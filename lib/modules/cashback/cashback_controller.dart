import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/customer_controller.dart';
import 'package:mobile/data/models/cashback_model.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';

class CashbackController extends GetxController {
  var companyId = ''.obs;
  var currentStep = 0.obs;
  var imageFile = Rx<File?>(null);
  var valorCompra = 0.0.obs;
  var cashback = 0.0.obs;

  final CustomerController customerController = Get.find<CustomerController>();
  final CashbackRepository cashbackRepository = CashbackRepository();

  void saveCashBack() {
    var dateTime = DateTime.now();
    var onlyDate = DateFormat("yyyy-MM-dd").format(dateTime);
    cashback.value = valorCompra.value * (5 / 100);

    CashbackModel cashbackModel = CashbackModel(
        companyId: companyId.value,
        customerId: customerController.customerId.value,
        valor: valorCompra.value,
        cashback: cashback.value,
        dateTime: Timestamp.fromDate(dateTime),
        date: onlyDate,
        imagem: '');
    cashbackRepository.save(cashbackModel);
  }

  void nextStep() {
    if (currentStep < 2) {
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }
}
