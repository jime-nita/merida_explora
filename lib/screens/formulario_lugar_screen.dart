import 'dart:io';
import 'package:flutter/material.dart';
import '../data/lugar_repositorio.dart';
import '../data/lugar_repositorio_sqlite.dart';
import '../models/lugar.dart';
import '../services/servicio_exception.dart';
import '../services/servicio_imagen.dart';
import '../services/servicio_permisos.dart';
import '../services/servicio_ubicacion.dart';
import '../services/servicio_voz.dart';
import '../theme/app_colors.dart';

/// Formulario para registrar un lugar nuevo:
/// nombre, categoría, foto (cámara o galería), opinión (escrita o dictada)
/// y ubicación GPS (se captura sola al guardar).
class FormularioLugarScreen extends StatefulWidget {
  const FormularioLugarScreen({super.key});

  @override
  State<FormularioLugarScreen> createState() => _FormularioLugarScreenState();
}

class _FormularioLugarScreenState extends State<FormularioLugarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _opinionCtrl = TextEditingController();

  // Usamos el contrato del repositorio, no SQLite directamente
  final LugarRepositorio _repositorio = LugarRepositorioSqlite.instancia;

  // Un servicio por cada gadget (cada uno con una sola responsabilidad)
  late final ServicioPermisos _permisos;
  late final ServicioImagen _servicioImagen;
  late final ServicioUbicacion _servicioUbicacion;
  late final ServicioVoz _servicioVoz;

  static const List<String> _categorias = [
    'Restaurante',
    'Café',
    'Parque',
    'Museo',
    'Cenote',
    'Tienda',
    'Otro',
  ];

  String _categoria = _categorias.first;
  String? _rutaFoto; // Ruta de la foto elegida (null si no hay)
  bool _dictando = false; // true mientras el micrófono escucha
  bool _guardando = false; // true mientras se guarda el lugar
  String _textoAntesDeDictar = ''; // Lo que ya estaba escrito antes de dictar

  @override
  void initState() {
    super.initState();
    // Creamos los servicios; todos comparten el mismo servicio de permisos
    _permisos = ServicioPermisos();
    _servicioImagen = ServicioImagen(_permisos);
    _servicioUbicacion = ServicioUbicacion(_permisos);
    _servicioVoz = ServicioVoz(_permisos);
  }

  @override
  void dispose() {
    // Liberamos recursos al salir de la pantalla
    if (_dictando) _servicioVoz.detener();
    _nombreCtrl.dispose();
    _opinionCtrl.dispose();
    super.dispose();
  }

  // ---------- Mensajes al usuario ----------

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Muestra el error de un servicio. Si el permiso quedó bloqueado,
  /// agrega un botón para abrir los Ajustes del celular.
  void _mostrarError(ServicioException error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.mensaje),
        action: error.puedeAbrirAjustes
            ? SnackBarAction(
          label: 'Ajustes',
          onPressed: () => _permisos.abrirAjustes(),
        )
            : null,
      ),
    );
  }

  // ---------- Foto ----------

  Future<void> _tomarFoto() async {
    try {
      final ruta = await _servicioImagen.tomarFoto();
      if (ruta != null && mounted) setState(() => _rutaFoto = ruta);
    } on ServicioException catch (e) {
      _mostrarError(e);
    }
  }

  Future<void> _elegirDeGaleria() async {
    try {
      final ruta = await _servicioImagen.elegirDeGaleria();
      if (ruta != null && mounted) setState(() => _rutaFoto = ruta);
    } on ServicioException catch (e) {
      _mostrarError(e);
    }
  }

  // ---------- Dictado por voz ----------

  Future<void> _alternarDictado() async {
    // Si ya está escuchando, lo detenemos
    if (_dictando) {
      await _servicioVoz.detener();
      if (mounted) setState(() => _dictando = false);
      return;
    }

    try {
      _textoAntesDeDictar = _opinionCtrl.text.trim();
      setState(() => _dictando = true);

      await _servicioVoz.iniciarDictado(
        // Cada vez que reconoce palabras, las ponemos en el campo de opinión
        alCambiar: (texto) {
          final base = _textoAntesDeDictar.isEmpty ? '' : '$_textoAntesDeDictar ';
          _opinionCtrl.text = '$base$texto';
          _opinionCtrl.selection =
              TextSelection.collapsed(offset: _opinionCtrl.text.length);
        },
        // Cuando termina de escuchar, apagamos el indicador
        alTerminar: () {
          if (mounted) setState(() => _dictando = false);
        },
      );
    } on ServicioException catch (e) {
      if (mounted) setState(() => _dictando = false);
      _mostrarError(e);
    }
  }

  // ---------- Guardar ----------

  Future<void> _guardar() async {
    // 1) Revisamos que los campos obligatorios estén llenos
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    if (_dictando) await _servicioVoz.detener();

    // 2) Capturamos el GPS. Si el usuario lo niega, guardamos sin ubicación
    double? latitud;
    double? longitud;
    try {
      final posicion = await _servicioUbicacion.obtenerPosicionActual();
      latitud = posicion.latitude;
      longitud = posicion.longitude;
    } on ServicioException catch (e) {
      _mostrarError(e);
    } catch (_) {
      _mostrarMensaje('No se pudo obtener la ubicación. Se guardará sin ella.');
    }

    // 3) Guardamos en SQLite
    try {
      await _repositorio.insertar(
        Lugar(
          nombre: _nombreCtrl.text.trim(),
          categoria: _categoria,
          opinion: _opinionCtrl.text.trim(),
          fecha: DateTime.now(),
          rutaFoto: _rutaFoto,
          latitud: latitud,
          longitud: longitud,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true); // Regresa a la lista avisando que se guardó
    } on RepositorioException catch (e) {
      _mostrarMensaje(e.mensaje);
      if (mounted) setState(() => _guardando = false);
    }
  }

  // ---------- Pantalla ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo lugar')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _seccionFoto(),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del lugar',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'Escribe el nombre del lugar'
                  : null,
            ),
            const SizedBox(height: 20),
            const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _categorias
                  .map(
                    (c) => ChoiceChip(
                  label: Text(c),
                  selected: _categoria == c,
                  selectedColor: AppColors.mostaza,
                  onSelected: (_) => setState(() => _categoria = c),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _opinionCtrl,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Tu opinión',
                alignLabelWithHint: true,
                helperText: _dictando
                    ? 'Escuchando... habla ahora 🎤'
                    : 'Escribe o toca el micrófono para dictar',
                // Botón del micrófono dentro del campo
                suffixIcon: IconButton(
                  tooltip: _dictando ? 'Detener dictado' : 'Dictar',
                  icon: Icon(_dictando ? Icons.stop_circle : Icons.mic),
                  color: _dictando ? AppColors.error : AppColors.rosaProfundo,
                  onPressed: _guardando ? null : _alternarDictado,
                ),
              ),
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'Cuéntanos qué te pareció'
                  : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar lugar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista previa de la foto y los botones de cámara y galería
  Widget _seccionFoto() {
    final ruta = _rutaFoto;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ruta == null
              ? Container(
            height: 180,
            width: double.infinity,
            color: AppColors.azulCielo,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined,
                    size: 48, color: AppColors.azulProfundo),
                SizedBox(height: 8),
                Text('Agrega una foto del lugar'),
              ],
            ),
          )
              : Image.file(
            File(ruta),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _elegirDeGaleria,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}