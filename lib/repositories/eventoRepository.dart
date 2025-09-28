// Capa de acceso a datos. Se encarga de leer de Firestore.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/eventos.dart';

class EventoRepository {
  final FirebaseFirestore _db;

  // Permite inyectar una instancia (útil en tests) o usar la global.
  EventoRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // Referencia a la colección `Eventos`.
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('Eventos');

  // Obtiene eventos en un rango de fechas [desde, hasta).
  Future<List<Evento>> getEventosEntre(DateTime desde, DateTime hasta) async {
    final q = await _col
        // Filtra por rango de Timestamp en campo 'Fecha'
        .where('Fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .where('Fecha', isLessThan: Timestamp.fromDate(hasta))
        .orderBy('Fecha')
        .get();

    // Mapea cada documento al modelo `Evento`
    return q.docs.map((d) => Evento.fromDoc(d)).toList();
  }

    //Subir la imagen
    Future<String> subirImagen(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('eventos/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    //Cambia para devolver la URL de descarga
    final url = await ref.getDownloadURL();
    return url; // <- Este valor se guardará en Firestore
  }

  // Crea un nuevo evento y devuelve el id del documento.
  Future<String> crearEvento({
    required String nombreE,
    required DateTime fecha,
    required String nombreLugar,
    required String municipio,
    required String descripcion,
    required String tipoEvento,
    required String organizador,      // String (no ref)
    String? portada,                  // URL de descarga o null
  }) async {
    final data = {
      'NombreE': nombreE,
      'Fecha': Timestamp.fromDate(fecha),
      'NombreLugar': nombreLugar,
      'Municipio': municipio,
      'Descripcion': descripcion,
      'TipoEvento': tipoEvento,
      'Organizador': organizador,
      'Portada': portada,             // <- URL completa (https://...) o null
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Unifica el nombre de colección aquí:
    final colRef = _db.collection('Eventos'); // <-- usa 'Eventos' o 'eventos', pero SIEMPRE el mismo

    final doc = await colRef.add(data);
    return doc.id;
  }

  
  // Azúcar sintáctico para obtener todos los eventos de un día.
  Future<List<Evento>> getEventosDelDia(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return getEventosEntre(start, end);
  }

  // Obtiene un evento por id de documento (o por IdE si coincide).
  Future<Evento> getById(String id) async {
    final d = await _col.doc(id).get();
    return Evento.fromDoc(d);
  }
}
