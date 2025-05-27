import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/customer_controller.dart';
import 'package:mobile/data/models/cashback_model.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';
import 'package:mobile/data/repositories/used_cashback_repository.dart';
import 'package:path/path.dart';

class CashbackController extends GetxController {
  var companyId = ''.obs;
  var currentStep = 0.obs;
  var imagePath = "".obs;
  var valorCompra = 0.0.obs;
  var cashback = 0.0.obs;
  var usedCashback = 0.0.obs;
  var utilizaValor = 0.0.obs;

  RxBool isLoading = false.obs;

  final CustomerController customerController = Get.find<CustomerController>();
  final CashbackRepository cashbackRepository = CashbackRepository();
  final UsedCashbackRepository usedCashbackRepository =
      UsedCashbackRepository();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void onInit() {
    super.onInit();
    loadCashbackBalance();
  }

  void resetValues() {
    valorCompra.value = 0.0;
    cashback.value = 0.0;
    usedCashback.value = 0.0;
    utilizaValor.value = 0.0;
  }

  Future<String> saveCashBack() async {
    var dateTime = DateTime.now();
    var onlyDate = DateFormat("yyyy-MM-dd").format(dateTime);
    cashback.value = valorCompra.value * (5 / 100);
    String downloadUrl = "";
    //salva a imagem
    downloadUrl = await _uploadImageToFirebase(imagePath.value);

    CashbackModel cashbackModel = CashbackModel(
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

    return await cashbackRepository.save(cashbackModel).then((id) {
      isLoading.value = false;
      resetValues();
      return id;
    });
  }

  Future<String> _uploadImageToFirebase(String imagePath) async {
    String fileName = basename(imagePath);
    Reference ref = _storage.ref().child('comprovante/$fileName');
    File file = File(imagePath);
    await ref.putFile(file);

    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> loadCashbackBalance() async {
    double balance = await cashbackRepository.getCashbackBalance();
    usedCashback.value = balance;
  }

  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
    }
  }

  void setCompanyId(String id) {
    companyId.value = id;
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
    }
  }
}
