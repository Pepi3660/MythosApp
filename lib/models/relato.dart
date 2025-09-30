// Contiene el modelo de los relatos
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de la colección `Publicaciones` (Relatos)
class Relato {
  final String idP;                         // Id del documento
  final DocumentReference? idU;             // Referencia al usuario autor
  final String tipoP;                       // "texto" | "imagen"
  final String contenido;                   // Texto o URL de imagen
  final DateTime fechaCreacion;             // Timestamp
  final GeoPoint? ubicacion;                // Opcional
  final String titulo;                      //Titulo de la publicacion
  final String municipio;                   //Muncipio del que proviene
  final String categoria;                   //Categoria
  final int? likes;

  Relato({
    required this.idP,
    required this.idU,
    required this.tipoP,
    required this.contenido,
    required this.fechaCreacion,
    this.ubicacion,
    required this.titulo,
    required this.municipio,
    required this.categoria,
    this.likes,
  });

  factory Relato.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Relato(
      idP: d['idP'] as String? ?? doc.id,
      idU: d['iDU'] is DocumentReference ? d['iDU'] as DocumentReference : null,
      tipoP: d['TipoP'] as String? ?? 'texto',
      contenido: d['Contenido'] as String? ?? '',
      fechaCreacion: (d['FechaCreacion'] as Timestamp).toDate(),
      ubicacion: d['Ubicacion'] as GeoPoint?,
      titulo: d['Titulo'] as String? ?? '',
      municipio: d['Municipio'] as String? ?? '',
      categoria: d['Categoria'] as String? ?? '',
      likes:d['likes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'idP': idP,
        'iDU': idU,
        'TipoP': tipoP,
        'Contenido': contenido,
        'FechaCreacion': Timestamp.fromDate(fechaCreacion),
        'Ubicacion': ubicacion,
        'Titulo': titulo,
        'Municipio': municipio,
        'Categoria': categoria,
        'likes': likes,
      };
}

/// Modelo para subcolección `Comentarios`
class Comentario {
  final String idC;
  final DocumentReference? idU;
  final String texto;
  final DateTime fechaComentario;

  Comentario({
    required this.idC,
    required this.idU,
    required this.texto,
    required this.fechaComentario,
  });

  factory Comentario.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Comentario(
      idC: d['iDC'] as String? ?? doc.id,
      idU: d['iDU'] is DocumentReference ? d['IDU'] as DocumentReference : null,
      texto: d['Texto'] as String? ?? '',
      fechaComentario: (d['FechaComentario'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'iDC': idC,
        'iDU': idU,
        'Texto': texto,
        'FechaComentario': Timestamp.fromDate(fechaComentario),
      };
}