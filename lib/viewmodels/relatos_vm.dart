// lib/viewmodels/relatos_vm.dart
import 'package:flutter/foundation.dart';
import '../models/relato.dart';
import '../repositories/relatos_repository.dart';

class RelatosVM extends ChangeNotifier {
  final RelatosRepository repo;
  RelatosVM(this.repo);

  List<Relato> relatos = [];
  bool cargando = false;
  String? error;

  // filtros actuales (opcional)
  String? fDepartamento;
  String? fMunicipio;
  String? fBarrio;
  String? fTag;

  Future<void> cargar({
    String? departamento,
    String? municipio,
    String? barrio,
    String? tag,
  }) async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      relatos = await repo.listar(
        departamento: departamento ?? fDepartamento,
        municipio: municipio ?? fMunicipio,
        barrio: barrio ?? fBarrio,
        tag: tag ?? fTag,
      );
      relatos.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      fDepartamento = departamento ?? fDepartamento;
      fMunicipio = municipio ?? fMunicipio;
      fBarrio = barrio ?? fBarrio;
      fTag = tag ?? fTag;
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
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
  }) async {
    try {
      final ok = await repo.crear(
        titulo: titulo,
        cuerpo: cuerpo,
        tipo: tipo,
        departamento: departamento,
        municipio: municipio,
        barrio: barrio,
        tags: tags,
        media: media,
        lat: lat,
        lng: lng,
      );
      if (ok) {
        // recargar lista rápida
        await cargar();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Relato? byId(String id) {
    try {
      return relatos.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
