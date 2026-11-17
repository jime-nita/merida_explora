import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/servicio_biometria.dart';
import '../theme/app_colors.dart';

/// Primera pantalla de la app: pide huella o rostro antes de mostrar los lugares.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ServicioBiometria _servicio = ServicioBiometria();

  bool _verificando = false;
  bool _sinBloqueo = false; // true si el celular no tiene ningún bloqueo
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    // Al abrir la pantalla pedimos la huella automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) => _verificar());
  }

  Future<void> _verificar() async {
    if (_verificando) return;
    setState(() {
      _verificando = true;
      _mensaje = null;
    });

    final resultado = await _servicio.autenticar();
    if (!mounted) return;

    switch (resultado) {
      case ResultadoBiometria.exito:
      // Verificación correcta: pasamos a la lista y no se puede volver al login
        Navigator.pushReplacementNamed(context, AppRoutes.lista);
        return;
      case ResultadoBiometria.fallo:
        _mensaje = 'No pudimos verificar tu identidad. Intenta de nuevo.';
      case ResultadoBiometria.noDisponible:
        _mensaje = 'Tu celular no tiene huella, rostro ni PIN configurado. '
            'Actívalo en Ajustes para proteger tus lugares.';
        _sinBloqueo = true;
      case ResultadoBiometria.error:
        _mensaje = 'La verificación se canceló o falló. Intenta de nuevo.';
    }

    setState(() => _verificando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.rosa,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 72,
                    color: AppColors.rosaProfundo,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Mérida Explora',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verifica tu identidad para entrar',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_mensaje != null) ...[
                  Text(
                    _mensaje!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_verificando)
                  const CircularProgressIndicator(color: AppColors.rosaProfundo)
                else
                  ElevatedButton.icon(
                    onPressed: _verificar,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Desbloquear'),
                  ),
                // Solo si el celular no tiene bloqueo, no hay con qué verificar
                if (_sinBloqueo && !_verificando)
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.lista,
                    ),
                    child: const Text('Continuar sin protección'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}