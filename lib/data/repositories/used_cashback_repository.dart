import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/constants/firestore_collections.dart';
import 'package:mobile/data/models/cashback_model.dart';

class UsedCashbackRepository {
  late CollectionReference usedCashbackCollection;
  final firestore = FirebaseFirestore.instance;

  UsedCashbackRepository() {
    usedCashbackCollection =
        firestore.collection(FirestoreCollections.usedCashback);
  }

  Future<void> save(CashbackModel cashbackModel) async {
    await usedCashbackCollection.add(cashbackModel.toJson());
  }

  Future<double> getUsedCashbackBalanceOnce(String customerId) async {
    final snapshot = await usedCashbackCollection
        .where('customerId', isEqualTo: customerId)
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      total += (doc['cashback'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }
}
