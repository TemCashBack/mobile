import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/login/login_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.header,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'lib/ui/assets/logo.png',
                    height: 64,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Bem-vindo de volta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryThemeColor.shade200,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Entre com seu e-mail e senha para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'seu@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Obx(
                          () => TextField(
                            obscureText: !controller.isPasswordVisible.value,
                            controller: controller.passwordController,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) => controller.submit(),
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              hintText: 'Sua senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: controller.isPasswordVisible.value
                                    ? 'Ocultar senha'
                                    : 'Mostrar senha',
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
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(child: ProgressIndicatorCustom()),
                            );
                          }
                          return ElevatedButton(
                            onPressed: controller.submit,
                            child: const Text('ENTRAR'),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ainda não tem conta?',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.REGISTRO),
                        child: Text(
                          'Criar conta',
                          style: TextStyle(
                            color: secondaryThemeColor.shade300,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
