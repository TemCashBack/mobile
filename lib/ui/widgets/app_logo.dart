import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/app_styles.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.borderRadius = BorderRadius.zero,
    this.showBackground = true,
  });

  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool showBackground;

  static const _assetPath = 'lib/ui/assets/logo.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      _assetPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
    );

    if (!showBackground) {
      return Padding(padding: padding, child: image);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.logoBackground,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: padding,
        child: image,
      ),
    );
  }
}
