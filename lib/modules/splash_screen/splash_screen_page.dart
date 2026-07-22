import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.header,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/ui/assets/logo.png',
                height: 100,
              ),
              const SizedBox(height: AppSpacing.lg),
              const ProgressIndicatorCustom(),
              const SizedBox(height: AppSpacing.md),
              Text(
                authController.isAuthReady.value
                    ? 'Redirecionando...'
                    : 'Carregando...',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
