import 'package:flutter/material.dart';

/// Единая цветовая палитра приложения: тёмный фон + зелёный акцент.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0F0D);
  static const Color surface = Color(0xFF141B18);
  static const Color surfaceElevated = Color(0xFF1B2420);
  static const Color divider = Color(0xFF232E29);

  static const Color primary = Color(0xFF1FD65F);
  static const Color primaryDark = Color(0xFF17A94B);
  static const Color primaryMuted = Color(0xFF12321F);

  static const Color textPrimary = Color(0xFFF5F7F6);
  static const Color textSecondary = Color(0xFF93A19A);
  static const Color textDisabled = Color(0xFF5A655F);

  static const Color error = Color(0xFFE8574A);
  static const Color warning = Color(0xFFE8B84B);

  static const List<Color> heroGradient = [primary, Color(0xFF0E8A3D)];
}
