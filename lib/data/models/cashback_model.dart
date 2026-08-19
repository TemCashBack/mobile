import 'package:cloud_firestore/cloud_firestore.dart';

class CashbackModel {
  String companyId;
  String customerId;
  double valor;
  double cashback;
  double cashbackRestante;
  double valorUtilizado;
  Timestamp dateTime;
  Timestamp expiresAt;
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
    required this.expiresAt,
    required this.date,
    required this.imagem,
    required this.aprovado,
    required this.utilizado,
    this.valorUtilizado = 0,
  });

  bool get isExpired =>
      DateTime.now().isAfter(expiresAt.toDate());

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    final cashbackValue = (json['cashback'] as num?)?.toDouble() ?? 0.0;
    final utilizado = json['utilizado'] == true;
    final restanteRaw = (json['cashbackRestante'] as num?)?.toDouble();
    final restante = restanteRaw ?? (utilizado ? 0.0 : cashbackValue);

    final dtRaw = json['dateTime'] as Timestamp;
    final expiresRaw = json['expiresAt'] as Timestamp?;
    final expires = expiresRaw ??
        Timestamp.fromDate(dtRaw.toDate().add(const Duration(days: 40)));

    return CashbackModel(
      companyId: json['companyId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      cashback: cashbackValue,
      cashbackRestante: restante,
      valorUtilizado: (json['valorUtilizado'] as num?)?.toDouble() ?? 0.0,
      dateTime: dtRaw,
      expiresAt: expires,
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
      'valorUtilizado': valorUtilizado,
      'dateTime': dateTime,
      'expiresAt': expiresAt,
      'date': date,
      'imagem': imagem,
      'aprovado': aprovado,
      'utilizado': utilizado,
    };
  }
}
