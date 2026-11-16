import 'package:flutter/material.dart';
import '../screens/lista_lugares_screen.dart';

/// Nombres de las pantallas y la forma de llegar a cada una.
/// Así evitamos escribir textos sueltos por toda la app.
class AppRoutes {
  AppRoutes._();

  // Nombres de las rutas (más adelante agregamos detalle y formulario)
  static const String lista = '/';

  /// Flutter llama a esta función cada vez que se navega a una ruta con nombre
  static Route<dynamic> generarRuta(RouteSettings settings) {
    switch (settings.name) {
      case lista:
      default:
        return MaterialPageRoute(
          builder: (_) => const ListaLugaresScreen(),
          settings: settings,
        );
    }
  }
}