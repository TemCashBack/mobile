import 'package:get/get.dart';
import 'registro_controller.dart';

class RegistroBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistroController>(() => RegistroController());
  }
}
