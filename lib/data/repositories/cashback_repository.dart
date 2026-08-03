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

  double _parceiraRemainingOf(Map<String, dynamic> data) {
    final cashback = (data['cashback'] as num?)?.toDouble() ?? 0.0;
    final restante = _remainingOf(data);
    final parceiraRaw = (data['parceiraRestante'] as num?)?.toDouble();
    final parceira =
        parceiraRaw ?? (data['utilizado'] == true ? 0.0 : cashback * 0.5);
    return math.min(restante, parceira < 0 ? 0.0 : parceira);
  }

  Stream<double> getRealTimeCashbackBalance(String customerId) {
    return cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (final doc in snapshot.docs) {
        total += _remainingOf(doc.data() as Map<String, dynamic>);
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
      total += _remainingOf(doc.data() as Map<String, dynamic>);
    }
    return total;
  }

  Future<CashbackSpendAvailability> getSpendAvailability({
    required String customerId,
    required String companyId,
  }) async {
    final snapshot = await cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .get();

    double mesmaLoja = 0.0;
    double parceiraBruta = 0.0;
    double parceiraUtilizavel = 0.0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final remaining = _remainingOf(data);
      if (remaining <= 0) continue;

      final originCompanyId = data['companyId']?.toString() ?? '';
      if (originCompanyId == companyId) {
        mesmaLoja += remaining;
      } else {
        parceiraBruta += remaining;
        parceiraUtilizavel += _parceiraRemainingOf(data);
      }
    }

    return CashbackSpendAvailability(
      mesmaLoja: mesmaLoja,
      parceiraBruta: parceiraBruta,
      parceiraUtilizavel: parceiraUtilizavel,
      maximoUtilizavel: mesmaLoja + parceiraUtilizavel,
    );
  }

  /// Reserva saldo de forma atômica (status [UsedCashbackStatus.reservado]).
  /// Confirme com [confirmarResgate] ou devolva com [estornarResgate].
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
        .get();

    final sameStoreRefs = <DocumentReference>[];
    final partnerRefs = <DocumentReference>[];

    for (final doc in candidates.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (_remainingOf(data) <= 0) continue;
      final origin = data['companyId']?.toString() ?? '';
      if (origin == companyId) {
        sameStoreRefs.add(doc.reference);
      } else if (_parceiraRemainingOf(data) > 0) {
        partnerRefs.add(doc.reference);
      }
    }

    final usedRef = usedCashbackCollection.doc();
    final dateTime = DateTime.now();
    final date = DateFormatHelper.ymd(dateTime);

    return firestore.runTransaction((transaction) async {
      final sameSnaps = <DocumentSnapshot>[];
      final partnerSnaps = <DocumentSnapshot>[];

      for (final ref in sameStoreRefs) {
        sameSnaps.add(await transaction.get(ref));
      }
      for (final ref in partnerRefs) {
        partnerSnaps.add(await transaction.get(ref));
      }

      double mesmaLoja = 0;
      double parceiraUtilizavel = 0;
      for (final snap in sameSnaps) {
        if (!snap.exists) continue;
        mesmaLoja += _remainingOf(snap.data() as Map<String, dynamic>);
      }
      for (final snap in partnerSnaps) {
        if (!snap.exists) continue;
        parceiraUtilizavel +=
            _parceiraRemainingOf(snap.data() as Map<String, dynamic>);
      }

      final maximo = mesmaLoja + parceiraUtilizavel;
      if (valorUtilizado > maximo + 0.001) {
        throw StateError('Valor de cashback acima do limite permitido.');
      }

      var remainingToSpend = valorUtilizado;
      var usedSameStore = 0.0;
      var usedPartner = 0.0;
      final alocacoes = <UsedCashbackAllocation>[];

      void consume({
        required List<DocumentSnapshot> snaps,
        required double limit,
        required bool mesmaLojaConsume,
      }) {
        var left = limit;
        for (final snap in snaps) {
          if (left <= 0.001) break;
          if (!snap.exists) continue;
          final data = Map<String, dynamic>.from(
            snap.data() as Map<String, dynamic>,
          );
          final currentRemaining = _remainingOf(data);
          if (currentRemaining <= 0) continue;

          final available = mesmaLojaConsume
              ? currentRemaining
              : _parceiraRemainingOf(data);
          if (available <= 0) continue;

          final take = available < left ? available : left;
          final newRemaining = currentRemaining - take;
          final cashbackValue = (data['cashback'] as num?)?.toDouble() ?? 0.0;
          final currentParceira = (data['parceiraRestante'] as num?)?.toDouble() ??
              cashbackValue * 0.5;
          final newParceira = mesmaLojaConsume
              ? currentParceira
              : math.max(0.0, currentParceira - take);

          transaction.update(snap.reference, {
            'cashbackRestante': newRemaining,
            'parceiraRestante': newParceira,
            'utilizado': newRemaining <= 0.001,
          });

          alocacoes.add(
            UsedCashbackAllocation(
              cashbackId: snap.id,
              origemCompanyId: data['companyId']?.toString() ?? '',
              valor: take,
              mesmaLoja: mesmaLojaConsume,
            ),
          );

          if (mesmaLojaConsume) {
            usedSameStore += take;
          } else {
            usedPartner += take;
          }
          left -= take;
        }
        remainingToSpend -= (limit - left);
      }

      final sameLimit =
          remainingToSpend < mesmaLoja ? remainingToSpend : mesmaLoja;
      consume(
        snaps: sameSnaps,
        limit: sameLimit,
        mesmaLojaConsume: true,
      );

      if (remainingToSpend > 0.001) {
        final partnerLimit = remainingToSpend < parceiraUtilizavel
            ? remainingToSpend
            : parceiraUtilizavel;
        consume(
          snaps: partnerSnaps,
          limit: partnerLimit,
          mesmaLojaConsume: false,
        );
      }

      if (remainingToSpend > 0.05) {
        throw StateError('Não foi possível alocar todo o cashback solicitado.');
      }

      final model = UsedCashbackModel(
        customerId: customerId,
        companyId: companyId,
        valorUtilizado: usedSameStore + usedPartner,
        valorMesmaLoja: usedSameStore,
        valorParceira: usedPartner,
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
        final currentParceira = (data['parceiraRestante'] as num?)?.toDouble() ??
            (data['utilizado'] == true ? 0.0 : cashbackValue * 0.5);
        final restoredParceira = alloc.mesmaLoja
            ? currentParceira
            : math.min(cashbackValue * 0.5, currentParceira + alloc.valor);

        transaction.update(snap.reference, {
          'cashbackRestante': restoredRemaining,
          'parceiraRestante': restoredParceira,
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

  /// Extrato unificado: ganhos (cashback) + resgates (usedCashback).
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

  /// Remove cashbacks e resgates do cliente. Retorna URLs de comprovantes no Storage.
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
