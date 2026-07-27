import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/customer_controller.dart';
import 'package:mobile/data/models/cashback_model.dart';
import 'package:mobile/data/models/used_cashback_model.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';
import 'package:path/path.dart';

class CashbackController extends GetxController {
  CashbackController({
    required this.cashbackRepository,
    required this.customerController,
  });

  final CashbackRepository cashbackRepository;
  final CustomerController customerController;

  final companyId = ''.obs;
  final currentStep = 0.obs;
  final imagePath = ''.obs;
  final imageBytes = Rxn<Uint8List>();
  final valorCompra = 0.0.obs;
  final cashback = 0.0.obs;
  final utilizaValor = 0.0.obs;
  final isLoading = false.obs;
  final isLoadingBalance = false.obs;

  final saldoMesmaLoja = 0.0.obs;
  final saldoParceiraBruta = 0.0.obs;
  final saldoParceiraUtilizavel = 0.0.obs;
  final maximoUtilizavel = 0.0.obs;

  late final MoneyMaskedTextController valorCompraController;
  late final MoneyMaskedTextController utilizaValorController;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  XFile? _pickedImage;

  bool get vaiGerarCashback => utilizaValor.value <= 0;

  @override
  void onInit() {
    super.onInit();
    valorCompraController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );
    utilizaValorController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );
  }

  void resetFlow() {
    currentStep.value = 0;
    imagePath.value = '';
    imageBytes.value = null;
    _pickedImage = null;
    resetValues();
    loadSpendAvailability();
  }

  void resetValues() {
    valorCompra.value = 0.0;
    cashback.value = 0.0;
    utilizaValor.value = 0.0;
    valorCompraController.updateValue(0);
    utilizaValorController.updateValue(0);
  }

  void onValorCompraChanged(String _) {
    final inputValue = valorCompraController.numberValue;
    if (inputValue > 200) {
      valorCompraController.updateValue(200);
      valorCompra.value = 200;
    } else {
      valorCompra.value = inputValue;
    }
  }

  void onUtilizaValorChanged(String _) {
    final inputValue = utilizaValorController.numberValue;
    final maxUsed = maximoUtilizavel.value;
    if (inputValue > maxUsed) {
      utilizaValorController.updateValue(maxUsed);
      utilizaValor.value = maxUsed;
    } else {
      utilizaValor.value = inputValue;
    }
  }

  Future<void> loadSpendAvailability() async {
    final customerId = customerController.customerId.value;
    final currentCompanyId = companyId.value;
    if (customerId.isEmpty || currentCompanyId.isEmpty) {
      saldoMesmaLoja.value = 0;
      saldoParceiraBruta.value = 0;
      saldoParceiraUtilizavel.value = 0;
      maximoUtilizavel.value = 0;
      return;
    }

    isLoadingBalance.value = true;
    try {
      final availability = await cashbackRepository.getSpendAvailability(
        customerId: customerId,
        companyId: currentCompanyId,
      );
      _applyAvailability(availability);
    } finally {
      isLoadingBalance.value = false;
    }
  }

  void _applyAvailability(CashbackSpendAvailability availability) {
    saldoMesmaLoja.value = availability.mesmaLoja;
    saldoParceiraBruta.value = availability.parceiraBruta;
    saldoParceiraUtilizavel.value = availability.parceiraUtilizavel;
    maximoUtilizavel.value = availability.maximoUtilizavel;

    if (utilizaValor.value > availability.maximoUtilizavel) {
      utilizaValorController.updateValue(availability.maximoUtilizavel);
      utilizaValor.value = availability.maximoUtilizavel;
    }
  }

  Future<String> saveCashBack() async {
    final customerId = customerController.customerId.value;
    if (customerId.isEmpty) {
      throw StateError('Cliente não identificado.');
    }
    if (companyId.value.isEmpty) {
      throw StateError('Loja não identificada.');
    }

    onValorCompraChanged('');
    onUtilizaValorChanged('');

    final usingCashback = utilizaValor.value > 0;
    final earnedCashback =
        usingCashback ? 0.0 : valorCompra.value * (5 / 100);
    cashback.value = earnedCashback;

    final downloadUrl = await _uploadImageToFirebase();
    final dateTime = DateTime.now();
    final onlyDate = DateFormat('yyyy-MM-dd').format(dateTime);

    final cashbackModel = CashbackModel(
      companyId: companyId.value,
      customerId: customerId,
      valor: valorCompra.value,
      cashback: earnedCashback,
      cashbackRestante: earnedCashback,
      dateTime: Timestamp.fromDate(dateTime),
      date: onlyDate,
      imagem: downloadUrl,
      aprovado: false,
      utilizado: earnedCashback <= 0,
    );

    final compraId = await cashbackRepository.save(cashbackModel);

    if (usingCashback) {
      await cashbackRepository.redeemCashback(
        customerId: customerId,
        companyId: companyId.value,
        valorUtilizado: utilizaValor.value,
        compraValor: valorCompra.value,
        compraCashbackId: compraId,
      );
    }

    isLoading.value = false;
    resetValues();
    return compraId;
  }

  Future<String> _uploadImageToFirebase() async {
    final picked = _pickedImage;
    final bytes = imageBytes.value;
    if (picked == null || bytes == null) {
      throw Exception('Nenhuma imagem selecionada');
    }

    final fileName =
        basename(picked.name.isNotEmpty ? picked.name : 'comprovante.jpg');
    final ref = _storage.ref().child('comprovante/$fileName');
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
      if (currentStep.value == 2) {
        loadSpendAvailability();
      }
    }
  }

  void setCompanyId(String id) {
    companyId.value = id;
    resetFlow();
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 100,
    );
    if (pickedFile == null) return;

    _pickedImage = pickedFile;
    imagePath.value = pickedFile.path;
    imageBytes.value = await pickedFile.readAsBytes();
  }

  @override
  void onReady() {
    super.onReady();
    resetFlow();
  }

  @override
  void onClose() {
    valorCompraController.dispose();
    utilizaValorController.dispose();
    super.onClose();
  }
}
