//Srvicio de los relatos
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/relato.dart';
import '../repositories/relatoRepository.dart';

class RelatoService {
  final RelatoRepository _repo;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  RelatoService(this._repo,
      {FirebaseAuth? auth, FirebaseStorage? storage})
      : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<List<Relato>> feed() => _repo.listar();

  /// Crea un Relato. Si [imagen] no es null, se sube a Storage y se guarda su URL.
  Future<String> crearRelato({
    required String tipoP,       // 'texto' o 'imagen'
    required String contenido,   // texto o '' si imagen
    File? imagen,
    GeoPoint? ubicacion,
  }) async {
    String finalContenido = contenido;

    if (tipoP == 'imagen' && imagen != null) {
      final fileName = 'rel_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('relatos/$fileName');
      final task = await ref.putFile(
        imagen,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      finalContenido = await task.ref.getDownloadURL();
    }

    final user = _auth.currentUser;
    final relato = Relato(
      idP: '',
      idU: user != null
          ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid)
          : null,
      tipoP: tipoP,
      contenido: finalContenido,
      fechaCreacion: DateTime.now(),
      ubicacion: ubicacion,
    );

    return _repo.crear(relato);
  }

  Future<void> agregarComentario(String idRelato, String texto) async {
    final user = _auth.currentUser;
    final c = Comentario(
      idC: '',
      idU: user != null
          ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid)
          : null,
      texto: texto,
      fechaComentario: DateTime.now(),
    );
    await _repo.comentar(idRelato, c);
  }
}
