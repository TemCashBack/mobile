import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/widgets/app_logo.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.logoBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(
              height: 100,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            const SizedBox(height: AppSpacing.lg),
            const ProgressIndicatorCustom(),
          ],
        ),
      ),
    );
  }
}
