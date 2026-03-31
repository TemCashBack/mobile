import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/colors.dart';

class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.onPressed, required this.label});
  final GestureTapCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          overlayColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            style: TextStyle(color: primaryThemeColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
