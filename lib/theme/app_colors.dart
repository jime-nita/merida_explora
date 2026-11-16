import 'package:flutter/material.dart';

/// Paleta pastel de la app.
/// Todos los colores viven aquí, así se cambian desde un solo lugar.
class AppColors {
  AppColors._(); // Evita que alguien cree objetos de esta clase

  static const Color rosa = Color(0xFFF8C8DC); // Rosa pastel
  static const Color azulCielo = Color(0xFFA9D6F5); // Azul cielo pastel
  static const Color mostaza = Color(0xFFF3D98B); // Amarillo mostaza pastel
  static const Color menta = Color(0xFFBFE6D3); // Verde menta (mensajes de éxito)
  static const Color fondo = Color(0xFFFFF8F2); // Crema de fondo
  static const Color texto = Color(0xFF4A4458); // Gris oscuro, se lee bien sobre pasteles
  static const Color error = Color(0xFFE57A8E); // Rosa fuerte para errores
}