// lib/presentation/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/theme/app_Theme.dart';

// ==================== Theme State ====================
class ThemeState {
  final bool isDarkMode;
  final ThemeData themeData;

  ThemeState({
    this.isDarkMode = false,
    ThemeData? themeData,
  }) : themeData = themeData ?? AppTheme.lightTheme;

  ThemeState copyWith({
    bool? isDarkMode,
    ThemeData? themeData,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeData: themeData ?? this.themeData,
    );
  }

  // تبديل الثيم
  ThemeState toggleTheme() {
    final newIsDark = !isDarkMode;
    return ThemeState(
      isDarkMode: newIsDark,
      themeData: newIsDark ? AppTheme.darkTheme : AppTheme.lightTheme,
    );
  }
}

// ==================== Theme Notifier ====================
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState());

  // تبديل الثيم
  void toggleTheme() {
    state = state.toggleTheme();
  }

  // تعيين الثيم الفاتح
  void setLightTheme() {
    state = state.copyWith(
      isDarkMode: false,
      themeData: AppTheme.lightTheme,
    );
  }

  // تعيين الثيم الداكن
  void setDarkTheme() {
    state = state.copyWith(
      isDarkMode: true,
      themeData: AppTheme.darkTheme,
    );
  }

  // تبديل الثيم مع حفظ في التخزين المحلي
  Future<void> toggleThemeWithSave() async {
    toggleTheme();
    // حفظ في SharedPreferences
    // await _saveThemePreference(state.isDarkMode);
  }
}

// ==================== Theme Provider ====================
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// ==================== Theme Providers المساعدة ====================
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDarkMode;
});

final currentThemeProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider).themeData;
});

final primaryColorProvider = Provider<Color>((ref) {
  return ref.watch(themeProvider).themeData.primaryColor;
});