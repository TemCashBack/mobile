import 'package:get/get.dart';
import 'package:mobile/controllers/location_controller.dart';

class ListaController extends GetxController {
  var term = ''.obs;
  var category = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _ensureLocation();
  }

  Future<void> _ensureLocation() async {
    if (!Get.isRegistered<LocationController>()) return;
    final location = Get.find<LocationController>();
    if (await location.ensureLocationAccess()) {
      await location.requestLocation();
    }
  }
}
