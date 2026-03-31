import 'package:cloud_firestore/cloud_firestore.dart';

class CheckinModel {
  String companyId;
  String customerId;
  Timestamp dateTime;
  String date;

  CheckinModel(
      {required this.companyId,
      required this.customerId,
      required this.dateTime,
      required this.date});

  factory CheckinModel.fromJson(Map<String, dynamic> json) {
    return CheckinModel(
      companyId: json['companyId'],
      customerId: json['customerId'],
      dateTime: json['dateTime'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['companyId'] = companyId;
    data['customerId'] = customerId;
    data['dateTime'] = dateTime;
    data['date'] = date;
    return data;
  }
}
