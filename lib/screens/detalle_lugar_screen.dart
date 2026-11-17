import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/lugar_repositorio.dart';
import '../data/lugar_repositorio_sqlite.dart';
import '../models/lugar.dart';
import '../theme/app_colors.dart';
import '../widgets/foto_lugar.dart';
import '../widgets/estrellas.dart';

/// Muestra toda la información de un lugar: foto, opinión y mapa.
class DetalleLugarScreen extends StatelessWidget {
  final Lugar lugar;

  const DetalleLugarScreen({super.key, required this.lugar});

  /// Pregunta si de verdad quiere borrar y, si dice que sí, lo elimina
  Future<void> _confirmarBorrado(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar este lugar?'),
        content: Text('Se eliminará "${lugar.nombre}" de tu lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmado != true || lugar.id == null) return;

    try {
      await LugarRepositorioSqlite.instancia.eliminar(lugar.id!);
      if (!context.mounted) return;
      Navigator.pop(context, true); // Regresa a la lista avisando que se borró
    } on RepositorioException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje)),
      );
    }
  }

  /// Abre Google Maps con las coordenadas guardadas del lugar
  Future<void> _abrirEnGoogleMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
          '&query=${lugar.latitud},${lugar.longitud}',
    );

    try {
      final seAbrio = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!seAbrio && context.mounted) {
        _avisar(context, 'No se pudo abrir Google Maps.');
      }
    } catch (_) {
      if (context.mounted) _avisar(context, 'No se pudo abrir Google Maps.');
    }
  }

  void _avisar(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('dd/MM/yyyy').format(lugar.fecha);

    return Scaffold(
      appBar: AppBar(
        title: Text(lugar.nombre),
        actions: [
          IconButton(
            tooltip: 'Borrar lugar',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarBorrado(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Foto grande: usa la misma etiqueta Hero que la lista,
          // por eso la imagen "vuela" de una pantalla a otra
          FotoLugar(lugar: lugar, ancho: double.infinity, alto: 240),
          const SizedBox(height: 16),
          Text(
            lugar.nombre,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(lugar.categoria),
                backgroundColor: AppColors.mostaza,
                side: BorderSide.none,
              ),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text(fecha),
            ],
          ),
          const SizedBox(height: 16),
          if (lugar.calificacion > 0) ...[
            Estrellas(calificacion: lugar.calificacion, tamano: 28),
            const SizedBox(height: 16),
          ],
          if (lugar.personas.isNotEmpty) ...[
            const Text('Acompañada de:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: lugar.personas
                  .map(
                    (nombre) => Chip(
                  avatar: const Icon(Icons.person, size: 18),
                  label: Text(nombre),
                  backgroundColor: AppColors.azulCielo,
                  side: BorderSide.none,
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          const Text('Mi opinión',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(lugar.opinion, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          const Text('Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (lugar.tieneUbicacion) ..._seccionMapa(context) else _sinUbicacion(),
        ],
      ),
    );
  }

  /// Mapa interactivo con el marcador, más el botón de Google Maps
  List<Widget> _seccionMapa(BuildContext context) {
    final punto = LatLng(lugar.latitud!, lugar.longitud!);

    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 260,
          child: FlutterMap(
            options: MapOptions(initialCenter: punto, initialZoom: 16),
            children: [
              // Mosaicos del mapa de OpenStreetMap (no necesita clave)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jimenita.merida_explora',
              ),
              // Marcador rosa en el lugar guardado
              MarkerLayer(
                markers: [
                  Marker(
                    point: punto,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      size: 48,
                      color: AppColors.rosaProfundo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        onPressed: () => _abrirEnGoogleMaps(context),
        icon: const Icon(Icons.map),
        label: const Text('Abrir en Google Maps'),
      ),
    ];
  }

  /// Mensaje para lugares que se guardaron sin GPS
  Widget _sinUbicacion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_off, color: AppColors.azulProfundo),
          SizedBox(width: 12),
          Expanded(child: Text('Este lugar se guardó sin ubicación.')),
        ],
      ),
    );
  }
}