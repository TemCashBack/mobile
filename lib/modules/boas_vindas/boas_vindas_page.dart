import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/buttons/link_button.dart';
import 'package:mobile/ui/widgets/buttons/login_button.dart';
import 'package:mobile/ui/widgets/buttons/register_button.dart';
import 'package:url_launcher/url_launcher.dart';

class BoasVindasPage extends StatelessWidget {
  const BoasVindasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logoWidth =
        math.min(MediaQuery.sizeOf(context).width * 0.48, 240.0);
    const logoAspectRatio = 6416 / 1531;
    final logoHeight = logoWidth / logoAspectRatio;
    final sloganFontSize = logoHeight * 0.22;

    return Scaffold(
      backgroundColor: AppColors.header,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/ui/assets/logo.png',
                      width: logoWidth,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: logoWidth,
                      child: Text(
                        'Cashback nas lojas que você ama',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: secondaryThemeColor,
                          fontSize: sloganFontSize,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    LoginButton(
                      onPressed: () => Get.offAndToNamed(AppRoutes.LOGIN),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.2),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ou',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.2),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RegisterButton(
                      onPressed: () => Get.toNamed(AppRoutes.REGISTRO),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Ao entrar, você concorda com nosso termo de uso e privacidade.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinkButton(
                      label: 'Termos de Uso e Privacidade',
                      onPressed: () =>
                          launchUrl(Uri.http('temcashback.com.br')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
