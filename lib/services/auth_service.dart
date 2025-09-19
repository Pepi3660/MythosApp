//Servicio que encapsula las llamadas a firebaseAuth

import 'package:firebase_auth/firebase_auth.dart';        //Importo FirebaseAuth para realizar la autenticación

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;       // -> Obtengo la instancia de FirebaseAuth

  /// Inicia sesión con correo y contraseña
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(               //Llamada al método propio de Firebase para login
      email: email.trim(),                                //Limpieza del correo de posibles espacios
      password: password,                                 //Paso la contraseña tal cual
    );
  }

  /// Registro de una nueva cuenta con correo y contraseña
  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(           //Llamada al alta de usuario en Firebase
      email: email.trim(),                                //Limpieza del correo
      password: password,                                 //Paso la contraseña
    );
  }

  ///Envio de un Correo de recuperación de contraseña
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim()); //Solicito restablecimiento de contraseña
  }

  ///Stream para saber si hay usuario autenticado (true/false)
  Stream<bool> authChanges() =>                           //Expongo un stream booleano simplificado
      _auth.authStateChanges().map((user) => user != null);
}
