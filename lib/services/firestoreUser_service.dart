//Servicio de almacenamiento de usuarios en la BD en firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserService {
  final _db = FirebaseFirestore.instance;

  /// Crea/actualiza el documento del usuario en la colección 'usuarios'
  Future<void> upsertUsuario({
    required String uid,
    required String nombre,
    required String email,
    String? fotoUrl, String? photoUrl,
  }) async {
    final ref = _db.collection('usuarios').doc(uid);

    await ref.set({
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'fotoUrl': fotoUrl,
    }, SetOptions(merge: true)); // merge:true para no pisar campos existentes
  }
}
