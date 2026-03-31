import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/models/checkin_model.dart';

class CheckinRepository {
  late CollectionReference checkinCollection;
  late CollectionReference companiesCollection;
  final firestore = FirebaseFirestore.instance;
  AuthController authController = Get.find<AuthController>();

  CheckinRepository() {
    checkinCollection = firestore.collection('checkin');
    companiesCollection = firestore.collection('companies');
  }

  Stream<QuerySnapshot> getCompanies() {
    return checkinCollection.snapshots(includeMetadataChanges: true);
  }

  Future<void> addCheckin(
      String companyId, String customerId, DateTime dateTime) async {
    var onlyDate = DateFormat("yyyy-MM-dd").format(dateTime);
    final data = CheckinModel(
        companyId: companyId,
        customerId: customerId,
        dateTime: Timestamp.fromDate(dateTime),
        date: onlyDate);

    checkinCollection.add(data.toJson());
  }

  Stream<QuerySnapshot> getCheckInLength() {
    var checkins = checkinCollection
        .where('customerId', isEqualTo: authController.user.value!.uid)
        .snapshots(includeMetadataChanges: true);
    return checkins;
  }

  Future<int> getCheckIns(
      String companyId, String customerId, DateTime dateTime) async {
    var onlyDate = DateFormat("yyyy-MM-dd").format(dateTime);
    var checkins = await checkinCollection
        .where('customerId', isEqualTo: customerId)
        .where('companyId', isEqualTo: companyId)
        .where('date', isEqualTo: onlyDate)
        .get();
    return checkins.docs.length;
  }

  Stream<List<Map<String, dynamic>>> getLast10Checkins() {
    // Stream para a coleção de pedidos
    final checkinStream = checkinCollection
        .where('customerId', isEqualTo: authController.user.value!.uid)
        .orderBy('dateTime', descending: true)
        .limit(10)
        .snapshots();

    return checkinStream.asyncExpand((checkinSnapshot) async* {
      final companiesId = checkinSnapshot.docs
          .map((checkin) => checkin['companyId'])
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
      final joinedData = checkinSnapshot.docs.map((checkin) {
        final companyId = checkin['companyId'];
        final company = companiesMap[companyId];
        return {
          'checkin': checkin.data(),
          'company': company,
        };
      }).toList();

      // Emite os dados combinados como um stream
      yield joinedData;
    });
  }
}
