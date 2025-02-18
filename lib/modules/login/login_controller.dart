import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> loginWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar('Sucesso', 'Login realizado com sucesso!');
      // Navegar para a página inicial após o login
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar('Erro', 'Usuário não encontrado.');
      } else if (e.code == 'wrong-password') {
        Get.snackbar('Erro', 'Senha incorreta.');
      } else {
        Get.snackbar('Erro', e.message ?? 'Erro desconhecido.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Alternar visibilidade
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}
