import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/controllers/location_controller.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';
import 'package:mobile/data/repositories/category_repository.dart';
import 'package:mobile/data/repositories/checkin_repository.dart';
import 'package:mobile/data/repositories/company_repository.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/data/repositories/used_cashback_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerRepository>(() => CustomerRepository(), fenix: true);
    Get.lazyPut<CashbackRepository>(() => CashbackRepository(), fenix: true);
    Get.lazyPut<CheckinRepository>(() => CheckinRepository(), fenix: true);
    Get.lazyPut<UsedCashbackRepository>(
        () => UsedCashbackRepository(), fenix: true);
    Get.lazyPut<CompanyRepository>(() => CompanyRepository(), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(), fenix: true);
    Get.lazyPut<LocationController>(() => LocationController(), fenix: true);

    Get.put<AuthController>(
      AuthController(customerRepository: Get.find<CustomerRepository>()),
      permanent: true,
    );
  }
}
