import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'servicio_exception.dart';
import 'servicio_permisos.dart';

/// Se encarga solo de conseguir fotos: con la cámara o desde la galería.
class ServicioImagen {
  final ServicioPermisos _permisos; // Se lo damos al crear el servicio
  final ImagePicker _selector = ImagePicker();

  ServicioImagen(this._permisos);

  /// Abre la cámara y devuelve la ruta de la foto (o null si canceló)
  Future<String?> tomarFoto() async {
    await _permisos.exigir(Permission.camera, 'la cámara');
    return _obtener(ImageSource.camera);
  }

  /// Abre la galería y devuelve la ruta de la foto (o null si canceló).
  /// La galería de Android no necesita permiso: usa el selector del sistema.
  Future<String?> elegirDeGaleria() => _obtener(ImageSource.gallery);

  Future<String?> _obtener(ImageSource origen) async {
    try {
      final archivo = await _selector.pickImage(
        source: origen,
        imageQuality: 80, // Comprime un poco para ocupar menos espacio
        maxWidth: 1600,
      );
      if (archivo == null) return null; // La persona canceló
      return await _guardarEnCarpetaDeLaApp(archivo);
    } catch (e) {
      throw ServicioException('No se pudo obtener la imagen. Intenta de nuevo.');
    }
  }

  /// Copia la foto a la carpeta propia de la app para que no se pierda
  Future<String> _guardarEnCarpetaDeLaApp(XFile archivo) async {
    final carpeta = await getApplicationDocumentsDirectory();
    final nombre =
        'foto_${DateTime.now().millisecondsSinceEpoch}${p.extension(archivo.path)}';
    final destino = p.join(carpeta.path, nombre);
    await File(archivo.path).copy(destino);
    return destino;
  }
}