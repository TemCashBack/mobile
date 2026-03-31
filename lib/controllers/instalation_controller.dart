import 'package:get/get.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

class InstallationController extends GetxController {
  var installationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getInstallationId();
  }

  // Função para obter o Firebase Installation ID
  Future<void> _getInstallationId() async {
    try {
      String? id = await FirebaseInstallations.instance.getId();
      installationId.value = id;
      print('ID de instalação: $id');
    } catch (e) {
      print('Erro ao obter ID de instalação: $e');
    }
  }
}
