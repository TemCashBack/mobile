import 'package:get/get.dart';
import 'estabelecimentos_controller.dart';

class EstabelecimentosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EstabelecimentosController>(
        () => EstabelecimentosController()); // Injeta o HomeController
  }
}
