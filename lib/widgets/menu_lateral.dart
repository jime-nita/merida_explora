import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

/// Menú lateral (Drawer) de toda la app.
class MenuLateral extends StatelessWidget {
  /// Ruta de la pantalla actual, para resaltar su opción
  final String rutaActual;

  const MenuLateral({super.key, required this.rutaActual});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.azulCielo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.explore, size: 40, color: AppColors.azulProfundo),
                SizedBox(height: 8),
                Text(
                  'Mérida Explora',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('Tus lugares favoritos'),
              ],
            ),
          ),
          _opcion(
            context,
            icono: Icons.place,
            texto: 'Mis lugares',
            ruta: AppRoutes.lista,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.azulProfundo),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              showAboutDialog(
                context: context,
                applicationName: 'Mérida Explora',
                applicationVersion: '1.0.0',
                children: const [
                  Text('Guarda los lugares que descubres en Mérida con '
                      'foto, tu opinión y su ubicación.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Crea una opción del menú. Si es la pantalla actual, se resalta en rosa.
  Widget _opcion(
      BuildContext context, {
        required IconData icono,
        required String texto,
        required String ruta,
      }) {
    final estaSeleccionada = ruta == rutaActual;

    return ListTile(
      leading: Icon(icono, color: AppColors.rosaProfundo),
      title: Text(texto),
      selected: estaSeleccionada,
      selectedTileColor: AppColors.rosa,
      selectedColor: AppColors.texto,
      onTap: () {
        Navigator.pop(context); // Cierra el menú
        // Solo navega si no estamos ya en esa pantalla
        if (!estaSeleccionada) {
          Navigator.pushReplacementNamed(context, ruta);
        }
      },
    );
  }
}