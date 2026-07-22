import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';
import 'package:mobile/modules/home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        cashbackRepository: Get.find<CashbackRepository>(),
        authController: Get.find<AuthController>(),
      ),
    );
  }
}
