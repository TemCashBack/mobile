import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile/controllers/location_controller.dart';

class ListaController extends GetxController {
  final term = ''.obs;
  final category = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _ensureLocation();
  }

  void onSearchChanged(String text) {
    term.value = text;
    if (text.isNotEmpty) {
      category.value = '';
    }
  }

  void selectCategory(String value) {
    if (category.value == value) {
      category.value = '';
      return;
    }
    category.value = value;
    if (value.isNotEmpty) {
      term.value = '';
      searchController.clear();
    }
  }

  void clearSearch() {
    term.value = '';
    searchController.clear();
  }

  void clearFilters() {
    term.value = '';
    category.value = '';
    searchController.clear();
  }

  Future<void> _ensureLocation() async {
    if (!Get.isRegistered<LocationController>()) return;
    final location = Get.find<LocationController>();
    if (await location.ensureLocationAccess()) {
      await location.requestLocation();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
