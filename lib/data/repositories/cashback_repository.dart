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

  Future<String> saveUsedCashback(UsedCashbackModel model) async {
    final doc = await usedCashbackCollection.add(model.toJson());
    return doc.id;
  }

  double _remainingOf(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final cashback = (data['cashback'] as num?)?.toDouble() ?? 0.0;
    final utilizado = data['utilizado'] == true;
    final restante = (data['cashbackRestante'] as num?)?.toDouble();
    if (restante != null) return restante < 0 ? 0.0 : restante;
    return utilizado ? 0.0 : cashback;
  }

  Stream<double> getRealTimeCashbackBalance(String customerId) {
    return cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (final doc in snapshot.docs) {
        total += _remainingOf(doc);
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
      total += _remainingOf(doc);
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

    for (final doc in snapshot.docs) {
      final remaining = _remainingOf(doc);
      if (remaining <= 0) continue;

      final originCompanyId = doc['companyId']?.toString() ?? '';
      if (originCompanyId == companyId) {
        mesmaLoja += remaining;
      } else {
        parceiraBruta += remaining;
      }
    }

    final parceiraUtilizavel = parceiraBruta * 0.5;
    return CashbackSpendAvailability(
      mesmaLoja: mesmaLoja,
      parceiraBruta: parceiraBruta,
      parceiraUtilizavel: parceiraUtilizavel,
      maximoUtilizavel: mesmaLoja + parceiraUtilizavel,
    );
  }

  /// Consome saldo aprovado: primeiro da mesma loja (100%), depois de outras (até 50%).
  Future<UsedCashbackModel> redeemCashback({
    required String customerId,
    required String companyId,
    required double valorUtilizado,
    required double compraValor,
    String? compraCashbackId,
  }) async {
    if (valorUtilizado <= 0) {
      throw ArgumentError('valorUtilizado deve ser maior que zero');
    }

    final availability = await getSpendAvailability(
      customerId: customerId,
      companyId: companyId,
    );

    if (valorUtilizado > availability.maximoUtilizavel + 0.001) {
      throw StateError('Valor de cashback acima do limite permitido.');
    }

    final snapshot = await cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .get();

    final sameStoreDocs = <QueryDocumentSnapshot>[];
    final partnerDocs = <QueryDocumentSnapshot>[];

    for (final doc in snapshot.docs) {
      if (_remainingOf(doc) <= 0) continue;
      final originCompanyId = doc['companyId']?.toString() ?? '';
      if (originCompanyId == companyId) {
        sameStoreDocs.add(doc);
      } else {
        partnerDocs.add(doc);
      }
    }

    var remainingToSpend = valorUtilizado;
    var usedSameStore = 0.0;
    var usedPartner = 0.0;

    Future<double> consumeFrom(
      List<QueryDocumentSnapshot> docs,
      double limit,
    ) async {
      var spent = 0.0;
      var left = limit;
      for (final doc in docs) {
        if (left <= 0.001) break;
        final currentRemaining = _remainingOf(doc);
        if (currentRemaining <= 0) continue;

        final take = currentRemaining < left ? currentRemaining : left;
        final newRemaining = currentRemaining - take;
        await doc.reference.update({
          'cashbackRestante': newRemaining,
          'utilizado': newRemaining <= 0.001,
        });
        spent += take;
        left -= take;
      }
      return spent;
    }

    final sameLimit =
        remainingToSpend < availability.mesmaLoja ? remainingToSpend : availability.mesmaLoja;
    usedSameStore = await consumeFrom(sameStoreDocs, sameLimit);
    remainingToSpend -= usedSameStore;

    if (remainingToSpend > 0.001) {
      final partnerLimit = remainingToSpend < availability.parceiraUtilizavel
          ? remainingToSpend
          : availability.parceiraUtilizavel;
      // Consome créditos parceiros pelo valor efetivamente usado (já limitado a 50%).
      usedPartner = await consumeFrom(partnerDocs, partnerLimit);
      remainingToSpend -= usedPartner;
    }

    if (remainingToSpend > 0.05) {
      throw StateError('Não foi possível alocar todo o cashback solicitado.');
    }

    final dateTime = DateTime.now();
    final model = UsedCashbackModel(
      customerId: customerId,
      companyId: companyId,
      valorUtilizado: usedSameStore + usedPartner,
      valorMesmaLoja: usedSameStore,
      valorParceira: usedPartner,
      compraValor: compraValor,
      gerouCashback: false,
      compraCashbackId: compraCashbackId,
      dateTime: Timestamp.fromDate(dateTime),
      date: '${dateTime.year.toString().padLeft(4, '0')}-'
          '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.day.toString().padLeft(2, '0')}',
    );

    await saveUsedCashback(model);
    return model;
  }

  Stream<List<Map<String, dynamic>>> getLast10Document(String customerId) {
    final cashbackStream = cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('dateTime', descending: true)
        .limit(10)
        .snapshots();

    return cashbackStream.asyncExpand((cashbackSnapshot) async* {
      final companiesId = cashbackSnapshot.docs
          .map((cashback) => cashback['companyId'])
          .toSet();

      if (companiesId.isEmpty) {
        yield [];
        return;
      }

      final companiesSnapshot = await companiesCollection
          .where(FieldPath.documentId, whereIn: companiesId.toList())
          .get();

      final companiesMap = {
        for (final company in companiesSnapshot.docs)
          company.id: company.data()
      };

      yield cashbackSnapshot.docs.map((cashback) {
        final companyId = cashback['companyId'];
        return {
          'cashback': cashback.data(),
          'company': companiesMap[companyId],
        };
      }).toList();
    });
  }
}
