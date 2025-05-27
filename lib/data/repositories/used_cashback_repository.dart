import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/models/cashback_model.dart';

class UsedCashbackRepository {
  late CollectionReference usedCashbackCollection;
  late CollectionReference companiesCollection;
  final firestore = FirebaseFirestore.instance;
  AuthController authController = Get.find<AuthController>();

  UsedCashbackRepository() {
    usedCashbackCollection = firestore.collection('usedCashback');
    companiesCollection = firestore.collection('companies');
  }

  Future<void> save(CashbackModel cashbackModel) async {
    usedCashbackCollection.add(cashbackModel.toJson());
  }

  Future<double> getUsedCashbackBalanceOnce() async {
    final snapshot = await usedCashbackCollection
        .where('customerId', isEqualTo: authController.user.value!.uid)
        .get();
    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc['cashback'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }
}
