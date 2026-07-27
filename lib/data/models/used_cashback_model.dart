import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UsedCashbackStatus {
  static const reservado = 'reservado';
  static const confirmado = 'confirmado';
  static const estornado = 'estornado';
}

class UsedCashbackAllocation {
  final String cashbackId;
  final String origemCompanyId;
  final double valor;
  final bool mesmaLoja;

  const UsedCashbackAllocation({
    required this.cashbackId,
    required this.origemCompanyId,
    required this.valor,
    required this.mesmaLoja,
  });

  factory UsedCashbackAllocation.fromJson(Map<String, dynamic> json) {
    return UsedCashbackAllocation(
      cashbackId: json['cashbackId']?.toString() ?? '',
      origemCompanyId: json['origemCompanyId']?.toString() ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      mesmaLoja: json['mesmaLoja'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cashbackId': cashbackId,
      'origemCompanyId': origemCompanyId,
      'valor': valor,
      'mesmaLoja': mesmaLoja,
    };
  }
}

class UsedCashbackModel {
  String customerId;
  String companyId;
  double valorUtilizado;
  double valorMesmaLoja;
  double valorParceira;
  double compraValor;
  bool gerouCashback;
  String status;
  String? compraCashbackId;
  List<UsedCashbackAllocation> alocacoes;
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
    required this.status,
    required this.dateTime,
    required this.date,
    this.compraCashbackId,
    this.alocacoes = const [],
  });

  factory UsedCashbackModel.fromJson(Map<String, dynamic> json) {
    final rawAlloc = json['alocacoes'];
    final alocacoes = <UsedCashbackAllocation>[];
    if (rawAlloc is List) {
      for (final item in rawAlloc) {
        if (item is Map<String, dynamic>) {
          alocacoes.add(UsedCashbackAllocation.fromJson(item));
        } else if (item is Map) {
          alocacoes.add(
            UsedCashbackAllocation.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return UsedCashbackModel(
      customerId: json['customerId']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      valorUtilizado: (json['valorUtilizado'] as num?)?.toDouble() ?? 0.0,
      valorMesmaLoja: (json['valorMesmaLoja'] as num?)?.toDouble() ?? 0.0,
      valorParceira: (json['valorParceira'] as num?)?.toDouble() ?? 0.0,
      compraValor: (json['compraValor'] as num?)?.toDouble() ?? 0.0,
      gerouCashback: json['gerouCashback'] == true,
      status: json['status']?.toString() ?? UsedCashbackStatus.confirmado,
      compraCashbackId: json['compraCashbackId']?.toString(),
      alocacoes: alocacoes,
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
      'status': status,
      'compraCashbackId': compraCashbackId,
      'alocacoes': alocacoes.map((e) => e.toJson()).toList(),
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
