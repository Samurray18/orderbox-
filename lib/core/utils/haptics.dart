import 'package:flutter/services.dart';

abstract final class AppHaptics {
  static void tap() => HapticFeedback.lightImpact();

  static void select() => HapticFeedback.selectionClick();

  static void success() => HapticFeedback.mediumImpact();

  static void warning() => HapticFeedback.heavyImpact();
}
