import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final customer = authController.customerData.value;
    final displayName = (customer?.nomeCompleto != null &&
            customer!.nomeCompleto!.trim().isNotEmpty)
        ? customer.nomeCompleto!.trim()
        : 'Usuário Tem Cashback';
    final photoUrl = customer?.photoURL;
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.header,
                  primaryThemeColor.shade900,
                ],
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: hasPhoto
                      ? Image.network(
                          photoUrl,
                          height: 56,
                          width: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarFallback(),
                        )
                      : _avatarFallback(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seu cashback, suas lojas',
                        style: TextStyle(
                          color: secondaryThemeColor.shade200,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  leading: Icon(
                    Icons.receipt_long_outlined,
                    color: primaryThemeColor.shade700,
                    size: 20,
                  ),
                  label: 'Extrato',
                  onTap: () => Get.offAndToNamed(AppRoutes.HOME),
                ),
                _DrawerItem(
                  leading: FaIcon(
                    FontAwesomeIcons.building,
                    color: primaryThemeColor.shade700,
                    size: 20,
                  ),
                  label: 'Nossos parceiros',
                  onTap: () => Get.offAndToNamed(AppRoutes.ESTABELECIMENTOS),
                ),
                const Divider(height: 24, indent: 20, endIndent: 20),
                _DrawerItem(
                  leading: FaIcon(
                    FontAwesomeIcons.doorOpen,
                    color: AppColors.error,
                    size: 20,
                  ),
                  label: 'Sair',
                  onTap: authController.signOut,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Image.asset(
      'lib/ui/assets/logo-round.png',
      height: 56,
      width: 56,
      fit: BoxFit.cover,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.leading,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final Widget leading;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: leading,
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      onTap: onTap,
    );
  }
}
