import 'package:cloud_firestore/cloud_firestore.dart';

class CashbackModel {
  String companyId;
  String customerId;
  double valor;
  double cashback;
  Timestamp dateTime;
  String date;
  String imagem;
  bool aprovado;
  bool utilizado;

  CashbackModel(
      {required this.companyId,
      required this.customerId,
      required this.valor,
      required this.cashback,
      required this.dateTime,
      required this.date,
      required this.imagem,
      required this.aprovado,
      required this.utilizado});

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    return CashbackModel(
        companyId: json['companyId'],
        customerId: json['customerId'],
        valor: (json['valor'] as num).toDouble(),
        cashback: (json['cashback'] as num).toDouble(),
        dateTime: json['dateTime'],
        date: json['date'],
        imagem: json['imagem'],
        aprovado: json['aprovado'],
        utilizado: json['utilizado']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['companyId'] = companyId;
    data['customerId'] = customerId;
    data['valor'] = valor;
    data['cashback'] = cashback;
    data['dateTime'] = dateTime;
    data['date'] = date;
    data['imagem'] = imagem;
    data['aprovado'] = aprovado;
    data['utilizado'] = utilizado;
    return data;
  }
}
