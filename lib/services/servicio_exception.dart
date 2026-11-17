/// Error propio de los servicios (cámara, GPS, voz...).
/// Lleva un mensaje listo para mostrarle al usuario.
class ServicioException implements Exception {
  final String mensaje;

  /// Si es true, la pantalla puede ofrecer un botón "Abrir ajustes"
  final bool puedeAbrirAjustes;

  ServicioException(this.mensaje, {this.puedeAbrirAjustes = false});

  @override
  String toString() => mensaje;
}