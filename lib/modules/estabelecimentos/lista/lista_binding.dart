import 'package:get/get.dart';
import 'package:mobile/controllers/location_controller.dart';
import 'package:mobile/modules/cashback/cashback_binding.dart';
import 'lista_controller.dart';

class ListaBinding extends Bindings {
  @override
  void dependencies() {
    CashbackBinding.registerDependencies();
    Get.lazyPut<ListaController>(() => ListaController());
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(() => LocationController(), fenix: true);
    }
  }
}
