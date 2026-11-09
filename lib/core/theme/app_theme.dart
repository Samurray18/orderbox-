import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData light(Locale locale) => _build(Brightness.light, locale);

  static ThemeData dark(Locale locale) => _build(Brightness.dark, locale);

  static ThemeData _build(Brightness brightness, Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    final font = isArabic ? 'Cairo' : 'Poppins';
    final fallback = isArabic ? const ['Poppins'] : const ['Cairo'];
    final dark = brightness == Brightness.dark;
    final scheme = _scheme(brightness);
    final textTheme = _textTheme(scheme, font);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: font,
      fontFamilyFallback: fallback,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: scheme.outlineVariant,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 64,
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark
            ? AppColors.darkSurfaceAlt.withValues(alpha: 0.62)
            : AppColors.lightSurfaceAlt.withValues(alpha: 0.75),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 16),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.primary,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: _fieldBorder(scheme.outlineVariant),
        enabledBorder: _fieldBorder(scheme.outlineVariant),
        focusedBorder: _fieldBorder(scheme.primary, width: 1.6),
        errorBorder: _fieldBorder(scheme.error),
        focusedErrorBorder: _fieldBorder(scheme.error, width: 1.6),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.35),
          minimumSize: const Size(0, 54),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, 52),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primary,
        labelStyle: textTheme.labelMedium,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF2A2142) : const Color(0xFF241A43),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppColors.mintDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        elevation: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surfaceContainerLowest,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        dragHandleSize: const Size(42, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 640),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.12),
        circularTrackColor: scheme.primary.withValues(alpha: 0.12),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF2A2142) : const Color(0xFF241A43),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _AppPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _AppPageTransitionsBuilder(),
          TargetPlatform.linux: _AppPageTransitionsBuilder(),
          TargetPlatform.windows: _AppPageTransitionsBuilder(),
          TargetPlatform.macOS: _AppPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ColorScheme _scheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );

    if (dark) {
      return base.copyWith(
        primary: AppColors.primaryDark,
        onPrimary: const Color(0xFF1B0B45),
        primaryContainer: const Color(0xFF2E1A6B),
        onPrimaryContainer: const Color(0xFFEDE6FF),
        secondary: AppColors.mintDark,
        onSecondary: const Color(0xFF00251F),
        secondaryContainer: const Color(0xFF0F3D36),
        onSecondaryContainer: const Color(0xFFB7F5E9),
        tertiary: const Color(0xFFFFC35B),
        onTertiary: const Color(0xFF3B2500),
        tertiaryContainer: const Color(0xFF4A3000),
        onTertiaryContainer: const Color(0xFFFFE0A6),
        error: const Color(0xFFFF6B6B),
        onError: const Color(0xFF40000A),
        errorContainer: const Color(0xFF4A1118),
        onErrorContainer: const Color(0xFFFFD9DB),
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.darkTextSecondary,
        surfaceContainerLowest: AppColors.darkSurface,
        surfaceContainerLow: const Color(0xFF130E20),
        surfaceContainer: const Color(0xFF1A1329),
        surfaceContainerHigh: AppColors.darkSurfaceAlt,
        surfaceContainerHighest: const Color(0xFF2A2142),
        outline: AppColors.darkOutline,
        outlineVariant: const Color(0xFF261F38),
        inverseSurface: const Color(0xFFEDE8FA),
        onInverseSurface: const Color(0xFF1A1433),
        inversePrimary: AppColors.primary,
        shadow: Colors.black,
        scrim: Colors.black,
        surfaceTint: Colors.transparent,
      );
    }

    return base.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEDE6FF),
      onPrimaryContainer: const Color(0xFF280B75),
      secondary: AppColors.mint,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD5F7F1),
      onSecondaryContainer: const Color(0xFF003B32),
      tertiary: AppColors.amber,
      onTertiary: const Color(0xFF3B2500),
      tertiaryContainer: const Color(0xFFFFF0D2),
      onTertiaryContainer: const Color(0xFF4A3000),
      error: AppColors.red,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFE3E4),
      onErrorContainer: const Color(0xFF5B0A0E),
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightText,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surfaceContainerLowest: AppColors.lightSurface,
      surfaceContainerLow: const Color(0xFFFCFAFF),
      surfaceContainer: const Color(0xFFF8F5FE),
      surfaceContainerHigh: const Color(0xFFF2EEFB),
      surfaceContainerHighest: const Color(0xFFEBE5F7),
      outline: AppColors.lightOutline,
      outlineVariant: const Color(0xFFF0EBF9),
      inverseSurface: const Color(0xFF241A43),
      onInverseSurface: const Color(0xFFF7F4FF),
      inversePrimary: AppColors.primaryDark,
      shadow: AppColors.primary,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );
  }

  static TextTheme _textTheme(ColorScheme scheme, String font) {
    TextStyle style(
      double size,
      FontWeight weight, {
      double height = 1.35,
      double spacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: font,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: color ?? scheme.onSurface,
      );
    }

    return TextTheme(
      displayLarge: style(42, FontWeight.w700, height: 1.12, spacing: -1.2),
      displayMedium: style(36, FontWeight.w700, height: 1.15, spacing: -1),
      displaySmall: style(30, FontWeight.w700, height: 1.18, spacing: -0.6),
      headlineLarge: style(28, FontWeight.w700, height: 1.2, spacing: -0.4),
      headlineMedium: style(24, FontWeight.w700, height: 1.22, spacing: -0.3),
      headlineSmall: style(20, FontWeight.w600, height: 1.25),
      titleLarge: style(18, FontWeight.w600, height: 1.3),
      titleMedium: style(16, FontWeight.w600, height: 1.35),
      titleSmall: style(14, FontWeight.w600, height: 1.4),
      bodyLarge: style(16, FontWeight.w400, height: 1.55),
      bodyMedium: style(14, FontWeight.w400, height: 1.5),
      bodySmall: style(12, FontWeight.w400, height: 1.45),
      labelLarge: style(14, FontWeight.w600, height: 1.25),
      labelMedium: style(12, FontWeight.w500, height: 1.25, spacing: 0.1),
      labelSmall: style(11, FontWeight.w500, height: 1.2, spacing: 0.2),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamily: font,
    );
  }
}

class _AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const _AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
