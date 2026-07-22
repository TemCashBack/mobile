import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/login/login_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class LoginPage extends GetView<LoginController> {
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.header,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'lib/ui/assets/logo.png',
                    height: 72,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Entrar na sua conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryThemeColor.shade200,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(
                    () => TextField(
                      obscureText: !controller.isPasswordVisible.value,
                      controller: controller.passwordController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: ProgressIndicatorCustom());
                    }
                    return ElevatedButton(
                      onPressed: () {
                        controller.loginWithEmail(
                          controller.emailController.text.trim(),
                          controller.passwordController.text.trim(),
                        );
                      },
                      child: const Text('ENTRAR'),
                    );
                  }),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.REGISTRO),
                    child: Text(
                      'Criar uma conta',
                      style: TextStyle(color: secondaryThemeColor.shade300),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
