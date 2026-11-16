import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

// Punto de entrada: aquí arranca la app
void main() {
  runApp(const MeridaExploraApp());
}

/// Widget raíz: configura el nombre y el tema de toda la app
class MeridaExploraApp extends StatelessWidget {
  const MeridaExploraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mérida Explora',
      debugShowCheckedModeBanner: false, // Quita la etiqueta "debug"
      theme: AppTheme.tema,
      home: const PantallaPrueba(),
    );
  }
}

/// Pantalla temporal para comprobar que el tema pastel funciona.
/// Más adelante la cambiamos por las pantallas reales.
class PantallaPrueba extends StatelessWidget {
  const PantallaPrueba({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mérida Explora')),
      // Menú lateral
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.azulCielo),
              child: Text('Mérida Explora', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.place, color: AppColors.error),
              title: Text('Mis lugares'),
            ),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Hola, Mérida 🌸'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}