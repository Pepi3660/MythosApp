// lib/models/relato.dart
import 'dart:convert';

class Relato {
  final String id;
  final String titulo;
  final String tipo; // 'texto' | 'imagen' | 'video'
  final String? cuerpo;
  final List<String> mediaUrls;
  final double? lat;
  final double? lng;

  final String? departamento;
  final String municipio;
  final String? barrio;

  final List<String> tags;
  final DateTime fechaCreacion;
  final String autorNombre;

  Relato({
    required this.id,
    required this.titulo,
    required this.tipo,
    this.cuerpo,
    this.mediaUrls = const [],
    this.lat,
    this.lng,
    this.departamento,
    required this.municipio,
    this.barrio,
    this.tags = const [],
    required this.fechaCreacion,
    required this.autorNombre,
  });

  Relato copyWith({
    String? id,
    String? titulo,
    String? tipo,
    String? cuerpo,
    List<String>? mediaUrls,
    double? lat,
    double? lng,
    String? departamento,
    String? municipio,
    String? barrio,
    List<String>? tags,
    DateTime? fechaCreacion,
    String? autorNombre,
  }) {
    return Relato(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      cuerpo: cuerpo ?? this.cuerpo,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      departamento: departamento ?? this.departamento,
      municipio: municipio ?? this.municipio,
      barrio: barrio ?? this.barrio,
      tags: tags ?? this.tags,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      autorNombre: autorNombre ?? this.autorNombre,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo,
      'cuerpo': cuerpo,
      'mediaUrls': mediaUrls,
      'lat': lat,
      'lng': lng,
      'departamento': departamento,
      'municipio': municipio,
      'barrio': barrio,
      'tags': tags,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'autorNombre': autorNombre,
    };
  }

  factory Relato.fromJson(Map<String, dynamic> map) {
    return Relato(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      tipo: map['tipo'] as String,
      cuerpo: map['cuerpo'] as String?,
      mediaUrls: (map['mediaUrls'] as List?)?.cast<String>() ?? const [],
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      departamento: map['departamento'] as String?,
      municipio: map['municipio'] as String? ?? 'Desconocido',
      barrio: map['barrio'] as String?,
      tags: (map['tags'] as List?)?.cast<String>() ?? const [],
      fechaCreacion: DateTime.tryParse(map['fechaCreacion'] ?? '') ?? DateTime.now(),
      autorNombre: map['autorNombre'] as String? ?? 'Anónimo',
    );
  }

  static String encodeList(List<Relato> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Relato> decodeList(String raw) {
    final data = jsonDecode(raw) as List;
    return data.map((e) => Relato.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
