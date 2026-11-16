import 'dart:io';
import 'package:flutter/material.dart';
import '../models/lugar.dart';
import '../theme/app_colors.dart';

/// Muestra la foto de un lugar con animación Hero.
/// Se usa en la lista (pequeña) y en el detalle (grande).
class FotoLugar extends StatelessWidget {
  final Lugar lugar;
  final double ancho;
  final double alto;

  const FotoLugar({
    super.key,
    required this.lugar,
    this.ancho = 56,
    this.alto = 56,
  });

  @override
  Widget build(BuildContext context) {
    final ruta = lugar.rutaFoto;

    // Si hay foto la mostramos; si no (o si falla al cargar), mostramos un ícono
    final Widget contenido = ruta == null
        ? _marcador()
        : Image.file(
      File(ruta),
      width: ancho,
      height: alto,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _marcador(),
    );

    return Hero(
      // La misma etiqueta en lista y detalle hace que la imagen "vuele"
      tag: 'foto_lugar_${lugar.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: contenido,
      ),
    );
  }

  /// Cuadro azul con un ícono, para lugares sin foto
  Widget _marcador() {
    return Container(
      width: ancho,
      height: alto,
      color: AppColors.azulCielo,
      child: const Icon(
        Icons.photo_camera_outlined,
        color: AppColors.azulProfundo,
      ),
    );
  }
}