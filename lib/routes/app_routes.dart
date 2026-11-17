import 'package:flutter/material.dart';
import '../screens/formulario_lugar_screen.dart';
import '../screens/lista_lugares_screen.dart';

/// Nombres de las pantallas y la forma de llegar a cada una.
/// Así evitamos escribir textos sueltos por toda la app.
class AppRoutes {
  AppRoutes._();

  // Nombres de las rutas (más adelante agregamos el detalle)
  static const String lista = '/';
  static const String formulario = '/nuevo';

  /// Flutter llama a esta función cada vez que se navega a una ruta con nombre
  static Route<dynamic> generarRuta(RouteSettings settings) {
    switch (settings.name) {
      case formulario:
        return MaterialPageRoute(
          builder: (_) => const FormularioLugarScreen(),
          settings: settings,
        );
      case lista:
      default:
        return MaterialPageRoute(
          builder: (_) => const ListaLugaresScreen(),
          settings: settings,
        );
    }
  }
}