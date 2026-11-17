import 'package:permission_handler/permission_handler.dart';
import 'servicio_exception.dart';

/// Se encarga solo de pedir permisos al usuario.
/// Los demás servicios lo usan, así no repetimos código.
class ServicioPermisos {
  /// Pide un permiso. Si ya lo tenemos, sigue sin molestar.
  /// Si el usuario lo niega, lanza un ServicioException con un mensaje claro.
  Future<void> exigir(Permission permiso, String nombreAmigable) async {
    var estado = await permiso.status;
    if (estado.isGranted) return;

    // Mostramos el cuadro de Android para pedir el permiso
    estado = await permiso.request();
    if (estado.isGranted) return;

    if (estado.isPermanentlyDenied) {
      // El usuario marcó "No volver a preguntar": solo se arregla en Ajustes
      throw ServicioException(
        'Negaste el permiso de $nombreAmigable. '
            'Actívalo en Ajustes para poder usarlo.',
        puedeAbrirAjustes: true,
      );
    }

    throw ServicioException(
      'Necesitamos permiso para usar $nombreAmigable.',
    );
  }

  /// Abre la pantalla de ajustes de la app en el celular
  Future<bool> abrirAjustes() => openAppSettings();
}