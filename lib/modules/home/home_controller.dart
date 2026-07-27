import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';

class HomeController extends GetxController {
  HomeController({
    required this.cashbackRepository,
    required this.authController,
  });

  final CashbackRepository cashbackRepository;
  final AuthController authController;

  final moneyController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
    precision: 2,
  );

  final moneyController2 = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    precision: 2,
  );

  String get customerId => authController.user.value?.uid ?? '';

  Stream<double> get cashbackBalanceStream =>
      cashbackRepository.getRealTimeCashbackBalance(customerId);

  Stream<double> get cashbackUsedStream =>
      cashbackRepository.getRealTimeCashbackBalanceUsed(customerId);

  Stream<List<Map<String, dynamic>>> get extratoStream =>
      cashbackRepository.getLast10Document(customerId);

  String formatMaskedValue(double value) {
    moneyController2.updateValue(value);
    return moneyController2.text;
  }

  String formatTransactionValue(double value) {
    moneyController.updateValue(value);
    return moneyController.text;
  }

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp.toDate());
  }

  Map<String, dynamic> parseCompanyMap(dynamic company) {
    if (company is Map<String, dynamic>) return company;
    return jsonDecode(jsonEncode(company)) as Map<String, dynamic>;
  }

  @override
  void onClose() {
    moneyController.dispose();
    moneyController2.dispose();
    super.onClose();
  }
}
