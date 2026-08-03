import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/modules/cashback/cashback_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/buttons/informar_compra_button.dart';
import 'package:mobile/ui/widgets/buttons/phone_button.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';
import 'package:mobile/utils/social_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyBottomSheet {
  CompanyBottomSheet({required this.context});

  BuildContext context;
  AuthController authController = Get.find<AuthController>();

  double distance = 0.0;

  CashbackController get cashbackController => Get.find<CashbackController>();

  Future<void> showAlert(String mensagem) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'Atenção',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void showCompany(
    String id,
    CompanyModel companyModel,
    Position? currentLocation,
  ) {
    // Loja online não exige GPS; física sem localização bloqueia a compra.
    if (!companyModel.isOnline && currentLocation == null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const _SheetShell(
          child: _LocationUnavailable(),
        ),
      );
      return;
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetShell(
        child: _CompanySheetContent(
          company: companyModel,
          onInformarCompra: () =>
              _onInformarCompra(id, companyModel, currentLocation),
          onCall: (telefone) => launchUrl(Uri.parse('tel://$telefone')),
          onWhatsApp: launchWhatsApp,
        ),
      ),
    );
  }

  void _goToCashback(String id) {
    cashbackController.setCompanyId(id);
    Get.toNamed(AppRoutes.CASHBACK);
  }

  /// RISCO CONHECIDO: a validação de distância (~15m) é client-side e
  /// pode ser bypassada. Mitigação completa exige Cloud Function/Rules.
  Future<void> _onInformarCompra(
    String id,
    CompanyModel modelCompany,
    Position? currentLocation,
  ) async {
    if (modelCompany.isOnline) {
      _goToCashback(id);
      return;
    }

    if (currentLocation == null) {
      await showAlert(
        'Não foi possível obter sua localização. Ative o GPS e tente novamente.',
      );
      return;
    }

    distance = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      modelCompany.geolocalizacao.lat,
      modelCompany.geolocalizacao.lng,
    );
    if (distance > 15) {
      await showAlert(
        'Você deve estar mais próximo para efetuar a compra.',
      );
    } else {
      _goToCashback(id);
    }
  }

  Future<void> launchWhatsApp(String whatsapp) async {
    final phone = whatsapp.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://api.whatsapp.com/send?phone=$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _LocationUnavailable extends StatelessWidget {
  const _LocationUnavailable();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Localização indisponível',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Não foi possível utilizar a localização. Ative o GPS e tente novamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanySheetContent extends StatelessWidget {
  const _CompanySheetContent({
    required this.company,
    required this.onInformarCompra,
    required this.onCall,
    required this.onWhatsApp,
  });

  final CompanyModel company;
  final VoidCallback onInformarCompra;
  final void Function(String telefone) onCall;
  final Future<void> Function(String whatsapp) onWhatsApp;

  bool get _hasSocials =>
      company.socials.facebook.isNotEmpty ||
      company.socials.instagram.isNotEmpty ||
      company.socials.whatsapp.isNotEmpty ||
      company.socials.linkedin.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompanyAvatar(foto: company.foto),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.nomeFantasia,
                        style: TextStyle(
                          color: primaryThemeColor.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _StatusChip(isOnline: company.isOnline),
                      if (company.categoria.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          company.categoria,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _AddressCard(company: company),
            if (_hasSocials) ...[
              const SizedBox(height: AppSpacing.md),
              _SocialRow(
                company: company,
                onWhatsApp: onWhatsApp,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            InformarCompraButton(onPressed: onInformarCompra),
            if (company.telefones.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              ...company.telefones.map(
                (telefone) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: PhoneButton(
                    onPressed: () => onCall(telefone),
                    label: telefone,
                  ),
                ),
              ),
            ],
            if (!company.isOnline) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Abrir no mapa',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MapAppsRow(company: company),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  const _CompanyAvatar({required this.foto});

  final String foto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: foto.isNotEmpty
          ? Image.network(
              foto,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'lib/ui/assets/logo-round.png',
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'lib/ui/assets/logo-round.png',
              fit: BoxFit.cover,
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? primaryThemeColor : secondaryThemeColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.language_rounded : Icons.storefront_rounded,
            size: 14,
            color: color.shade800,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Serviço on-line' : 'Loja física',
            style: TextStyle(
              color: color.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.company});

  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    if (company.isOnline) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_outlined, color: primaryThemeColor.shade700),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'Este estabelecimento atende de forma on-line.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final street = '${company.endereco}, ${company.numero}';
    final city = '${company.bairro} — ${company.municipio}/${company.uf}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place_outlined, color: primaryThemeColor.shade700),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  street,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  city,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({
    required this.company,
    required this.onWhatsApp,
  });

  final CompanyModel company;
  final Future<void> Function(String whatsapp) onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (company.socials.facebook.isNotEmpty)
          _SocialIconButton(
            icon: FontAwesomeIcons.facebook,
            color: const Color(0xFF1877F2),
            onPressed: () =>
                SocialLauncher.launchFacebook(company.socials.facebook),
          ),
        if (company.socials.instagram.isNotEmpty)
          _SocialIconButton(
            icon: FontAwesomeIcons.instagram,
            color: const Color(0xFFE4405F),
            onPressed: () =>
                SocialLauncher.launchInstagram(company.socials.instagram),
          ),
        if (company.socials.whatsapp.isNotEmpty)
          _SocialIconButton(
            icon: FontAwesomeIcons.whatsapp,
            color: const Color(0xFF25D366),
            onPressed: () => onWhatsApp(company.socials.whatsapp),
          ),
        if (company.socials.linkedin.isNotEmpty)
          _SocialIconButton(
            icon: FontAwesomeIcons.linkedin,
            color: const Color(0xFF0A66C2),
            onPressed: () =>
                SocialLauncher.launchLinkedin(company.socials.linkedin),
          ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final FaIconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: FaIcon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

class _MapAppsRow extends StatelessWidget {
  const _MapAppsRow({required this.company});

  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvailableMap>>(
      future: MapLauncher.installedMaps,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Center(child: ProgressIndicatorCustom()),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Não foi possível carregar os mapas.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            'Nenhum app de mapa disponível neste dispositivo.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          );
        }

        final availableMaps = snapshot.data!;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: availableMaps.map((map) {
            return Material(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () async {
                  await map.showMarker(
                    coords: Coords(
                      company.geolocalizacao.lat,
                      company.geolocalizacao.lng,
                    ),
                    title: company.nomeFantasia,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        map.icon,
                        width: 22,
                        height: 22,
                        placeholderBuilder: (_) =>
                            const ProgressIndicatorCustom(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        map.mapName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
