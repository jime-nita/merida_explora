import 'package:flutter/material.dart';

/// Paleta pastel de la app.
/// Todos los colores viven aquí, así se cambian desde un solo lugar.
class AppColors {
  AppColors._(); // Evita que alguien cree objetos de esta clase

  static const Color rosa = Color(0xFFF8C8DC);
  static const Color azulCielo = Color(0xFFA9D6F5);
  static const Color mostaza = Color(0xFFF3D98B);
  static const Color menta = Color(0xFFBFE6D3);
  static const Color fondo = Color(0xFFFFF8F2);
  static const Color texto = Color(0xFF4A4458);
  static const Color error = Color(0xFFE57A8E);

  // Versiones más profundas de la paleta, para íconos y elementos que deben destacar
  static const Color rosaProfundo = Color(0xFFC9618A);
  static const Color azulProfundo = Color(0xFF4F8FB8);
  static const Color mostazaProfunda = Color(0xFFB8922A);
}