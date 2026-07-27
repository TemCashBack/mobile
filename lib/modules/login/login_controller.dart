import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> submit() async {
    await loginWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
  }

  Future<void> loginWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(
        title: 'Campos obrigatórios',
        message: 'Informe e-mail e senha para entrar.',
      );
      return;
    }

    isLoading.value = true;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(
        title: 'Não foi possível entrar',
        message: _messageForAuthError(e),
      );
    } catch (_) {
      _showErrorDialog(
        title: 'Erro inesperado',
        message: 'Tente novamente em alguns instantes.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _messageForAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'wrong-password':
        return 'A senha informada está incorreta.';
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'E-mail ou senha incorretos. Verifique e tente novamente.';
      case 'invalid-email':
        return 'O e-mail informado não é válido.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Entre em contato com o suporte.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um momento e tente de novo.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet e tente novamente.';
      default:
        return 'Não foi possível autenticar. Confira seus dados e tente novamente.';
    }
  }

  void _showErrorDialog({
    required String title,
    required String message,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryThemeColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
