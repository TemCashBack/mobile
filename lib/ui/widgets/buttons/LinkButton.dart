import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/colors.dart';

class LinkButton extends StatelessWidget {
  LinkButton({required this.onPressed, required this.label});
  final GestureTapCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            style: TextStyle(color: defaultTheme),
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
