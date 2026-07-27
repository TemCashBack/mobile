import 'package:cloud_firestore/cloud_firestore.dart';

class CashbackModel {
  String companyId;
  String customerId;
  double valor;
  double cashback;
  double cashbackRestante;
  Timestamp dateTime;
  String date;
  String imagem;
  bool aprovado;
  bool utilizado;

  CashbackModel({
    required this.companyId,
    required this.customerId,
    required this.valor,
    required this.cashback,
    required this.cashbackRestante,
    required this.dateTime,
    required this.date,
    required this.imagem,
    required this.aprovado,
    required this.utilizado,
  });

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    final cashbackValue = (json['cashback'] as num?)?.toDouble() ?? 0.0;
    final utilizado = json['utilizado'] == true;
    final restanteRaw = (json['cashbackRestante'] as num?)?.toDouble();

    return CashbackModel(
      companyId: json['companyId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      cashback: cashbackValue,
      cashbackRestante: restanteRaw ?? (utilizado ? 0.0 : cashbackValue),
      dateTime: json['dateTime'] as Timestamp,
      date: json['date']?.toString() ?? '',
      imagem: json['imagem']?.toString() ?? '',
      aprovado: json['aprovado'] == true,
      utilizado: utilizado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'customerId': customerId,
      'valor': valor,
      'cashback': cashback,
      'cashbackRestante': cashbackRestante,
      'dateTime': dateTime,
      'date': date,
      'imagem': imagem,
      'aprovado': aprovado,
      'utilizado': utilizado,
    };
  }
}
