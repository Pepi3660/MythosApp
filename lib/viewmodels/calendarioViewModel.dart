// Expone datos listos para la UI del calendario y lista de eventos.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mythosapp/services/StorageService.dart';

import '../models/eventos.dart';
import '../services/eventoService.dart';

class CalendarioViewModel extends ChangeNotifier {
  final EventoService _service;
  final StorageService? _storage;
  
  CalendarioViewModel(this._service,{StorageService? storage})
      : _storage = storage;

  //Día que el calendario está mostrando como foco (mes visible).
  DateTime focusedDay = DateTime.now();

  //Día seleccionado por el usuario en la vista.
  DateTime? selectedDay;

  //Flags de carga y error simples.
  bool loading = false;
  String? error;

  //Cache local: eventos agrupados por fecha (clave = año/mes/día sin hora).
  final Map<DateTime, List<Evento>> _byDay = {};

  //Lista de eventos del día actualmente seleccionado.
  List<Evento> get eventosSeleccionados {
    final key = _dateKey(selectedDay ?? DateTime.now());
    return _byDay[key] ?? const [];
    }

  //Carga todos los eventos del mes visible y los agrupa por día.
  Future<void> cargarMes(DateTime anyDay) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      focusedDay = anyDay;
      final eventos = await _service.eventosDelMes(anyDay);

      // Limpia y vuelve a indexar
      _byDay.clear();
      for (final e in eventos) {
        final key = _dateKey(e.fecha);
        _byDay.putIfAbsent(key, () => []).add(e);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  //Creacion de un evento
    Future<String> crearEvento({
        required String nombreE,
        required DateTime fecha,
        required String nombreLugar,
        required String municipio,
        required String descripcion,
        required String tipoEvento,
        required String organizador,         // ahora string (como pediste)
        File? imagenLocal,                   // imagen opcional
      }) async {
        loading = true;
        notifyListeners();

        try {
          String? portadaUrl;

          //Subir la imagen y OBTENER LA URL DE DESCARGA
          if (imagenLocal != null) {
                final name = 'evento_${DateTime.now().millisecondsSinceEpoch}';
                portadaUrl = await _storage?.uploadEventoImage(
                  imagenLocal,
                  fileName: name, // <- requerido por tu StorageService
                );
              }

          //Crear evento en Firestore pasando la URL
          final id = await _service.crearEvento(
            nombreE: nombreE,
            fecha: fecha,
            nombreLugar: nombreLugar,
            municipio: municipio,
            descripcion: descripcion,
            tipoEvento: tipoEvento,
            organizador: organizador,
            portada: portadaUrl, // guarda la URL aquí
          );

          //refrescar el mes o el listado
          await cargarMes(fecha);

          return id;
        } finally {
          loading = false;
          notifyListeners();
        }
      }

  //Selecciona un día y, si no hay cache, carga eventos de ese día.
  Future<void> seleccionarDia(DateTime day) async {
    selectedDay = day;
    final key = _dateKey(day);
    if (!_byDay.containsKey(key)) {
      final list = await _service.eventosDelDia(day);
      _byDay[key] = list;
    }
    notifyListeners();
  }

  //Retorna eventos de un día específico para mostrar marcadores en el calendario.
  List<Evento> eventosParaDia(DateTime day) {
    return _byDay[_dateKey(day)] ?? const [];
  }

  //Devuelve el título del mes actual con localización.
  String mesTitulo(BuildContext context) {
    return DateFormat.yMMMM(Localizations.localeOf(context).languageCode)
        .format(focusedDay);
  }

  //Normaliza a (año, mes, día) para usar como clave de mapa.
  DateTime _dateKey(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
