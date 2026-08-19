import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/widgets/company_photo.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Obx(() {
        final customer = authController.customerData.value;
        final displayName = (customer?.nomeCompleto != null &&
                customer!.nomeCompleto!.trim().isNotEmpty)
            ? customer.nomeCompleto!.trim()
            : 'Usuário Tem Cashback';
        final photoBytes = authController.profilePhotoBytes.value;
        final photoUrl = customer?.photoURL?.trim();

        return Column(
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
                    AppColors.headerElevated,
                  ],
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: _DrawerAvatar(
                      photoBytes: photoBytes,
                      photoUrl: photoUrl,
                      fallback: _avatarFallback(),
                    ),
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
                            color: AppColors.accent,
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
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Center(
                  child: TextButton(
                    onPressed: () => _confirmDeleteAccount(context),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          AppColors.textSecondary.withValues(alpha: 0.7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Excluir conta',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    Navigator.of(context).pop();

    final passwordController = TextEditingController();
    final needsPassword = authController.usesPasswordProvider;

    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
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
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Excluir conta?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Esta ação é permanente. Seus dados pessoais, selfie, '
                'cashbacks e histórico serão removidos e você não poderá '
                'recuperar a conta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              if (needsPassword) ...[
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirme com sua senha',
                    hintText: 'Senha',
                  ),
                ),
              ] else if (authController.usesGoogleProvider) ...[
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Você precisará confirmar com a conta Google na próxima etapa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Get.back(result: true),
                      child: const Text('Excluir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );

    if (confirmed != true) {
      passwordController.dispose();
      return;
    }

    try {
      await authController.deleteAccount(
        password: needsPassword ? passwordController.text : null,
      );
    } on FirebaseAuthException catch (e) {
      _showDeleteError(_messageForDeleteError(e));
    } catch (_) {
      _showDeleteError(
        'Não foi possível excluir a conta. Tente novamente em alguns instantes.',
      );
    } finally {
      passwordController.dispose();
    }
  }

  String _messageForDeleteError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Senha incorreta. Confira e tente novamente.';
      case 'missing-password':
        return 'Informe a senha para confirmar a exclusão.';
      case 'aborted-by-user':
        return 'Exclusão cancelada. Sua conta permanece ativa.';
      case 'requires-recent-login':
        return 'Por segurança, faça login novamente e tente excluir a conta.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet e tente novamente.';
      default:
        return e.message?.isNotEmpty == true
            ? e.message!
            : 'Não foi possível excluir a conta. Tente novamente.';
    }
  }

  void _showDeleteError(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
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
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Não foi possível excluir',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryThemeColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return const SizedBox(
      height: 56,
      width: 56,
      child: AppBrandIcon(),
    );
  }
}

class _DrawerAvatar extends StatelessWidget {
  const _DrawerAvatar({
    required this.photoBytes,
    required this.photoUrl,
    required this.fallback,
  });

  final Uint8List? photoBytes;
  final String? photoUrl;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    if (photoBytes != null && photoBytes!.isNotEmpty) {
      return Image.memory(
        photoBytes!,
        height: 56,
        width: 56,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }

    final url = photoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        height: 56,
        width: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: 56,
            width: 56,
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            ),
          );
        },
      );
    }

    return fallback;
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
