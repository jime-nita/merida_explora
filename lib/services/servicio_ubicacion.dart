import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'servicio_exception.dart';
import 'servicio_permisos.dart';

/// Se encarga solo de conseguir la posición GPS actual.
class ServicioUbicacion {
  final ServicioPermisos _permisos;

  ServicioUbicacion(this._permisos);

  /// Devuelve la posición actual (latitud y longitud)
  Future<Position> obtenerPosicionActual() async {
    await _permisos.exigir(Permission.locationWhenInUse, 'la ubicación');

    // Aunque haya permiso, el GPS del celular puede estar apagado
    final gpsEncendido = await Geolocator.isLocationServiceEnabled();
    if (!gpsEncendido) {
      throw ServicioException(
        'El GPS está apagado. Enciéndelo para guardar la ubicación.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15), // No esperar para siempre
        ),
      );
    } catch (e) {
      throw ServicioException('No se pudo obtener tu ubicación. Intenta de nuevo.');
    }
  }
}