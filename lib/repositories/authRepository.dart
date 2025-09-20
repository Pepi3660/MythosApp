//Abstrae el servicio y orquesta reglas del dominio.
//Esto permite testear y reemplazar fácilmente la fuente de datos.

import '../services/auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _service;                     //Mantengo una referencia al servicio

  AuthRepository({FirebaseAuthService? service})
      : _service = service ?? FirebaseAuthService();      //Inyecto servicio o creo uno por defecto

  Future<void> signIn(String email, String password) {
    return _service.signIn(email, password);              //Delego login al servicio
  }

  Future<void> signUp(String email, String password) {
    return _service.signUp(email, password);              //Delego registro al servicio
  }

  Future<void> sendPasswordReset(String email) {
    return _service.sendPasswordReset(email);             //Delego reset al servicio
  }

  Future<void> updateDisplayName(String name) =>
      _service.updateDisplayName(name);
      
  // -------- Google --------
  Future<void> signInWithGoogle() => _service.signInWithGoogle();

  Stream<bool> authChanges() => _service.authChanges();   //Reexpongo el stream de cambios de auth
}
