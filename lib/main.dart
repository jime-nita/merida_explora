import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

// Punto de entrada: aquí arranca la app
void main() {
  runApp(const MeridaExploraApp());
}

/// Widget raíz: configura el nombre, el tema y las rutas de toda la app
class MeridaExploraApp extends StatelessWidget {
  const MeridaExploraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mérida Explora',
      debugShowCheckedModeBanner: false, // Quita la etiqueta "debug"
      theme: AppTheme.tema,
      initialRoute: AppRoutes.login, // La app inicia pidiendo la huella
      onGenerateRoute: AppRoutes.generarRuta, // Reparte las rutas con nombre
    );
  }
}