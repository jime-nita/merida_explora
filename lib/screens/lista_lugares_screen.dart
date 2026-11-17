import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/lugar_repositorio.dart';
import '../data/lugar_repositorio_sqlite.dart';
import '../models/lugar.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../widgets/foto_lugar.dart';
import '../widgets/menu_lateral.dart';

/// Pantalla principal: muestra la lista de lugares guardados.
class ListaLugaresScreen extends StatefulWidget {
  const ListaLugaresScreen({super.key});

  @override
  State<ListaLugaresScreen> createState() => _ListaLugaresScreenState();
}

class _ListaLugaresScreenState extends State<ListaLugaresScreen> {
  // Usamos el contrato (LugarRepositorio), no SQLite directamente
  final LugarRepositorio _repositorio = LugarRepositorioSqlite.instancia;

  // Guardamos el Future para que FutureBuilder no lo repita en cada redibujo
  late Future<List<Lugar>> _futuroLugares;

  @override
  void initState() {
    super.initState();
    _futuroLugares = _repositorio.obtenerTodos();
  }

  /// Vuelve a leer los lugares de la base de datos
  void _recargar() {
    setState(() {
      _futuroLugares = _repositorio.obtenerTodos();
    });
  }

  /// Abre el formulario y, si se guardó un lugar, recarga la lista
  Future<void> _abrirFormulario() async {
    final guardado = await Navigator.pushNamed(context, AppRoutes.formulario);
    if (guardado == true) {
      _recargar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Lugar guardado! 🌸')),
      );
    }
  }

  /// Abre el detalle de un lugar. Si allá se borró, recarga la lista
  Future<void> _abrirDetalle(Lugar lugar) async {
    final seBorro = await Navigator.pushNamed(
      context,
      AppRoutes.detalle,
      arguments: lugar,
    );
    if (seBorro == true) {
      _recargar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lugar borrado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis lugares')),
      drawer: const MenuLateral(rutaActual: AppRoutes.lista),
      body: FutureBuilder<List<Lugar>>(
        future: _futuroLugares,
        builder: (context, snapshot) {
          // 1) Cargando: círculo de progreso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.rosaProfundo),
            );
          }

          // 2) Error: mensaje y botón para reintentar
          if (snapshot.hasError) {
            return _vistaError(snapshot.error);
          }

          final lugares = snapshot.data ?? [];

          // 3) Sin lugares todavía: mensaje amable
          if (lugares.isEmpty) {
            return _vistaVacia();
          }

          // 4) Hay lugares: lista de tarjetas
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lugares.length,
            itemBuilder: (context, indice) => _tarjeta(lugares[indice]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        tooltip: 'Agregar lugar',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Tarjeta de un lugar en la lista
  Widget _tarjeta(Lugar lugar) {
    final fecha = DateFormat('dd/MM/yyyy').format(lugar.fecha);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: FotoLugar(lugar: lugar),
        title: Text(
          lugar.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${lugar.categoria} · $fecha'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _abrirDetalle(lugar),
      ),
    );
  }

  /// Pantalla cuando no hay lugares guardados
  Widget _vistaVacia() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined, size: 72, color: AppColors.azulProfundo),
            SizedBox(height: 16),
            Text(
              'Aún no has guardado lugares',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Toca el botón + para agregar el primero'),
          ],
        ),
      ),
    );
  }

  /// Pantalla cuando algo falló al cargar
  Widget _vistaError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _recargar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}