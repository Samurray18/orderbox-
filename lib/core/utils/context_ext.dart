import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isCompact => MediaQuery.sizeOf(this).width < 360;

  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
}
