import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/CheckinModel.dart';

class CheckinRepository {
  late CollectionReference checkin;

  CheckinRepository() {
    checkin = FirebaseFirestore.instance.collection('checkin');
  }

  Stream<QuerySnapshot> getCompanies() {
    return checkin.snapshots(includeMetadataChanges: true);
  }

  Future<void> addCheckin(
      String companyId, String customerId, DateTime dateTime) async {
    var onlyDate = DateFormat("yyyy-MM-dd").format(dateTime);
    final data = CheckinModel(
        companyId: companyId,
        customerId: customerId,
        dateTime: dateTime,
        date: onlyDate);
    checkin.add(data.toJson());
  }

  Future<int> getCheckIns(
      String companyId, String customerId, DateTime dateTime) async {
    var onlyDate = DateFormat("yyyy-MM-dd").format(dateTime);
    var checkins = await this
        .checkin
        .where('customerId', isEqualTo: customerId)
        .where('companyId', isEqualTo: companyId)
        .where('date', isEqualTo: onlyDate)
        .get();
    return checkins.docs.length;
  }
}
