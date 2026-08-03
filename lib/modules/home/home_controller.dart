import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/models/company_model.dart';
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

  String _boundCustomerId = '';
  Stream<double>? _cashbackBalanceStream;
  Stream<double>? _cashbackUsedStream;
  Stream<List<Map<String, dynamic>>>? _extratoStream;

  String get customerId => authController.user.value?.uid ?? '';

  void _ensureStreams() {
    final id = customerId;
    if (id.isEmpty) {
      _boundCustomerId = '';
      _cashbackBalanceStream = null;
      _cashbackUsedStream = null;
      _extratoStream = null;
      return;
    }
    if (_boundCustomerId == id &&
        _cashbackBalanceStream != null &&
        _cashbackUsedStream != null &&
        _extratoStream != null) {
      return;
    }
    _boundCustomerId = id;
    _cashbackBalanceStream =
        cashbackRepository.getRealTimeCashbackBalance(id);
    _cashbackUsedStream =
        cashbackRepository.getRealTimeCashbackBalanceUsed(id);
    _extratoStream = cashbackRepository.getUnifiedExtrato(id);
  }

  Stream<double> get cashbackBalanceStream {
    _ensureStreams();
    return _cashbackBalanceStream ?? const Stream.empty();
  }

  Stream<double> get cashbackUsedStream {
    _ensureStreams();
    return _cashbackUsedStream ?? const Stream.empty();
  }

  Stream<List<Map<String, dynamic>>> get extratoStream {
    _ensureStreams();
    return _extratoStream ?? const Stream.empty();
  }

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
    return CompanyModel.mapFromFirestore(company);
  }

  @override
  void onClose() {
    moneyController.dispose();
    moneyController2.dispose();
    super.onClose();
  }
}
