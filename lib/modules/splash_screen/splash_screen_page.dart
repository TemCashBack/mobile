import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Realiza o redirecionamento com base no estado do usuário6
    Future.delayed(Duration.zero, () {
      if (authController.user.value != null) {
        Get.offNamed(AppRoutes.HOME);
      } else {
        Get.offNamed(AppRoutes.BOASVINDAS);
      }
    });

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
            SizedBox(height: 20),
            ProgressIndicatorCustom(),
            SizedBox(height: 20),
            Text(
              'Carregando...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
