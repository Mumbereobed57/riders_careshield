import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// Helper function to get the appropriate SystemUiOverlayStyle
/// based on the AppBar background color and transparency
SystemUiOverlayStyle getSystemUiOverlayStyle({
  Color? statusBarColor,
  bool isTransparent = false,
  Brightness? statusBarIconBrightness,
}) {
  final effectiveStatusBarColor = isTransparent
      ? Colors.transparent
      : statusBarColor ?? AppColors.surface;

  final effectiveIconBrightness = statusBarIconBrightness ??
      (isTransparent || _isLightColor(effectiveStatusBarColor)
          ? Brightness.dark
          : Brightness.light);

  return SystemUiOverlayStyle(
    statusBarColor: effectiveStatusBarColor,
    statusBarIconBrightness: effectiveIconBrightness,
    statusBarBrightness: effectiveIconBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark, // For iOS compatibility
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}

/// Helper function to determine if a color is light or dark
bool _isLightColor(Color color) {
  final luminance = color.computeLuminance();
  return luminance > 0.5;
}

ThemeData buildAppTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryBlue,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryGreen,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSurface: AppColors.text,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surface,
      iconTheme: const IconThemeData(color: AppColors.text),
      titleTextStyle: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      systemOverlayStyle: getSystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.text.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.text.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 2,
        shadowColor: AppColors.primaryBlue.withOpacity(0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primaryBlue.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
