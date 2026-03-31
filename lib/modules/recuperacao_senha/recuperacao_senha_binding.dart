import 'package:get/get.dart';
import 'package:mobile/modules/recuperacao_senha/recuperacao_senha_controller.dart';

class RecuperacaoSenhaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecuperacaoSenhaController>(
      () => RecuperacaoSenhaController(),
    );
  }
}
