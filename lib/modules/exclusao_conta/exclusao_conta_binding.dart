import 'package:get/get.dart';
import 'package:mobile/modules/exclusao_conta/exclusao_conta_controller.dart';

class ExclusaoContaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExclusaoContaController>(() => ExclusaoContaController());
  }
}
