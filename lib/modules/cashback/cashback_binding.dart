import 'package:get/get.dart';
import 'cashback_controller.dart';

class CashbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashbackController>(
        () => CashbackController()); // Injeta o HomeController
  }
}
