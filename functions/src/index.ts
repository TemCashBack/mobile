import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { setGlobalOptions } from "firebase-functions/v2";

setGlobalOptions({ region: "southamerica-east1" });
admin.initializeApp();

const db = admin.firestore();

export const checkEmailExists = onCall(async (request) => {
  const email = String(request.data?.email ?? "")
    .trim()
    .toLowerCase();
  if (!email) {
    throw new HttpsError("invalid-argument", "E-mail obrigatório.");
  }

  try {
    await admin.auth().getUserByEmail(email);
    return { exists: true };
  } catch (e: unknown) {
    const err = e as { code?: string };
    if (err.code === "auth/user-not-found") {
      return { exists: false };
    }
    throw new HttpsError("internal", "Falha ao verificar e-mail.");
  }
});

export const reviewPurchase = onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Faça login.");
  }

  const cashbackId = String(request.data?.cashbackId ?? "");
  const action = String(request.data?.action ?? "");
  if (!cashbackId || !["approve", "reject"].includes(action)) {
    throw new HttpsError("invalid-argument", "Parâmetros inválidos.");
  }

  const ref = db.collection("cashback").doc(cashbackId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Compra não encontrada.");
  }

  const companyId = String(snap.get("companyId") ?? "");
  if (!companyId) {
    throw new HttpsError("failed-precondition", "Compra sem companyId.");
  }

  const companySnap = await db.collection("companies").doc(companyId).get();
  if (!companySnap.exists) {
    throw new HttpsError("not-found", "Estabelecimento não encontrado.");
  }

  const company = companySnap.data() ?? {};
  const ownerUid =
    company.uid ?? company.ownerUid ?? company.userId ?? null;
  if (ownerUid !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "Apenas o lojista desta loja pode revisar a compra."
    );
  }

  await ref.update({
    aprovado: action === "approve",
    rejeitado: action === "reject",
    reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    reviewedBy: request.auth.uid,
  });

  return { ok: true };
});

export const onCashbackReviewUpdated = onDocumentUpdated(
  "cashback/{cashbackId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const cashbackId = event.params.cashbackId;
    const becameApproved = before.aprovado !== true && after.aprovado === true;
    const becameRejected =
      before.rejeitado !== true &&
      (after.rejeitado === true ||
        (after.aprovado === false && after.rejeitado === true));

    if (becameApproved) {
      const snap = await db
        .collection("usedCashback")
        .where("compraCashbackId", "==", cashbackId)
        .where("status", "==", "reservado")
        .get();
      const batch = db.batch();
      for (const doc of snap.docs) {
        batch.update(doc.ref, { status: "confirmado" });
      }
      await batch.commit();
      return;
    }

    if (becameRejected || (before.aprovado !== false && after.aprovado === false && after.rejeitado === true)) {
      if (after.rejeitado === true) {
        const snap = await db
          .collection("usedCashback")
          .where("compraCashbackId", "==", cashbackId)
          .get();
        for (const doc of snap.docs) {
          const status = doc.get("status");
          if (status === "estornado") continue;
          if (status === "reservado") {
            await restoreReservation(doc.id, doc.data());
          }
        }
      }
    }
  }
);

function isExpired(data: admin.firestore.DocumentData): boolean {
  const expiresAt = data.expiresAt as admin.firestore.Timestamp | undefined;
  if (expiresAt) {
    return Date.now() > expiresAt.toMillis();
  }
  const dateTime = data.dateTime as admin.firestore.Timestamp | undefined;
  if (dateTime) {
    const expiryMs = dateTime.toMillis() + 40 * 24 * 60 * 60 * 1000;
    return Date.now() > expiryMs;
  }
  return false;
}

async function restoreReservation(
  usedId: string,
  usedData: admin.firestore.DocumentData
): Promise<void> {
  await db.runTransaction(async (tx) => {
    const usedRef = db.collection("usedCashback").doc(usedId);
    const usedSnap = await tx.get(usedRef);
    if (!usedSnap.exists) return;
    if (usedSnap.get("status") === "estornado") return;

    const alocacoes = (usedData.alocacoes as Array<Record<string, unknown>>) ?? [];
    for (const alloc of alocacoes) {
      const cashbackId = String(alloc.cashbackId ?? "");
      const valor = Number(alloc.valor ?? 0);
      if (!cashbackId || valor <= 0) continue;

      const cbRef = db.collection("cashback").doc(cashbackId);
      const cbSnap = await tx.get(cbRef);
      if (!cbSnap.exists) continue;
      const data = cbSnap.data()!;

      if (isExpired(data)) continue;

      const cashbackValue = Number(data.cashback ?? 0);
      const restante = Number(
        data.cashbackRestante ?? (data.utilizado === true ? 0 : cashbackValue)
      );
      const restoredRemaining = Math.min(cashbackValue, restante + valor);

      tx.update(cbRef, {
        cashbackRestante: restoredRemaining,
        utilizado: restoredRemaining <= 0.001,
      });
    }

    tx.update(usedRef, { status: "estornado" });
  });
}
