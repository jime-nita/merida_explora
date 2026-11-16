import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/lugar.dart';
import 'lugar_repositorio.dart';

/// Guarda los lugares en una base de datos SQLite dentro del celular.
class LugarRepositorioSqlite implements LugarRepositorio {
  // Un solo objeto para toda la app (así no se abre la base varias veces)
  LugarRepositorioSqlite._();
  static final LugarRepositorioSqlite instancia = LugarRepositorioSqlite._();

  static const String _nombreBd = 'merida_explora.db';
  static const String _tabla = 'lugares';

  Database? _bd;

  /// Abre la base de datos. Si no existe, la crea con su tabla.
  Future<Database> _obtenerBd() async {
    if (_bd != null) return _bd!;

    final ruta = p.join(await getDatabasesPath(), _nombreBd);
    _bd = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tabla (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            categoria TEXT NOT NULL,
            opinion TEXT NOT NULL,
            fecha TEXT NOT NULL,
            metadatos TEXT NOT NULL
          )
        ''');
      },
    );
    return _bd!;
  }

  @override
  Future<int> insertar(Lugar lugar) async {
    try {
      final bd = await _obtenerBd();
      return await bd.insert(_tabla, lugar.toMap());
    } catch (e) {
      // Si algo falla, avisamos con un mensaje claro en vez de que la app se cierre
      throw RepositorioException('No se pudo guardar el lugar. Intenta de nuevo.');
    }
  }

  @override
  Future<List<Lugar>> obtenerTodos() async {
    try {
      final bd = await _obtenerBd();
      // Los más nuevos primero
      final filas = await bd.query(_tabla, orderBy: 'fecha DESC');
      return filas.map((fila) => Lugar.fromMap(fila)).toList();
    } catch (e) {
      throw RepositorioException('No se pudieron cargar tus lugares.');
    }
  }

  @override
  Future<void> eliminar(int id) async {
    try {
      final bd = await _obtenerBd();
      await bd.delete(_tabla, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw RepositorioException('No se pudo borrar el lugar.');
    }
  }
}