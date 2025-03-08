import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/models/cashback_model.dart';

class CashbackRepository {
  late CollectionReference cashbackColletion;
  late CollectionReference companiesCollection;
  final firestore = FirebaseFirestore.instance;
  AuthController authController = Get.find<AuthController>();

  CashbackRepository() {
    cashbackColletion = firestore.collection('cashback');
    companiesCollection = firestore.collection('companies');
  }

  Future<void> save(CashbackModel cashbackModel) async {
    cashbackColletion.add(cashbackModel.toJson());
  }

  Stream<double> getRealTimeCashbackBalance() {
    return cashbackColletion
        .where('customerId', isEqualTo: authController.user.value!.uid)
        .where('aprovado', isEqualTo: true)
        .where('utilizado', isEqualTo: false)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += doc['cashback']?.toDouble() ?? 0.0;
      }
      return total;
    });
  }

  Stream<double> getRealTimeCashbackBalanceUsed() {
    return cashbackColletion
        .where('customerId', isEqualTo: authController.user.value!.uid)
        .where('aprovado', isEqualTo: true)
        .where('utilizado', isEqualTo: true)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += doc['cashback']?.toDouble() ?? 0.0;
      }
      return total;
    });
  }

  Stream<List<Map<String, dynamic>>> getLast10Document() {
    // Stream para a coleção de pedidos
    final cashbackStream = cashbackColletion
        .where('customerId', isEqualTo: authController.user.value!.uid)
        .orderBy('dateTime', descending: true)
        .limit(10)
        .snapshots();

    return cashbackStream.asyncExpand((cashbackSnapshot) async* {
      final companiesId = cashbackSnapshot.docs
          .map((cashback) => cashback['companyId'])
          .toSet(); // Remove duplicados

      if (companiesId.isEmpty) {
        yield [];
        return;
      }

      // Cria uma consulta dinâmica para buscar os usuários relacionados
      final companiesSnapshot = await companiesCollection
          .where(FieldPath.documentId, whereIn: companiesId.toList())
          .get();

      // Mapa de usuários para combinar os dados
      final companiesMap = {
        for (var user in companiesSnapshot.docs) user.id: user.data()
      };

      // Combina os dados dos pedidos com os usuários
      final joinedData = cashbackSnapshot.docs.map((cashback) {
        final companyId = cashback['companyId'];
        final company = companiesMap[companyId];
        return {
          'cashback': cashback.data(),
          'company': company,
        };
      }).toList();

      // Emite os dados combinados como um stream
      yield joinedData;
    });
  }
}
