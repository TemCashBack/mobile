import 'package:get/get.dart';
import 'lista_controller.dart';

class ListaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListaController>(
        () => ListaController()); // Injeta o HomeController
  }
}
