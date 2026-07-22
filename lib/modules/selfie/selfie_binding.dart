import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'selfie_controller.dart';

class SelfieBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfieController>(
      () => SelfieController(
        authController: Get.find<AuthController>(),
        customerRepository: Get.find<CustomerRepository>(),
      ),
    );
  }
}
