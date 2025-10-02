import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecuperacaoSenhaController extends GetxController {
  var isLoading = false.obs;
  var emailSent = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      Get.snackbar(
        'Erro',
        'Por favor, insira seu e-mail.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Erro',
        'Por favor, insira um e-mail válido.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      await _auth.sendPasswordResetEmail(email: email);
      emailSent.value = true;

      Get.snackbar(
        'Sucesso',
        'E-mail de recuperação enviado! Verifique sua caixa de entrada.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      // Aguarda 3 segundos e volta para a tela de login
      Future.delayed(Duration(seconds: 3), () {
        Get.back();
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Não existe uma conta com este e-mail.';
          break;
        case 'invalid-email':
          errorMessage = 'E-mail inválido.';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        default:
          errorMessage =
              'Erro ao enviar e-mail de recuperação. Tente novamente.';
      }

      Get.snackbar(
        'Erro',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro inesperado. Tente novamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
