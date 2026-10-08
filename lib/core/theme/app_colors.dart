import 'package:flutter/material.dart';

/// Use these instead of hardcoded Colors.white / Color(0xFFF8FAFC) etc.
/// They automatically adapt to light/dark theme.
extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Main page background
  Color get bgColor => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  /// Card / container background
  Color get cardBg => isDark ? const Color(0xFF1E293B) : Colors.white;

  /// Slightly elevated surface (tab bars, inputs)
  Color get surfaceBg => isDark ? const Color(0xFF263548) : const Color(0xFFF1F5F9);

  /// Primary text color
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF0F172A);

  /// Secondary / hint text
  Color get textSecondary => isDark ? Colors.white60 : const Color(0xFF737373);

  /// Divider
  Color get divider => isDark ? Colors.white12 : Colors.black12;

  /// Shadow (use withOpacity on top)
  Color get shadow => isDark ? Colors.black : Colors.black;
}
