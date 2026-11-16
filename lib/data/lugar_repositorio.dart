import '../models/lugar.dart';

/// Error propio para avisar a las pantallas que algo falló con la base de datos
class RepositorioException implements Exception {
  final String mensaje;
  RepositorioException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Contrato: lista lo que se puede hacer con los lugares.
/// Las pantallas usan esto sin saber que por debajo hay SQLite.
abstract class LugarRepositorio {
  Future<int> insertar(Lugar lugar);
  Future<List<Lugar>> obtenerTodos();
  Future<void> eliminar(int id);
}