"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onCashbackReviewUpdated = exports.reviewPurchase = exports.checkEmailExists = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const v2_1 = require("firebase-functions/v2");
(0, v2_1.setGlobalOptions)({ region: "southamerica-east1" });
admin.initializeApp();
const db = admin.firestore();
/** Verifica se o e-mail já existe no Firebase Auth (sem criar user temporário). */
exports.checkEmailExists = (0, https_1.onCall)(async (request) => {
    const email = String(request.data?.email ?? "")
        .trim()
        .toLowerCase();
    if (!email) {
        throw new https_1.HttpsError("invalid-argument", "E-mail obrigatório.");
    }
    try {
        await admin.auth().getUserByEmail(email);
        return { exists: true };
    }
    catch (e) {
        const err = e;
        if (err.code === "auth/user-not-found") {
            return { exists: false };
        }
        throw new https_1.HttpsError("internal", "Falha ao verificar e-mail.");
    }
});
/** Aprova/rejeita compra (painel do lojista daquela companyId). */
exports.reviewPurchase = (0, https_1.onCall)(async (request) => {
    if (!request.auth?.uid) {
        throw new https_1.HttpsError("unauthenticated", "Faça login.");
    }
    const cashbackId = String(request.data?.cashbackId ?? "");
    const action = String(request.data?.action ?? "");
    if (!cashbackId || !["approve", "reject"].includes(action)) {
        throw new https_1.HttpsError("invalid-argument", "Parâmetros inválidos.");
    }
    const ref = db.collection("cashback").doc(cashbackId);
    const snap = await ref.get();
    if (!snap.exists) {
        throw new https_1.HttpsError("not-found", "Compra não encontrada.");
    }
    const companyId = String(snap.get("companyId") ?? "");
    if (!companyId) {
        throw new https_1.HttpsError("failed-precondition", "Compra sem companyId.");
    }
    const companySnap = await db.collection("companies").doc(companyId).get();
    if (!companySnap.exists) {
        throw new https_1.HttpsError("not-found", "Estabelecimento não encontrado.");
    }
    const company = companySnap.data() ?? {};
    const ownerUid = company.uid ?? company.ownerUid ?? company.userId ?? null;
    if (ownerUid !== request.auth.uid) {
        throw new https_1.HttpsError("permission-denied", "Apenas o lojista desta loja pode revisar a compra.");
    }
    await ref.update({
        aprovado: action === "approve",
        rejeitado: action === "reject",
        reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
        reviewedBy: request.auth.uid,
    });
    return { ok: true };
});
/**
 * Quando a compra muda para aprovada/rejeitada, confirma ou estorna o resgate.
 * Espelha confirmarResgatePorCompra / estornarResgatePorCompra do app.
 */
exports.onCashbackReviewUpdated = (0, firestore_1.onDocumentUpdated)("cashback/{cashbackId}", async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after)
        return;
    const cashbackId = event.params.cashbackId;
    const becameApproved = before.aprovado !== true && after.aprovado === true;
    const becameRejected = before.rejeitado !== true &&
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
        // Estorno completo fica no app (transaction complexa); marca status.
        // Preferência: admin rejeita com field rejeitado:true.
        if (after.rejeitado === true) {
            const snap = await db
                .collection("usedCashback")
                .where("compraCashbackId", "==", cashbackId)
                .get();
            for (const doc of snap.docs) {
                const status = doc.get("status");
                if (status === "estornado")
                    continue;
                // Marca para o client/admin processar estorno atômico se necessário.
                // Aqui confirmamos rejeição setando status estornado apenas se ainda reservado,
                // sem restaurar saldos (resto pode ser feito por callable dedicada).
                if (status === "reservado") {
                    await restoreReservation(doc.id, doc.data());
                }
            }
        }
    }
});
async function restoreReservation(usedId, usedData) {
    await db.runTransaction(async (tx) => {
        const usedRef = db.collection("usedCashback").doc(usedId);
        const usedSnap = await tx.get(usedRef);
        if (!usedSnap.exists)
            return;
        if (usedSnap.get("status") === "estornado")
            return;
        const alocacoes = usedData.alocacoes ?? [];
        for (const alloc of alocacoes) {
            const cashbackId = String(alloc.cashbackId ?? "");
            const valor = Number(alloc.valor ?? 0);
            const mesmaLoja = alloc.mesmaLoja === true;
            if (!cashbackId || valor <= 0)
                continue;
            const cbRef = db.collection("cashback").doc(cashbackId);
            const cbSnap = await tx.get(cbRef);
            if (!cbSnap.exists)
                continue;
            const data = cbSnap.data();
            const cashbackValue = Number(data.cashback ?? 0);
            const restante = Number(data.cashbackRestante ?? (data.utilizado === true ? 0 : cashbackValue));
            const restoredRemaining = Math.min(cashbackValue, restante + valor);
            const parceiraRaw = data.parceiraRestante;
            const currentParceira = typeof parceiraRaw === "number"
                ? parceiraRaw
                : data.utilizado === true
                    ? 0
                    : cashbackValue * 0.5;
            const restoredParceira = mesmaLoja
                ? currentParceira
                : Math.min(cashbackValue * 0.5, currentParceira + valor);
            tx.update(cbRef, {
                cashbackRestante: restoredRemaining,
                parceiraRestante: restoredParceira,
                utilizado: restoredRemaining <= 0.001,
            });
        }
        tx.update(usedRef, { status: "estornado" });
    });
}
//# sourceMappingURL=index.js.map