import 'package:get/get.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'registro_controller.dart';

class RegistroBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistroController>(
      () => RegistroController(
        customerRepository: Get.find<CustomerRepository>(),
      ),
    );
  }
}
