import 'dart:math' as math;
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

  final saldoLoja = 0.0.obs;
  final maximoSaldo = 0.0.obs;

  /// Configuração da loja atual (vinda do Firestore).
  final cashbackPercentual = 5.0.obs;
  final limiteCompra = 200.0.obs;

  late final MoneyMaskedTextController valorCompraController;
  late final MoneyMaskedTextController utilizaValorController;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  XFile? _pickedImage;

  double get maximoUtilizavel =>
      math.min(maximoSaldo.value, valorCompra.value);

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
    _loadCompanyConfig();
    loadSpendAvailability();
  }

  void resetValues() {
    valorCompra.value = 0.0;
    cashback.value = 0.0;
    utilizaValor.value = 0.0;
    valorCompraController.updateValue(0);
    utilizaValorController.updateValue(0);
  }

  Future<void> _loadCompanyConfig() async {
    final id = companyId.value;
    if (id.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(id)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        cashbackPercentual.value =
            (data['cashbackPercentual'] as num?)?.toDouble() ?? 5.0;
        limiteCompra.value =
            (data['limiteCompra'] as num?)?.toDouble() ?? 200.0;
      }
    } catch (_) {
      // fallback para valores padrão
    }
  }

  void onValorCompraChanged(String _) {
    final inputValue = valorCompraController.numberValue;
    final limite = limiteCompra.value;
    if (inputValue > limite) {
      valorCompraController.updateValue(limite);
      valorCompra.value = limite;
    } else {
      valorCompra.value = inputValue;
    }
    _clampUtilizaValor();
  }

  void onUtilizaValorChanged(String _) {
    _clampUtilizaValor(fromInput: true);
  }

  void _clampUtilizaValor({bool fromInput = false}) {
    final inputValue = fromInput
        ? utilizaValorController.numberValue
        : utilizaValor.value;
    final maxUsed = maximoUtilizavel;
    if (inputValue > maxUsed) {
      utilizaValorController.updateValue(maxUsed);
      utilizaValor.value = maxUsed;
    } else {
      utilizaValor.value = inputValue;
      if (!fromInput) {
        utilizaValorController.updateValue(inputValue);
      }
    }
  }

  Future<void> loadSpendAvailability() async {
    final customerId = customerController.customerId.value;
    final currentCompanyId = companyId.value;
    if (customerId.isEmpty || currentCompanyId.isEmpty) {
      saldoLoja.value = 0;
      maximoSaldo.value = 0;
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
    saldoLoja.value = availability.saldoLoja;
    maximoSaldo.value = availability.maximoUtilizavel;
    _clampUtilizaValor();
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
    _clampUtilizaValor();

    final usingCashback = utilizaValor.value > 0;
    if (usingCashback && utilizaValor.value > valorCompra.value + 0.001) {
      throw StateError('Cashback não pode exceder o valor da compra.');
    }

    final pct = cashbackPercentual.value / 100;
    final earnedCashback =
        usingCashback ? 0.0 : valorCompra.value * pct;
    cashback.value = earnedCashback;

    final downloadUrl = await _uploadImageToFirebase(customerId);
    final dateTime = DateTime.now();
    final onlyDate = DateFormat('yyyy-MM-dd').format(dateTime);
    final expiresAt = dateTime.add(const Duration(days: 40));

    final cashbackModel = CashbackModel(
      companyId: companyId.value,
      customerId: customerId,
      valor: valorCompra.value,
      cashback: earnedCashback,
      cashbackRestante: earnedCashback,
      valorUtilizado: usingCashback ? utilizaValor.value : 0,
      dateTime: Timestamp.fromDate(dateTime),
      expiresAt: Timestamp.fromDate(expiresAt),
      date: onlyDate,
      imagem: downloadUrl,
      aprovado: false,
      utilizado: earnedCashback <= 0,
    );

    final compraId = await cashbackRepository.save(cashbackModel);

    if (usingCashback) {
      await cashbackRepository.reservarCashback(
        customerId: customerId,
        companyId: companyId.value,
        valorUtilizado: utilizaValor.value,
        compraValor: valorCompra.value,
        compraCashbackId: compraId,
      );
    }

    resetValues();
    return compraId;
  }

  Future<String> _uploadImageToFirebase(String customerId) async {
    final picked = _pickedImage;
    final bytes = imageBytes.value;
    if (picked == null || bytes == null) {
      throw Exception('Nenhuma imagem selecionada');
    }

    final originalName =
        basename(picked.name.isNotEmpty ? picked.name : 'comprovante.jpg');
    final safeName = originalName.toLowerCase().endsWith('.jpg') ||
            originalName.toLowerCase().endsWith('.jpeg') ||
            originalName.toLowerCase().endsWith('.png') ||
            originalName.toLowerCase().endsWith('.webp')
        ? originalName
        : '$originalName.jpg';
    final fileName =
        '${customerId}_${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = _storage.ref().child('comprovante/$fileName');

    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
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

  Future<void> pickImage({ImageSource? preferred}) async {
    final picker = ImagePicker();
    final primary = preferred ??
        (kIsWeb ? ImageSource.gallery : ImageSource.camera);

    Future<XFile?> tryPick(ImageSource source) async {
      try {
        return await picker.pickImage(source: source, imageQuality: 100);
      } catch (_) {
        return null;
      }
    }

    var pickedFile = await tryPick(primary);

    if (pickedFile == null &&
        !kIsWeb &&
        primary == ImageSource.camera) {
      pickedFile = await tryPick(ImageSource.gallery);
    }

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
