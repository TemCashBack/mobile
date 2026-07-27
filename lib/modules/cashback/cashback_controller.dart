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
  final usedCashback = 0.0.obs;
  final utilizaValor = 0.0.obs;
  final isLoading = false.obs;

  late final MoneyMaskedTextController valorCompraController;
  late final MoneyMaskedTextController utilizaValorController;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  XFile? _pickedImage;

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
    loadCashbackBalance();
  }

  void resetValues() {
    valorCompra.value = 0.0;
    cashback.value = 0.0;
    usedCashback.value = 0.0;
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
    final maxUsed = usedCashback.value;
    if (inputValue > maxUsed) {
      utilizaValorController.updateValue(maxUsed);
      utilizaValor.value = maxUsed;
    } else {
      utilizaValor.value = inputValue;
    }
  }

  Future<String> saveCashBack() async {
    final dateTime = DateTime.now();
    final onlyDate = DateFormat('yyyy-MM-dd').format(dateTime);
    cashback.value = valorCompra.value * (5 / 100);
    final downloadUrl = await _uploadImageToFirebase();

    final cashbackModel = CashbackModel(
      companyId: companyId.value,
      customerId: customerController.customerId.value,
      valor: valorCompra.value,
      cashback: cashback.value,
      dateTime: Timestamp.fromDate(dateTime),
      date: onlyDate,
      imagem: downloadUrl,
      aprovado: false,
      utilizado: false,
    );

    final id = await cashbackRepository.save(cashbackModel);
    isLoading.value = false;
    resetValues();
    return id;
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

  Future<void> loadCashbackBalance() async {
    final customerId = customerController.customerId.value;
    if (customerId.isEmpty) return;
    usedCashback.value =
        await cashbackRepository.getCashbackBalance(customerId);
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
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
