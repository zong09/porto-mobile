import 'package:flutter/material.dart';
import 'colors.dart';

/// Design tokens — typography (see tasks/design-tokens.md).
class AppType {
  static const String fontFamily = 'Anuphan';

  static const TextStyle display = TextStyle(
      fontFamily: fontFamily,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: AppColors.text);
  static const TextStyle heading = TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.text);
  static const TextStyle title = TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.text);
  static const TextStyle body = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.text);
  static const TextStyle label = TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColors.muted);
  static const TextStyle caption = TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.muted);
  static const TextStyle numTabular = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.text,
      fontFeatures: [FontFeature.tabularFigures()]);
}
