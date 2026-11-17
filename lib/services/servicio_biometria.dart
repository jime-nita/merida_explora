import 'package:local_auth/local_auth.dart';

/// Posibles resultados de pedir la huella o el rostro
enum ResultadoBiometria { exito, fallo, noDisponible, error }

/// Se encarga solo de verificar la identidad con huella, rostro o PIN.
class ServicioBiometria {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Dice si el celular tiene alguna forma de verificar (huella, rostro o PIN)
  Future<bool> estaDisponible() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Muestra la ventana del sistema para verificar la identidad
  Future<ResultadoBiometria> autenticar() async {
    if (!await estaDisponible()) return ResultadoBiometria.noDisponible;

    try {
      final autenticado = await _auth.authenticate(
        localizedReason: 'Confirma que eres tú para ver tus lugares',
      );
      return autenticado ? ResultadoBiometria.exito : ResultadoBiometria.fallo;
    } catch (_) {
      // Cancelaron, hubo demasiados intentos, etc.
      return ResultadoBiometria.error;
    }
  }
}