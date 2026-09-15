import 'package:flutter/material.dart';

class AppThemeColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color grey100 = Color(0xFFFAFAFA);
  static const Color grey200 = Color(0xFFEFEFEF);
  static const Color grey300 = Color(0xFFDBDBDB);
  static const Color grey500 = Color(0xFF8E8E8E);
  static const Color grey900 = Color(0xFF262626);

  static const Color darkGrey100 = Color(0xFF121212);
  static const Color darkGrey200 = Color(0xFF1E1E1E);
  static const Color darkGrey300 = Color(0xFF2C2C2C);
  static const Color darkGrey500 = Color(0xFFA0A0A0);

  static const Color instaBlue = Color(0xFF0095F6);
  static const Color softBlue = Color(0xFFE0F1FF);
  static const Color darkSoftBlue = Color(0xFF002D4F);

  static const Color destructive = Color(0xFFED4956);
  static const Color success = Color(0xFF58C322);
  static const Color warning = Color(0xFFFFD100);

  static const Color forestGreen = Color(0xFF1B4332);
  static const Color forestGreenGlow = Color(0xFF2D6A4F);
  static const Color sunsetAmber = Color(0xFFEE921A);
}

class AppTheme {
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusS = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusM = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusL = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(24));

  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, height: 1.123, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, height: 1.156, letterSpacing: 0),
    displaySmall: TextStyle(fontSize: 36, height: 1.222, letterSpacing: 0),
    headlineLarge: TextStyle(fontSize: 32, height: 1.25, letterSpacing: 0),
    headlineMedium: TextStyle(
        fontSize: 28, height: 1.286, letterSpacing: 0, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontSize: 24, height: 1.333, letterSpacing: 0),
    titleLarge: TextStyle(
        fontSize: 22, height: 1.273, letterSpacing: 0, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(
        fontSize: 18, height: 1.333, letterSpacing: 0.1, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(
        fontSize: 14, height: 1.429, letterSpacing: 0.1, fontWeight: FontWeight.w500),
    bodyLarge:
        TextStyle(fontSize: 16, height: 1.5, letterSpacing: 0.5),
    bodyMedium:
        TextStyle(fontSize: 14, height: 1.429, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, height: 1.333, letterSpacing: 0.4),
    labelLarge: TextStyle(
        fontSize: 14, height: 1.429, letterSpacing: 0.1, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(
        fontSize: 12, height: 1.333, letterSpacing: 0.5, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(
        fontSize: 11, height: 1.455, letterSpacing: 0.5, fontWeight: FontWeight.w500),
  );

  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark
        ? const ColorScheme.dark(
            primary: AppThemeColors.instaBlue,
            onPrimary: AppThemeColors.white,
            primaryContainer: AppThemeColors.darkSoftBlue,
            onPrimaryContainer: AppThemeColors.white,
            secondary: AppThemeColors.darkGrey500,
            onSecondary: AppThemeColors.white,
            tertiary: AppThemeColors.forestGreenGlow,
            onTertiary: AppThemeColors.white,
            surface: AppThemeColors.black,
            onSurface: AppThemeColors.white,
            surfaceContainerHighest: AppThemeColors.darkGrey200,
            onSurfaceVariant: AppThemeColors.darkGrey500,
            error: AppThemeColors.destructive,
            onError: AppThemeColors.white,
            outline: AppThemeColors.darkGrey300,
          )
        : const ColorScheme.light(
            primary: AppThemeColors.instaBlue,
            onPrimary: AppThemeColors.white,
            primaryContainer: AppThemeColors.softBlue,
            onPrimaryContainer: AppThemeColors.black,
            secondary: AppThemeColors.grey500,
            onSecondary: AppThemeColors.white,
            tertiary: AppThemeColors.forestGreen,
            onTertiary: AppThemeColors.white,
            surface: AppThemeColors.white,
            onSurface: AppThemeColors.black,
            surfaceContainerHighest: AppThemeColors.grey100,
            onSurfaceVariant: AppThemeColors.grey500,
            error: AppThemeColors.destructive,
            onError: AppThemeColors.white,
            outline: AppThemeColors.grey300,
          );

    final textTheme = _lightTextTheme.apply(
      bodyColor: isDark ? AppThemeColors.white : AppThemeColors.grey900,
      displayColor: isDark ? AppThemeColors.white : AppThemeColors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: null,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radiusL,
          side: BorderSide(color: scheme.outline.withAlpha(38)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppThemeColors.darkGrey200 : AppThemeColors.white,
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: radiusM,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusM,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusM,
          borderSide: const BorderSide(color: AppThemeColors.instaBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusM,
          borderSide:
              const BorderSide(color: AppThemeColors.destructive, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radiusM),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radiusM),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(borderRadius: radiusM),
          side: BorderSide(color: scheme.primary.withAlpha(153)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: radiusL),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withAlpha(26),
        thickness: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withAlpha(26),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: radiusXl),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppThemeColors.darkGrey200 : AppThemeColors.grey900,
        contentTextStyle: TextStyle(
          color: isDark ? AppThemeColors.white : AppThemeColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: radiusM),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}