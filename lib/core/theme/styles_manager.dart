import 'package:flutter/material.dart';

import 'font_manager.dart';

// ─── Base builder (unchanged — used internally) ───────────────────────────────
TextStyle _buildStyle(double fontSize, FontWeight fontWeight, Color color,
    {double height = 1.5}) {
  return TextStyle(
    fontSize: fontSize,
    fontFamily: FontConstants.fontFamily,
    color: color,
    fontWeight: fontWeight,
    height: height,
  );
}

// ─── Named styles — always Cairo, consistent scale ───────────────────────────

/// Light  w300  — captions, hints
TextStyle getLightStyle({double fontSize = FontSize.s12, required Color color}) =>
    _buildStyle(fontSize, FontWeightManager.light, color);

/// Regular  w400  — body copy
TextStyle getRegularStyle({double fontSize = FontSize.s14, required Color color}) =>
    _buildStyle(fontSize, FontWeightManager.regular, color, height: 1.6);

/// Medium  w500  — secondary labels, sub-titles
TextStyle getMediumStyle({double fontSize = FontSize.s15, required Color color}) =>
    _buildStyle(fontSize, FontWeightManager.medium, color, height: 1.5);

/// SemiBold  w600  — titles, card headers
TextStyle getSemiBoldStyle({double fontSize = FontSize.s16, required Color color}) =>
    _buildStyle(fontSize, FontWeightManager.semiBold, color, height: 1.4);

/// Bold  w700  — screen titles, strong emphasis
TextStyle getBoldStyle({double fontSize = FontSize.s16, required Color color}) =>
    _buildStyle(fontSize, FontWeightManager.bold, color, height: 1.4);
