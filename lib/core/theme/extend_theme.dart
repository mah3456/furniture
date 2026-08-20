// lib/core/theme/extended_theme.dart

import 'package:flutter/material.dart';

import 'app_Colors.dart';
import 'app_Theme.dart';


// ==================== إضافات للثيم ====================
extension ThemeExtensions on ThemeData {
  // الحصول على ألوان مخصصة
  Color get primaryColorLight => AppColors.primaryLight;
  Color get primaryColorDark => AppColors.primaryDark;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get errorColor => AppColors.error;

  // تدرجات

  // ظلال البطاقات
  List<BoxShadow> get cardShadow => AppColors.cardShadow;
  List<BoxShadow> get buttonShadow => AppColors.buttonShadow;

  // ألوان الخلفية
  Color get backgroundCard => AppColors.backgroundCard;
  Color get backgroundDark => AppColors.backgroundDark;

  // ألوان النصوص
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textHint => AppColors.textHint;
}

// ==================== إضافات للـ BuildContext ====================
extension BuildContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => AppTheme.isDarkMode(this);

  // ألوان مخصصة
  Color get primaryColorLight => AppColors.primaryLight;
  Color get primaryColorDark => AppColors.primaryDark;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get errorColor => AppColors.error;


  // ظلال
  List<BoxShadow> get cardShadow => AppColors.cardShadow;
  List<BoxShadow> get buttonShadow => AppColors.buttonShadow;

  // ألوان النصوص
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textHint => AppColors.textHint;

  // ألوان الخلفية
  Color get background => AppColors.background;
  Color get backgroundCard => AppColors.backgroundCard;

  // ألوان الحالة
  Color get success => AppColors.success;
  Color get error => AppColors.error;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;
}