//Repositorio usuarios

import '../services/firestoreUser_service.dart';

class UsuariosRepository {
  final FirestoreUserService _svc;
  UsuariosRepository({FirestoreUserService? service})
      : _svc = service ?? FirestoreUserService();

  Future<void> upsert({
    required String uid,
    required String nombre,
    required String email,
    String? fotoUrl,
  }) =>
      _svc.upsertUsuario(uid: uid, nombre: nombre, email: email, fotoUrl: fotoUrl);
}
