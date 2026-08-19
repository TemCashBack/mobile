import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/constants/firestore_collections.dart';
import 'package:mobile/data/models/cashback_model.dart';
import 'package:mobile/data/models/used_cashback_model.dart';

class CashbackRepository {
  late CollectionReference cashbackCollection;
  late CollectionReference usedCashbackCollection;
  late CollectionReference companiesCollection;
  final firestore = FirebaseFirestore.instance;

  CashbackRepository() {
    cashbackCollection = firestore.collection(FirestoreCollections.cashback);
    companiesCollection = firestore.collection(FirestoreCollections.companies);
    usedCashbackCollection =
        firestore.collection(FirestoreCollections.usedCashback);
  }

  Future<String> save(CashbackModel cashbackModel) async {
    final doc = await cashbackCollection.add(cashbackModel.toJson());
    return doc.id;
  }

  double _remainingOf(Map<String, dynamic> data) {
    final cashback = (data['cashback'] as num?)?.toDouble() ?? 0.0;
    final utilizado = data['utilizado'] == true;
    final restante = (data['cashbackRestante'] as num?)?.toDouble();
    if (restante != null) return restante < 0 ? 0.0 : restante;
    return utilizado ? 0.0 : cashback;
  }

  bool _isExpired(Map<String, dynamic> data) {
    final expiresAt = data['expiresAt'] as Timestamp?;
    if (expiresAt == null) {
      final dateTime = data['dateTime'] as Timestamp?;
      if (dateTime == null) return false;
      return DateTime.now()
          .isAfter(dateTime.toDate().add(const Duration(days: 40)));
    }
    return DateTime.now().isAfter(expiresAt.toDate());
  }

