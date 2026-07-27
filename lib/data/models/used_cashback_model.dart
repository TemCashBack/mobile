import 'package:cloud_firestore/cloud_firestore.dart';

class UsedCashbackModel {
  String customerId;
  String companyId;
  double valorUtilizado;
  double valorMesmaLoja;
  double valorParceira;
  double compraValor;
  bool gerouCashback;
  String? compraCashbackId;
  Timestamp dateTime;
  String date;

  UsedCashbackModel({
    required this.customerId,
    required this.companyId,
    required this.valorUtilizado,
    required this.valorMesmaLoja,
    required this.valorParceira,
    required this.compraValor,
    required this.gerouCashback,
    required this.dateTime,
    required this.date,
    this.compraCashbackId,
  });

  factory UsedCashbackModel.fromJson(Map<String, dynamic> json) {
    return UsedCashbackModel(
      customerId: json['customerId']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      valorUtilizado: (json['valorUtilizado'] as num?)?.toDouble() ?? 0.0,
      valorMesmaLoja: (json['valorMesmaLoja'] as num?)?.toDouble() ?? 0.0,
      valorParceira: (json['valorParceira'] as num?)?.toDouble() ?? 0.0,
      compraValor: (json['compraValor'] as num?)?.toDouble() ?? 0.0,
      gerouCashback: json['gerouCashback'] == true,
      compraCashbackId: json['compraCashbackId']?.toString(),
      dateTime: json['dateTime'] as Timestamp,
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'companyId': companyId,
      'valorUtilizado': valorUtilizado,
      'valorMesmaLoja': valorMesmaLoja,
      'valorParceira': valorParceira,
      'compraValor': compraValor,
      'gerouCashback': gerouCashback,
      'compraCashbackId': compraCashbackId,
      'dateTime': dateTime,
      'date': date,
    };
  }
}

class CashbackSpendAvailability {
  final double mesmaLoja;
  final double parceiraBruta;
  final double parceiraUtilizavel;
  final double maximoUtilizavel;

  const CashbackSpendAvailability({
    required this.mesmaLoja,
    required this.parceiraBruta,
    required this.parceiraUtilizavel,
    required this.maximoUtilizavel,
  });
}
