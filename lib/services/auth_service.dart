
//Servicio que encapsula las llamadas a firebaseAuth

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;       //Obtengo la instancia de FirebaseAuth

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

  //Actualizar el nombre publico del usuario autenticado
  Future<void> updateDisplayName(String displayName) async {
    final u = _auth.currentUser;
    if (u != null) {
      await u.updateDisplayName(displayName.trim());
      await u.reload();
    }
  }
  
  // ---------------- Google Sign-In --------------------
  //Inicio de sesion / Resistro con google
Future<UserCredential> signInWithGoogle() async {
    //Abre el flujo de Google para seleccionar la cuenta
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
        throw FirebaseAuthException(code: 'sign_in_canceled', message: 'Cancelado por el usuario');
      } // usuario canceló el flujo

    //Obtiene los tokens de autenticacion de google
    final googleAuth = await googleUser.authentication;

    //Crea una credencial de Firebase con dichos tokens
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //Inicia sesión en Firebase con la credencial
    return  await _auth.signInWithCredential(credential);
  }

  // Cierre de sesión unificado.
  Future<void> signOut() async {
    //Cerrar sesión de Google si no es web (GoogleSignIn móvil)
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        
      }
    }
    //Cerrar sesión de Firebase
    await _auth.signOut();

    // 3) Limpiar claves usadas por el flujo OTP / registro
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('magic_email');
    await prefs.remove('otp_email');
    await prefs.remove('local_otp');
    await prefs.remove('pending_name');
    await prefs.remove('pending_password');
  }
  
  ///Stream para saber si hay usuario autenticado (true/false)
  Stream<bool> authChanges() =>                           //Expongo un stream booleano simplificado
      _auth.authStateChanges().map((user) => user != null);
}