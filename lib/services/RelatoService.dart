//Srvicio de los relatos
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import '../models/relato.dart';
import '../repositories/relatoRepository.dart';

class RelatoService {
  final RelatoRepository _repo; // (queda por si lo usas en otros métodos)
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  RelatoService(
    this._repo, {
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<List<Relato>> feed() => _repo.listar();

  /// Crea un Relato. Si [imagen] no es null, se sube a Storage y se guarda su URL pública en [contenido].
  /// Devuelve el idP del relato creado.
  Future<String> crearRelato({
    required String tipoP,       // 'texto' o 'imagen'
    required String contenido,   // texto o '' si imagen
    File? imagen,
    GeoPoint? ubicacion,
    required String titulo,
    required String municipio,
    required String categoria,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Subida de imagen (si aplica) y obtención de downloadURL
    String finalContenido = contenido;
    if (tipoP == 'imagen' && imagen != null) {
      final ext = p.extension(imagen.path).replaceFirst('.', '').toLowerCase();
      final fileName = 'rel_${DateTime.now().millisecondsSinceEpoch}.${ext.isEmpty ? 'jpg' : ext}';
      final ref = _storage.ref().child('relatos/$fileName');

      final metadata = SettableMetadata(
        contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
      );

      final uploadTask = ref.putFile(imagen, metadata);
      final snap = await uploadTask.whenComplete(() {});
      if (snap.state != TaskState.success) {
        throw Exception('No se pudo subir la imagen ($fileName)');
      }
      finalContenido = await ref.getDownloadURL();
    }

    // Generar doc y usar su ID como idP
    final relatosCol = FirebaseFirestore.instance.collection('Publicaciones');
    final docRef = relatosCol.doc(); // genera ID sin escribir aún

    final relato = Relato(
      idP: docRef.id, //id real del doc
      idU: FirebaseFirestore.instance.collection('usuarios').doc(user.uid),
      tipoP: tipoP,
      contenido: finalContenido,
      fechaCreacion: DateTime.now(),
      ubicacion: ubicacion,
      titulo: titulo,
      municipio: municipio,
      categoria: categoria,
    );

    // Guardar con el id predefinido
    await docRef.set(relato.toMap());

    return docRef.id;
  }

  /// Agrega un comentario a la subcolección /Publicaciones/{idRelato}/Comentarios/{idC}
  Future<void> agregarComentario(String idRelato, String texto) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    if (texto.trim().isEmpty) return;

    final comentariosRef = FirebaseFirestore.instance
        .collection('Publicaciones')
        .doc(idRelato)
        .collection('Comentarios');

    // Generamos el doc para obtener idC
    final docRef = comentariosRef.doc();

    final c = Comentario(
      idC: docRef.id, // id real del comentario
      idU: FirebaseFirestore.instance.collection('usuarios').doc(user.uid),
      texto: texto.trim(),
      fechaComentario: DateTime.now(),
    );

    // Guardamos con set() en el idC definido
    await docRef.set(c.toMap());
  }
}
