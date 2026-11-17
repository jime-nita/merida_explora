import 'dart:convert';

/// Representa un lugar que la persona descubrió en Mérida.
/// Es solo datos: no sabe nada de pantallas ni de la base de datos.
class Lugar {
  final int? id; // Lo asigna SQLite al guardar
  final String nombre;
  final String categoria;
  final String opinion;
  final DateTime fecha;
  final String? rutaFoto; // Ruta de la foto en el celular (puede no haber)
  final double? latitud; // Coordenadas GPS (pueden faltar si negó el permiso)
  final double? longitud;
  final int calificacion; // Estrellas de 0 a 5 (0 = sin calificar)
  final List<String> personas; // Con quién fue a ese lugar

  const Lugar({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.opinion,
    required this.fecha,
    this.rutaFoto,
    this.latitud,
    this.longitud,
    this.calificacion = 0,
    this.personas = const [],
  });

  /// Dice si el lugar tiene coordenadas guardadas
  bool get tieneUbicacion => latitud != null && longitud != null;

  /// Convierte el lugar a un Map para guardarlo en SQLite.
  /// La foto, las coordenadas, las estrellas y las personas
  /// se empaquetan como JSON en "metadatos".
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'opinion': opinion,
      'fecha': fecha.toIso8601String(),
      'metadatos': jsonEncode({
        'rutaFoto': rutaFoto,
        'latitud': latitud,
        'longitud': longitud,
        'calificacion': calificacion,
        'personas': personas,
      }),
    };
  }

  /// Hace lo contrario: arma un Lugar a partir de una fila de SQLite
  factory Lugar.fromMap(Map<String, dynamic> map) {
    // Desempaquetamos el JSON de los metadatos
    final metadatos =
    jsonDecode(map['metadatos'] as String) as Map<String, dynamic>;

    return Lugar(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      categoria: map['categoria'] as String,
      opinion: map['opinion'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      rutaFoto: metadatos['rutaFoto'] as String?,
      latitud: (metadatos['latitud'] as num?)?.toDouble(),
      longitud: (metadatos['longitud'] as num?)?.toDouble(),
      // Los lugares guardados antes no traen estos datos: usamos valores vacíos
      calificacion: (metadatos['calificacion'] as num?)?.toInt() ?? 0,
      personas: (metadatos['personas'] as List?)
          ?.map((nombre) => nombre.toString())
          .toList() ??
          const [],
    );
  }

  /// Convierte el lugar completo a texto JSON
  String toJson() => jsonEncode(toMap());

  /// Crea un lugar a partir de texto JSON
  factory Lugar.fromJson(String fuente) =>
      Lugar.fromMap(jsonDecode(fuente) as Map<String, dynamic>);
}