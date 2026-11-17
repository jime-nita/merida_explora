import 'package:flutter/material.dart';
import '../models/lugar.dart';
import '../screens/detalle_lugar_screen.dart';
import '../screens/formulario_lugar_screen.dart';
import '../screens/lista_lugares_screen.dart';
import '../screens/login_screen.dart';

/// Nombres de las pantallas y la forma de llegar a cada una.
/// Así evitamos escribir textos sueltos por toda la app.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String lista = '/';
  static const String formulario = '/nuevo';
  static const String detalle = '/detalle';

  /// Flutter llama a esta función cada vez que se navega a una ruta con nombre
  static Route<dynamic> generarRuta(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case formulario:
        return MaterialPageRoute(
          builder: (_) => const FormularioLugarScreen(),
          settings: settings,
        );
      case detalle:
      // El lugar viaja como argumento al navegar
        final lugar = settings.arguments as Lugar;
        return MaterialPageRoute(
          builder: (_) => DetalleLugarScreen(lugar: lugar),
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