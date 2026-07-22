import 'package:flutter/material.dart';

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
      leading: leading,
      title: Image.asset(
        'lib/ui/assets/logo.png',
        height: 36,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
