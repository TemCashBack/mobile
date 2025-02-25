import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/controllers/instalation_controller.dart';
import 'package:mobile/controllers/maps_avalible_controller.dart';
import 'package:mobile/controllers/nivel_controller.dart';
import 'package:mobile/data/repositories/customer_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerRepository>(() => CustomerRepository());
    Get.lazyPut<AuthController>(() =>
        AuthController(customerRepository: Get.find<CustomerRepository>()));
    Get.lazyPut<MapsAvalibleController>(() => MapsAvalibleController());
    Get.lazyPut<InstallationController>(() => InstallationController());
    Get.lazyPut<NivelController>(() => NivelController());
  }
}
