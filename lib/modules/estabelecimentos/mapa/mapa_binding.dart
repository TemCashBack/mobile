import 'package:get/get.dart';
import 'package:mobile/controllers/location_controller.dart';
import 'package:mobile/modules/cashback/cashback_binding.dart';

class MapaBinding extends Bindings {
  @override
  void dependencies() {
    CashbackBinding.registerDependencies();
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(() => LocationController(), fenix: true);
    }
  }
}
