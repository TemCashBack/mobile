import 'package:flutter/material.dart';

abstract class AppColors {
  static const header = Color(0xFF1A1D1A);
  static const headerElevated = Color(0xFF252825);
  static const logoBackground = Color(0xFF000000);
  static const background = Color(0xFFF3F4F2);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const onHeader = Color(0xFFF3F4F2);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);
  static const error = Color(0xFFDC2626);

  /// Destaques de cashback, saldo e status positivo.
  static const accent = Color(0xFF5CB88A);

  /// Verde da marca (logo/ícone) — uso pontual, não em toda a UI.
  static const brand = Color(0xFF0FD35E);

  /// Estado pressionado / tom mais escuro do primário.
  static const primaryDark = Color(0xFF2F7A55);
}

abstract class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
}

abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