  Stream<double> getRealTimeCashbackBalance(String customerId) {
    return cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (_isExpired(data)) continue;
        total += _remainingOf(data);
      }
      return total;
    });
  }

  Stream<double> getRealTimeCashbackBalanceUsed(String customerId) {
    return usedCashbackCollection
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final status = doc['status']?.toString();
        if (status == UsedCashbackStatus.estornado) continue;
        total += (doc['valorUtilizado'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    });
  }

  Future<double> getCashbackBalance(String customerId) async {
    final snapshot = await cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (_isExpired(data)) continue;
      total += _remainingOf(data);
    }
    return total;
  }

  /// Retorna saldo disponível APENAS da mesma loja (não expirado).
  Future<CashbackSpendAvailability> getSpendAvailability({
    required String customerId,
    required String companyId,
  }) async {
    final snapshot = await cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .where('companyId', isEqualTo: companyId)
        .get();

    double saldoLoja = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (_isExpired(data)) continue;
      final remaining = _remainingOf(data);
      if (remaining <= 0) continue;
      saldoLoja += remaining;
    }

    return CashbackSpendAvailability(
      saldoLoja: saldoLoja,
      maximoUtilizavel: saldoLoja,
    );
  }

  /// Reserva saldo de forma atômica — apenas da mesma loja.
  Future<UsedCashbackModel> reservarCashback({
    required String customerId,
    required String companyId,
    required double valorUtilizado,
    required double compraValor,
    String? compraCashbackId,
  }) async {
    if (valorUtilizado <= 0) {
      throw ArgumentError('valorUtilizado deve ser maior que zero');
    }
    if (valorUtilizado > compraValor + 0.001) {
      throw StateError('Cashback não pode exceder o valor da compra.');
    }

    final candidates = await cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .where('companyId', isEqualTo: companyId)
        .get();

    final candidateRefs = <DocumentReference>[];
    for (final doc in candidates.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (_isExpired(data)) continue;
      if (_remainingOf(data) <= 0) continue;
      candidateRefs.add(doc.reference);
    }

    final usedRef = usedCashbackCollection.doc();
    final dateTime = DateTime.now();
    final date = DateFormatHelper.ymd(dateTime);

    return firestore.runTransaction((transaction) async {
      final snaps = <DocumentSnapshot>[];
      for (final ref in candidateRefs) {
        snaps.add(await transaction.get(ref));
      }

      double available = 0;
      for (final snap in snaps) {
        if (!snap.exists) continue;
        final data = snap.data() as Map<String, dynamic>;
        if (_isExpired(data)) continue;
        available += _remainingOf(data);
      }

      if (valorUtilizado > available + 0.001) {
        throw StateError('Valor de cashback acima do limite permitido.');
      }

      var remainingToSpend = valorUtilizado;
      final alocacoes = <UsedCashbackAllocation>[];

      for (final snap in snaps) {
        if (remainingToSpend <= 0.001) break;
        if (!snap.exists) continue;
        final data = Map<String, dynamic>.from(
          snap.data() as Map<String, dynamic>,
        );
        if (_isExpired(data)) continue;
        final currentRemaining = _remainingOf(data);
        if (currentRemaining <= 0) continue;

        final take = currentRemaining < remainingToSpend
            ? currentRemaining
            : remainingToSpend;
        final newRemaining = currentRemaining - take;

        transaction.update(snap.reference, {
          'cashbackRestante': newRemaining,
          'utilizado': newRemaining <= 0.001,
        });

        alocacoes.add(
          UsedCashbackAllocation(
            cashbackId: snap.id,
            origemCompanyId: companyId,
            valor: take,
          ),
        );

        remainingToSpend -= take;
      }

      if (remainingToSpend > 0.05) {
        throw StateError('Não foi possível alocar todo o cashback solicitado.');
      }

      final totalUsed = alocacoes.fold(0.0, (s, a) => s + a.valor);

      final model = UsedCashbackModel(
        customerId: customerId,
        companyId: companyId,
        valorUtilizado: totalUsed,
        compraValor: compraValor,
        gerouCashback: false,
        status: UsedCashbackStatus.reservado,
        compraCashbackId: compraCashbackId,
        alocacoes: alocacoes,
        dateTime: Timestamp.fromDate(dateTime),
        date: date,
      );

      transaction.set(usedRef, model.toJson());
      return model;
    });
  }

  Future<void> confirmarResgate(String usedCashbackId) async {
    final ref = usedCashbackCollection.doc(usedCashbackId);
    await firestore.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (!snap.exists) {
        throw StateError('Resgate não encontrado.');
      }
      final status = snap['status']?.toString();
      if (status == UsedCashbackStatus.estornado) {
        throw StateError('Resgate já foi estornado.');
      }
      if (status == UsedCashbackStatus.confirmado) return;
      transaction.update(ref, {'status': UsedCashbackStatus.confirmado});
    });
  }

  Future<void> confirmarResgatePorCompra(String compraCashbackId) async {
    final snapshot = await usedCashbackCollection
        .where('compraCashbackId', isEqualTo: compraCashbackId)
        .where('status', isEqualTo: UsedCashbackStatus.reservado)
        .get();

    for (final doc in snapshot.docs) {
      await confirmarResgate(doc.id);
    }
  }

  Future<void> estornarResgate(String usedCashbackId) async {
    final usedRef = usedCashbackCollection.doc(usedCashbackId);

    await firestore.runTransaction((transaction) async {
      final usedSnap = await transaction.get(usedRef);
      if (!usedSnap.exists) {
        throw StateError('Resgate não encontrado.');
      }

      final usedData = usedSnap.data() as Map<String, dynamic>;
      final status = usedData['status']?.toString();
      if (status == UsedCashbackStatus.estornado) return;

      final rawAlloc = usedData['alocacoes'];
      final alocacoes = <UsedCashbackAllocation>[];
      if (rawAlloc is List) {
        for (final item in rawAlloc) {
          if (item is Map<String, dynamic>) {
            alocacoes.add(UsedCashbackAllocation.fromJson(item));
          } else if (item is Map) {
            alocacoes.add(
              UsedCashbackAllocation.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }

      final allocSnaps = <DocumentSnapshot>[];
      for (final alloc in alocacoes) {
        allocSnaps.add(
          await transaction.get(cashbackCollection.doc(alloc.cashbackId)),
        );
      }

      for (var i = 0; i < alocacoes.length; i++) {
        final alloc = alocacoes[i];
        final snap = allocSnaps[i];
        if (!snap.exists) continue;

        final data = Map<String, dynamic>.from(
          snap.data() as Map<String, dynamic>,
        );
        final cashbackValue = (data['cashback'] as num?)?.toDouble() ?? 0.0;
        final currentRemaining = _remainingOf(data);
        final restoredRemaining = math.min(
          cashbackValue,
          currentRemaining + alloc.valor,
        );

        transaction.update(snap.reference, {
          'cashbackRestante': restoredRemaining,
          'utilizado': restoredRemaining <= 0.001,
        });
      }

      transaction.update(usedRef, {'status': UsedCashbackStatus.estornado});
    });
  }

  Future<void> estornarResgatePorCompra(String compraCashbackId) async {
    final snapshot = await usedCashbackCollection
        .where('compraCashbackId', isEqualTo: compraCashbackId)
        .get();

    for (final doc in snapshot.docs) {
      final status = doc['status']?.toString();
      if (status == UsedCashbackStatus.estornado) continue;
      await estornarResgate(doc.id);
    }
  }

  Stream<List<Map<String, dynamic>>> getLast10Document(String customerId) {
    return getUnifiedExtrato(customerId);
  }

  Stream<List<Map<String, dynamic>>> getUnifiedExtrato(String customerId) {
    final cashbackStream = cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('dateTime', descending: true)
        .limit(20)
        .snapshots();

    return cashbackStream.asyncMap((cashbackSnapshot) async {
      final usedSnapshot = await usedCashbackCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy('dateTime', descending: true)
          .limit(20)
          .get();

      final items = <Map<String, dynamic>>[];

      for (final doc in cashbackSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        items.add({
          'type': 'ganho',
          'dateTime': data['dateTime'],
          'cashback': data,
          'companyId': data['companyId'],
        });
      }

      for (final doc in usedSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        items.add({
          'type': 'resgate',
          'dateTime': data['dateTime'],
          'usedCashback': data,
          'companyId': data['companyId'],
        });
      }

      items.sort((a, b) {
        final aDt = a['dateTime'];
        final bDt = b['dateTime'];
        final aMs = aDt is Timestamp ? aDt.millisecondsSinceEpoch : 0;
        final bMs = bDt is Timestamp ? bDt.millisecondsSinceEpoch : 0;
        return bMs.compareTo(aMs);
      });

      final limited = items.take(20).toList();
      final companiesId = limited
          .map((e) => e['companyId']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final companiesMap = <String, dynamic>{};
      if (companiesId.isNotEmpty) {
        for (var i = 0; i < companiesId.length; i += 10) {
          final chunk = companiesId.sublist(
            i,
            i + 10 > companiesId.length ? companiesId.length : i + 10,
          );
          final companiesSnapshot = await companiesCollection
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          for (final company in companiesSnapshot.docs) {
            companiesMap[company.id] = company.data();
          }
        }
      }

      return limited.map((item) {
        final companyId = item['companyId']?.toString();
        return {
          ...item,
          'company': companyId == null ? null : companiesMap[companyId],
        };
      }).toList();
    });
  }

  Future<List<String>> deleteAllByCustomerId(String customerId) async {
    final imageUrls = <String>[];
    final cashbackSnapshot = await cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .get();
    final usedSnapshot = await usedCashbackCollection
        .where('customerId', isEqualTo: customerId)
        .get();

    var batch = firestore.batch();
    var ops = 0;

    Future<void> flushIfNeeded({bool force = false}) async {
      if (ops == 0) return;
      if (!force && ops < 450) return;
      await batch.commit();
      batch = firestore.batch();
      ops = 0;
    }

    for (final doc in cashbackSnapshot.docs) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        final image = data['imagem']?.toString().trim();
        if (image != null && image.isNotEmpty) imageUrls.add(image);
      }
      batch.delete(doc.reference);
      ops++;
      await flushIfNeeded();
    }

    for (final doc in usedSnapshot.docs) {
      batch.delete(doc.reference);
      ops++;
      await flushIfNeeded();
    }

    await flushIfNeeded(force: true);
    return imageUrls;
  }
}

class DateFormatHelper {
  static String ymd(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
