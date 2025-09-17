// lib/repositories/relatos_repository.dart
import '../services/api_service.dart';
import '../models/relato.dart';

class RelatosRepository {
  final ApiService api;
  RelatosRepository(this.api);

  Future<List<Relato>> listar({
    String? departamento,
    String? municipio,
    String? barrio,
    String? tag,
  }) {
    return api.getRelatos(
      departamento: departamento,
      municipio: municipio,
      barrio: barrio,
      tag: tag,
    );
  }

  Future<bool> crear({
    required String titulo,
    String? cuerpo,
    required String tipo,
    String? departamento,
    required String municipio,
    String? barrio,
    List<String> tags = const [],
    List<String> media = const [],
    double? lat,
    double? lng,
    String autorNombre = 'Anónimo',
  }) {
    return api.crearRelato(
      titulo: titulo,
      cuerpo: cuerpo,
      tipo: tipo,
      departamento: departamento,
      municipio: municipio,
      barrio: barrio,
      tags: tags,
      mediaUrls: media,
      lat: lat,
      lng: lng,
      autorNombre: autorNombre,
    );
  }
}
