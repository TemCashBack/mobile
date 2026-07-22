import 'package:get/get.dart';
import 'package:mobile/controllers/customer_controller.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';
import 'package:mobile/modules/cashback/cashback_controller.dart';

class CashbackBinding extends Bindings {
  static void registerDependencies() {
    if (!Get.isRegistered<CashbackController>()) {
      Get.lazyPut<CashbackController>(
        () => CashbackController(
          cashbackRepository: Get.find<CashbackRepository>(),
          customerController: Get.find<CustomerController>(),
        ),
        fenix: true,
      );
    }
  }

  @override
  void dependencies() {
    registerDependencies();
  }
}
