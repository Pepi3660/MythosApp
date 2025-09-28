
//El presente archivo contiene el modelo para documentos de la
//coleccion eventos en firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String idE; // IdE (en la colección)
  final String nombreE;
  final DateTime fecha;
  final String nombreLugar;
  final GeoPoint? ubicacionCoordenadas;
  final String municipio;
  final String descripcion;
  final String? organizador;
  final String? portada; // URL
  final String tipoEvento;

  Evento({
    required this.idE,
    required this.nombreE,
    required this.fecha,
    required this.nombreLugar,
    this.ubicacionCoordenadas,
    required this.municipio,
    required this.descripcion,
    this.organizador,
    this.portada,
    required this.tipoEvento,
  });

  //Construccion del modelo apartir de un DocumentSnapshot
  factory Evento.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    // Asegurar conversión correcta de Timestamp -> DateTime
    final ts = d['Fecha'] as Timestamp;
    return Evento(
      idE: d['idE'] as String? ?? doc.id,
      nombreE: d['NombreE'] as String? ?? '',
      fecha: ts.toDate(),
      nombreLugar: d['NombreLugar'] as String? ?? '',
      ubicacionCoordenadas: d['UbicacionCoordenadas'] as GeoPoint?,
      municipio: d['Municipio'] as String? ?? '',
      descripcion: d['Descripcion'] as String? ?? '',
      organizador: d['Organizador'] as String?,
      portada: d['Portada'] as String?,
      tipoEvento: d['TipoEvento'] as String? ?? '',
    );
  }

//Mapa para crear o actualizar documentos en firestores
  Map<String, dynamic> toMap() {
    return {
      'IdE': idE,
      'NombreE': nombreE,
      'Fecha': Timestamp.fromDate(fecha),
      'NombreLugar': nombreLugar,
      'UbicacionCoordenadas': ubicacionCoordenadas,
      'Municipio': municipio,
      'Descripcion': descripcion,
      'Organizador': organizador,
      'Portada': portada,
      'TipoEvento': tipoEvento,
    };
  }
}
