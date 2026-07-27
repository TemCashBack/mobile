import 'package:get/get.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'registro_controller.dart';

class RegistroBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<RegistroController>()) {
      Get.delete<RegistroController>(force: true);
    }
    Get.put<RegistroController>(
      RegistroController(
        customerRepository: Get.find<CustomerRepository>(),
      ),
      permanent: false,
    );
  }
}
