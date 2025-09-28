// Centraliza reglas simples y prepara rangos de fechas a nivel de negocio.

import '../models/eventos.dart';
import '../repositories/eventoRepository.dart';

class EventoService {
  final EventoRepository _repo;
  EventoService(this._repo);

  // Todos los eventos del mes que contenga [anyDayInMonth].
  Future<List<Evento>> eventosDelMes(DateTime anyDayInMonth) {
    final first = DateTime(anyDayInMonth.year, anyDayInMonth.month, 1);
    
    // Primer día del mes siguiente (rango semi-abierto)
    final last = DateTime(anyDayInMonth.year, anyDayInMonth.month + 1, 1);
    return _repo.getEventosEntre(first, last);
  }

  // Eventos del día exacto.
  Future<List<Evento>> eventosDelDia(DateTime day) => _repo.getEventosDelDia(day);

  //Crear un nuevo evento
  Future<String> crearEvento({
    required String nombreE,
    required DateTime fecha,
    required String nombreLugar,
    required String municipio,
    required String descripcion,
    required String tipoEvento,
    required String organizador, // <- string
    String? portada,             // <- URL completa (https://...)
  }) {
    return _repo.crearEvento(
      nombreE: nombreE,
      fecha: fecha,
      nombreLugar: nombreLugar,
      municipio: municipio,
      descripcion: descripcion,
      tipoEvento: tipoEvento,
      organizador: organizador,
      portada: portada,
    );
  }


  // Detalle de un evento por id.
  Future<Evento> detalle(String id) => _repo.getById(id);
}
