import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/app_styles.dart';

/// Ícone da marca (links verde/branco) sobre fundo preto.
class AppBrandIcon extends StatelessWidget {
  const AppBrandIcon({super.key});

  static const _assetPath = 'lib/ui/assets/icone.png';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.logoBackground,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          _assetPath,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

/// Foto do estabelecimento ou ícone da marca como fallback.
class CompanyPhoto extends StatelessWidget {
  const CompanyPhoto({super.key, required this.foto});

  final String foto;

  @override
  Widget build(BuildContext context) {
    if (foto.trim().isEmpty) {
      return const AppBrandIcon();
    }

    return Image.network(
      foto,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const AppBrandIcon(),
    );
  }
}
