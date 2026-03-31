import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/colors.dart';

class ProgressIndicatorCustom extends StatelessWidget {
  const ProgressIndicatorCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: primaryThemeColor,
    );
  }
}
