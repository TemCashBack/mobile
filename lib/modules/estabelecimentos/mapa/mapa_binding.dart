import 'package:get/get.dart';
import 'package:mobile/controllers/location_controller.dart';
import 'package:mobile/modules/cashback/cashback_binding.dart';
import 'mapa_controller.dart';

class MapaBinding extends Bindings {
  @override
  void dependencies() {
    CashbackBinding.registerDependencies();
    Get.lazyPut<MapaController>(() => MapaController());
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(() => LocationController(), fenix: true);
    }
  }
}
