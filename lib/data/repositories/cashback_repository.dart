import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/constants/firestore_collections.dart';
import 'package:mobile/data/models/cashback_model.dart';

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

  Stream<double> getRealTimeCashbackBalance(String customerId) {
    return cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .where('utilizado', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (final doc in snapshot.docs) {
        total += doc['cashback']?.toDouble() ?? 0.0;
      }
      return total;
    });
  }

  Stream<double> getRealTimeCashbackBalanceUsed(String customerId) {
    return cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .where('aprovado', isEqualTo: true)
        .where('utilizado', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (final doc in snapshot.docs) {
        total += doc['cashback']?.toDouble() ?? 0.0;
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
      total += (doc['cashback'] as num?)?.toDouble() ?? 0.0;
    }

    final usedSnapshot = await usedCashbackCollection
        .where('customerId', isEqualTo: customerId)
        .get();

    double usedTotal = 0.0;
    for (final doc in usedSnapshot.docs) {
      usedTotal += (doc['cashback'] as num?)?.toDouble() ?? 0.0;
    }

    return total - usedTotal;
  }

  Stream<List<Map<String, dynamic>>> getLast10Document(String customerId) {
    final cashbackStream = cashbackCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('dateTime', descending: true)
        .limit(10)
        .snapshots();

    return cashbackStream.asyncExpand((cashbackSnapshot) async* {
      final companiesId =
          cashbackSnapshot.docs.map((cashback) => cashback['companyId']).toSet();

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
