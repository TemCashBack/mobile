import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/modules/home/home_page.dart';
import 'package:mobile/modules/login/login_page.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Realiza o redirecionamento com base no estado do usuário
    Future.delayed(Duration.zero, () {
      if (authController.user.value != null) {
        Get.off(() => HomePage());
      } else {
        // Se o usuário não está logado, vai para a LoginPage
        Get.off(() => LoginPage());
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/ui/assets/logo.png',
              height: 100,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
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
