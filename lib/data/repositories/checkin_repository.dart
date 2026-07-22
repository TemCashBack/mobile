import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/firestore_collections.dart';
import 'package:mobile/data/models/checkin_model.dart';

class CheckinRepository {
  late CollectionReference checkinCollection;
  late CollectionReference companiesCollection;
  final firestore = FirebaseFirestore.instance;

  CheckinRepository() {
    checkinCollection = firestore.collection(FirestoreCollections.checkin);
    companiesCollection = firestore.collection(FirestoreCollections.companies);
  }

  Stream<QuerySnapshot> getCompanies() {
    return checkinCollection.snapshots(includeMetadataChanges: true);
  }

  Future<void> addCheckin(
      String companyId, String customerId, DateTime dateTime) async {
    final onlyDate = DateFormat('yyyy-MM-dd').format(dateTime);
    final data = CheckinModel(
      companyId: companyId,
      customerId: customerId,
      dateTime: Timestamp.fromDate(dateTime),
      date: onlyDate,
    );

    await checkinCollection.add(data.toJson());
  }

  Stream<QuerySnapshot> getCheckInLength(String customerId) {
    return checkinCollection
        .where('customerId', isEqualTo: customerId)
        .snapshots(includeMetadataChanges: true);
  }

  Future<int> getCheckIns(
      String companyId, String customerId, DateTime dateTime) async {
    final onlyDate = DateFormat('yyyy-MM-dd').format(dateTime);
    final checkins = await checkinCollection
        .where('customerId', isEqualTo: customerId)
        .where('companyId', isEqualTo: companyId)
        .where('date', isEqualTo: onlyDate)
        .get();
    return checkins.docs.length;
  }

  Stream<List<Map<String, dynamic>>> getLast10Checkins(String customerId) {
    final checkinStream = checkinCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('dateTime', descending: true)
        .limit(10)
        .snapshots();

    return checkinStream.asyncExpand((checkinSnapshot) async* {
      final companiesId =
          checkinSnapshot.docs.map((checkin) => checkin['companyId']).toSet();

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

      yield checkinSnapshot.docs.map((checkin) {
        final companyId = checkin['companyId'];
        return {
          'checkin': checkin.data(),
          'company': companiesMap[companyId],
        };
      }).toList();
    });
  }
}
