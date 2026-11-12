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

  // Reference-spec tokens
  static const Color lavenderPill = Color(0xFFEDE6FF);
  static const Color lavenderPillDark = Color(0xFF322058);
  static const Color blobPurple = Color(0xFFB39DFF);
  static const Color blobMint = Color(0xFF7FE3CB);

  /// Icon chip used in headers (lavender tint + primary icon).
  static const Color headerIconTint = Color(0xFFEDE8FF);
  static const Color headerIconTintDark = Color(0xFF2E2350);

  // V2 refined surfaces
  static const Color v2LightTop = Color(0xFFF6F2FD);
  static const Color v2LightBottom = Color(0xFFEDE7FB);
  static const Color v2LightSurface = Color(0xFFFFFFFF);
  static const Color v2DarkTop = Color(0xFF150F2A);
  static const Color v2DarkBottom = Color(0xFF0B0818);
  static const Color v2DarkSurface = Color(0xFF1C1432);
  static const Color v2DarkSurfaceAlt = Color(0xFF241A3F);
  static const Color v2DarkBorder = Color(0xFF332854);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3BF2), Color(0xFF3B1FA8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Reference-spec revenue card: deep purple -> deep indigo.
  static const LinearGradient revenueGradient = LinearGradient(
    colors: [Color(0xFF5B2EE0), Color(0xFF3B1FA8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- v2 premium multi-stop gradients -------------------------------
  static const LinearGradient revenueHeroV2 = LinearGradient(
    colors: [Color(0xFF7A4DFF), Color(0xFF5B2EE0), Color(0xFF2D1375)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.52, 1.0],
  );

  static const LinearGradient mintDeepGradient = LinearGradient(
    colors: [Color(0xFF17D3B2), Color(0xFF079E86), Color(0xFF053B31)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient amberDeepGradient = LinearGradient(
    colors: [Color(0xFFFFC35B), Color(0xFFF2994A), Color(0xFF7A3505)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );

  /// App-wide backdrop: lavender wash (light) / deep aubergine (dark).
  static const LinearGradient backdropLight = LinearGradient(
    colors: [Color(0xFFF0ECFC), Color(0xFFE9E3FA), Color(0xFFF6F3FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backdropDark = LinearGradient(
    colors: [Color(0xFF171026), Color(0xFF120C20), Color(0xFF0B0818)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// V2 backdrop: deeper, more elegant gradient.
  static const LinearGradient v2BackdropLight = LinearGradient(
    colors: [v2LightTop, v2LightBottom, v2LightTop],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient v2BackdropDark = LinearGradient(
    colors: [v2DarkTop, v2DarkBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Subtle vertical fade for gradient cards (adds depth).
  static const LinearGradient cardGloss = LinearGradient(
    colors: [Color(0x22FFFFFF), Color(0x00FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
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
