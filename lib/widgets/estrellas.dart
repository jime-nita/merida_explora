import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fila de 5 estrellas.
/// Si recibe [alCambiar], se pueden tocar para calificar.
/// Si no lo recibe, solo muestra la calificación.
class Estrellas extends StatelessWidget {
  final int calificacion; // De 0 a 5
  final double tamano;
  final ValueChanged<int>? alCambiar;

  const Estrellas({
    super.key,
    required this.calificacion,
    this.tamano = 18,
    this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (indice) {
        final numero = indice + 1;
        final estaLlena = numero <= calificacion;

        final estrella = Icon(
          estaLlena ? Icons.star : Icons.star_border,
          size: tamano,
          color: AppColors.mostazaProfunda,
        );

        // Solo mostrar: no reacciona al toque
        if (alCambiar == null) return estrella;

        // Calificar: al tocar la misma estrella otra vez, se quita la calificación
        return GestureDetector(
          onTap: () => alCambiar!(numero == calificacion ? 0 : numero),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: estrella,
          ),
        );
      }),
    );
  }
}