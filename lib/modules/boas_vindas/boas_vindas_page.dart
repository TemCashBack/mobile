import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/buttons/LinkButton.dart';
import 'package:mobile/ui/widgets/buttons/LoginButton.dart';
import 'package:mobile/ui/widgets/buttons/RegisterButton.dart';
import 'package:url_launcher/url_launcher.dart';

class BoasVindasPage extends StatelessWidget {
  const BoasVindasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.header,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'lib/ui/assets/logo.png',
                width: MediaQuery.of(context).size.width * 0.65,
              ),
              const SizedBox(height: 12),
              Text(
                'Cashback nas lojas que você ama',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryThemeColor.shade200,
                  fontSize: 14,
                ),
              ),
              const Spacer(flex: 2),
              LoginButton(onPressed: () => Get.offAndToNamed(AppRoutes.LOGIN)),
              const SizedBox(height: 12),
              RegisterButton(
                onPressed: () => Get.toNamed(AppRoutes.REGISTRO),
              ),
              const Spacer(),
              Text(
                'Ao entrar, você concorda com nossos termos de uso e privacidade.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              LinkButton(
                label: 'Termos de Uso e Privacidade',
                onPressed: () => launchUrl(Uri.http('temcashback.com.br')),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
