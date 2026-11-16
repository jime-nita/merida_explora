import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Define el estilo general de la app (barra, botones, campos de texto).
class AppTheme {
  AppTheme._();

  static ThemeData get tema {
    // Colores principales: rosa, azul cielo y mostaza
    const esquema = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.rosa,
      onPrimary: AppColors.texto,
      secondary: AppColors.azulCielo,
      onSecondary: AppColors.texto,
      tertiary: AppColors.mostaza,
      onTertiary: AppColors.texto,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.fondo,
      onSurface: AppColors.texto,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.fondo,
      // Barra superior rosa
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.rosa,
        foregroundColor: AppColors.texto,
        centerTitle: true,
        elevation: 0,
      ),
      // Botón flotante mostaza
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.mostaza,
        foregroundColor: AppColors.texto,
      ),
      // Botones normales azul cielo con esquinas redondeadas
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulCielo,
          foregroundColor: AppColors.texto,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      // Campos de texto blancos y redondeados
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}