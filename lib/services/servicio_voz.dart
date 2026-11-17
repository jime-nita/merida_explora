import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'servicio_exception.dart';
import 'servicio_permisos.dart';

/// Se encarga solo del dictado: captura la voz con el micrófono
/// y la convierte en texto.
class ServicioVoz {
  final ServicioPermisos _permisos;
  final SpeechToText _reconocedor = SpeechToText();

  bool _inicializado = false;
  void Function()? _alTerminar; // Se avisa a la pantalla cuando termina de escuchar

  ServicioVoz(this._permisos);

  /// Dice si el micrófono está escuchando ahora mismo
  bool get escuchando => _reconocedor.isListening;

  /// Empieza a escuchar. Cada vez que reconoce palabras llama a [alCambiar].
  Future<void> iniciarDictado({
    required void Function(String texto) alCambiar,
    required void Function() alTerminar,
  }) async {
    await _permisos.exigir(Permission.microphone, 'el micrófono');
    _alTerminar = alTerminar;

    // Se prepara el reconocedor solo la primera vez
    if (!_inicializado) {
      _inicializado = await _reconocedor.initialize(
        onStatus: (estado) {
          // Cuando deja de escuchar, avisamos a la pantalla
          if (estado == 'done' || estado == 'notListening') {
            _alTerminar?.call();
          }
        },
        onError: (error) => _alTerminar?.call(),
      );
    }

    if (!_inicializado) {
      throw ServicioException(
        'El dictado por voz no está disponible en este dispositivo. '
            'Puedes escribir el texto a mano.',
      );
    }

    await _reconocedor.listen(
      onResult: (SpeechRecognitionResult resultado) {
        alCambiar(resultado.recognizedWords); // Texto reconocido hasta ahora
      },
      localeId: await _buscarIdiomaEspanol(),
      listenFor: const Duration(seconds: 60), // Máximo 1 minuto de dictado
      pauseFor: const Duration(seconds: 5), // Se detiene si hay 5 s de silencio
    );
  }

  /// Detiene el dictado
  Future<void> detener() => _reconocedor.stop();

  /// Busca español de México; si no hay, otro español; si no, el del sistema
  Future<String?> _buscarIdiomaEspanol() async {
    final idiomas = await _reconocedor.locales();
    final espanol =
    idiomas.where((i) => i.localeId.startsWith('es')).toList();
    if (espanol.isEmpty) return null;

    for (final idioma in espanol) {
      if (idioma.localeId.replaceAll('-', '_') == 'es_MX') {
        return idioma.localeId;
      }
    }
    return espanol.first.localeId;
  }
}