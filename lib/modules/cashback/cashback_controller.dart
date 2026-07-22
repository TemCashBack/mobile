import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  var companyId = ''.obs;
  var currentStep = 0.obs;
  var imagePath = ''.obs;
  var valorCompra = 0.0.obs;
  var cashback = 0.0.obs;
  var usedCashback = 0.0.obs;
  var utilizaValor = 0.0.obs;
  RxBool isLoading = false.obs;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  void resetFlow() {
    currentStep.value = 0;
    imagePath.value = '';
    resetValues();
    loadCashbackBalance();
  }

  void resetValues() {
    valorCompra.value = 0.0;
    cashback.value = 0.0;
    usedCashback.value = 0.0;
    utilizaValor.value = 0.0;
  }

  Future<String> saveCashBack() async {
    final dateTime = DateTime.now();
    final onlyDate = DateFormat('yyyy-MM-dd').format(dateTime);
    cashback.value = valorCompra.value * (5 / 100);
    final downloadUrl = await _uploadImageToFirebase(imagePath.value);

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

  Future<String> _uploadImageToFirebase(String path) async {
    final fileName = basename(path);
    final ref = _storage.ref().child('comprovante/$fileName');
    await ref.putFile(File(path));
    return ref.getDownloadURL();
  }

  Future<void> loadCashbackBalance() async {
    final customerId = customerController.customerId.value;
    if (customerId.isEmpty) return;
    usedCashback.value = await cashbackRepository.getCashbackBalance(customerId);
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void setCompanyId(String id) {
    companyId.value = id;
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
    }
  }

  @override
  void onReady() {
    super.onReady();
    resetFlow();
  }
}
