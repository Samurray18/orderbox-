import 'package:flutter/material.dart';

/// Central colour palette. Widgets must never hard-code colours.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF5B2EE0);
  static const Color primaryBright = Color(0xFF7A4DFF);
  static const Color indigoDeep = Color(0xFF2B1173);
  static const Color mint = Color(0xFF12C2A4);
  static const Color mintDeep = Color(0xFF0A9C84);
  static const Color amber = Color(0xFFF5A524);
  static const Color red = Color(0xFFE5484D);
  static const Color blue = Color(0xFF2F80ED);
  static const Color orange = Color(0xFFF2994A);
  static const Color green = Color(0xFF16A34A);
  static const Color grey = Color(0xFF8A8799);

  // Light surfaces
  static const Color lightBackground = Color(0xFFF7F5FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF2EEFB);
  static const Color lightOutline = Color(0xFFE8E2F3);
  static const Color lightText = Color(0xFF1A1433);
  static const Color lightTextSecondary = Color(0xFF756F89);

  // Dark surfaces (designed, not inverted)
  static const Color darkBackground = Color(0xFF0C0917);
  static const Color darkSurface = Color(0xFF161025);
  static const Color darkSurfaceAlt = Color(0xFF211936);
  static const Color darkOutline = Color(0xFF302747);
  static const Color darkText = Color(0xFFF6F3FF);
  static const Color darkTextSecondary = Color(0xFFA49CB9);

  // Accent variants for dark mode
  static const Color primaryDark = Color(0xFF9B7BFF);
  static const Color mintDark = Color(0xFF2ED9BB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3BF2), Color(0xFF4B22C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF5B2EE0), Color(0xFF2B1173)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF17D3B2), Color(0xFF079E86)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFFC35B), Color(0xFFF08C1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFFF7A7F), Color(0xFFD9363E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Colourful avatar gradients, picked deterministically by customer name.
  static const List<List<Color>> avatarGradients = [
    [Color(0xFF7A4DFF), Color(0xFF4B22C7)],
    [Color(0xFF17D3B2), Color(0xFF079E86)],
    [Color(0xFFFFB65C), Color(0xFFF08C1F)],
    [Color(0xFF6AA9FF), Color(0xFF2F80ED)],
    [Color(0xFFFF8BA3), Color(0xFFE5484D)],
    [Color(0xFFB08BFF), Color(0xFF6B3DF5)],
  ];
}
