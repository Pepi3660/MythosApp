
// lib/services/api_service.dart
import 'dart:math';
import '../models/relato.dart';

class ApiService {
  final List<Relato> _db = _seed();

  Future<List<Relato>> getRelatos({
    String? departamento,
    String? municipio,
    String? barrio,
    String? tag,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _db.where((r) {
      final byDep = departamento == null || r.departamento == departamento;
      final byMuni = municipio == null || r.municipio == municipio;
      final byBarrio = barrio == null || (r.barrio != null && r.barrio == barrio);
      final byTag = tag == null || r.tags.contains(tag);
      return byDep && byMuni && byBarrio && byTag;
    }).toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return list;
  }

  Future<bool> crearRelato({
    required String titulo,
    String? cuerpo,
    required String tipo, // 'texto' | 'imagen' | 'video'
    String? departamento,
    required String municipio,
    String? barrio,
    List<String> tags = const [],
    List<String> mediaUrls = const [],
    double? lat,
    double? lng,
    String autorNombre = 'Anónimo',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final nuevo = Relato(
      id: _id(),
      titulo: titulo,
      tipo: tipo,
      cuerpo: cuerpo,
      mediaUrls: mediaUrls,
      lat: lat,
      lng: lng,
      departamento: departamento,
      municipio: municipio,
      barrio: barrio,
      tags: tags,
      fechaCreacion: DateTime.now(),
      autorNombre: autorNombre,
    );
    _db.add(nuevo);
    return true;
  }
}

String _id() =>
    '${DateTime.now().millisecondsSinceEpoch}-${1000 + Random().nextInt(9000)}';

List<Relato> _seed() {
  return [
    Relato(
      id: _id(),
      titulo: 'El toro huaco en Diriamba',
      cuerpo: 'Relato sobre la tradición del toro huaco y sus danzas.',
      tipo: 'texto',
      departamento: 'Carazo',
      municipio: 'Carazo',
      barrio: null,
      autorNombre: 'Doña Marta',
      tags: const ['tradición', 'danza'],
      lat: 11.858,
      lng: -86.239,
      mediaUrls: const [],
      fechaCreacion: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Relato(
      id: _id(),
      titulo: 'Rosquillas somoteñas',
      cuerpo: 'Receta heredada: maíz, queso seco y horno de barro.',
      tipo: 'texto',
      departamento: 'Madriz',
      municipio: 'Madriz',
      autorNombre: 'Don Julio',
      tags: const ['receta', 'gastronomía'],
      lat: 13.476,
      lng: -86.583,
      mediaUrls: const [],
      fechaCreacion: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Relato(
      id: _id(),
      titulo: 'Güirilas con cuajada',
      cuerpo: 'Cómo preparamos la güirila en Matagalpa.',
      tipo: 'texto',
      departamento: 'Matagalpa',
      municipio: 'Matagalpa',
      autorNombre: 'Familia López',
      tags: const ['receta'],
      lat: 12.927,
      lng: -85.917,
      mediaUrls: const [],
      fechaCreacion: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Relato(
      id: _id(),
      titulo: 'Historia del Palo de Mayo',
      cuerpo: 'Memorias de la celebración en Bluefields.',
      tipo: 'texto',
      departamento: 'RAAS',
      municipio: 'RAAS',
      autorNombre: 'María S.',
      tags: const ['música', 'baile'],
      lat: 12.014,
      lng: -83.764,
      mediaUrls: const [],
      fechaCreacion: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Relato(
      id: _id(),
      titulo: 'Velas patronales en León',
      cuerpo: 'Cómo se organizan las velas y procesiones.',
      tipo: 'texto',
      departamento: 'León',
      municipio: 'León',
      autorNombre: 'Comité de barrio',
      tags: const ['fiestas', 'fe'],
      lat: 12.435,
      lng: -86.879,
      mediaUrls: const [],
      fechaCreacion: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
}
