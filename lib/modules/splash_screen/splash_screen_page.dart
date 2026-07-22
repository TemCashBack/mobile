import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/ui/assets/logo.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              const ProgressIndicatorCustom(),
              const SizedBox(height: 20),
              Text(
                authController.isAuthReady.value
                    ? 'Redirecionando...'
                    : 'Carregando...',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    });
  }
}
