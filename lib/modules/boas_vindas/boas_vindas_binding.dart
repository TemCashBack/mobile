import 'package:get/get.dart';
import 'boas_vindas_controller.dart';

class BoasVindasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoasVindasController>(() => BoasVindasController());
  }
}
