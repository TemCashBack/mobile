import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/widgets/app_logo.dart';

class AppLogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppLogoAppBar({
    super.key,
    this.actions,
    this.leading,
  });

  final List<Widget>? actions;
  final Widget? leading;

  static Widget menuButton(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.logoBackground,
      foregroundColor: AppColors.onHeader,
      leading: leading,
      title: const AppLogo(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
