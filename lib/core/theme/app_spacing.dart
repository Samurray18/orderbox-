import 'package:flutter/widgets.dart';

/// 4 / 8 / 12 / 16 / 24 spacing scale.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsetsGeometry page =
      EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0);
  static const EdgeInsetsGeometry pageAll = EdgeInsetsDirectional.all(20);
  static const EdgeInsetsGeometry card = EdgeInsetsDirectional.all(16);

  /// Extra room so content is never hidden behind the floating navigation.
  static const double bottomNavClearance = 118;
}

abstract final class AppSizes {
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double avatarSm = 36;
  static const double avatar = 48;
  static const double avatarLg = 64;
  static const double fab = 60;
  static const double navHeight = 70;
  static const double minTouch = 48;
  static const double dot = 6;
  static const double hairline = 1;
  static const double border = 1.4;
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
}
