// Servicio EXCLUSIVO para OTP / Email Link (passwordless).
// Envía el enlace mágico al correo
// Verifica y completa el inicio de sesión con el enlace recibido

import 'package:firebase_auth/firebase_auth.dart';

class AuthOtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Configuración del enlace de acción (ActionCodeSettings)
  ActionCodeSettings _actionCodeSettings() => ActionCodeSettings(
        url: 'https://mythosapp-c7bec.firebaseapp.com/__/auth/action', //tu dominio configurado
        handleCodeInApp: true,                    //manejar el link en la app
        androidPackageName: 'com.example.mythosapp',
        androidInstallApp: true,
        androidMinimumVersion: '21',
        iOSBundleId: 'com.example.mythosapp',
      );

  /// Envía el enlace mágico al correo proporcionado
  Future<void> sendMagicLink(String email) async {
    await _auth.sendSignInLinkToEmail(
      email: email.trim(),
      actionCodeSettings: _actionCodeSettings(),
    );
  }

  /// Verifica si una URL es válida para completar el inicio por email link
  bool isEmailLink(String link) => _auth.isSignInWithEmailLink(link);

  /// Completa el inicio de sesión con el enlace y el email original
  Future<void> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    final credential = EmailAuthProvider.credentialWithLink(
      email: email.trim(),
      emailLink: emailLink,
    );
    await _auth.signInWithCredential(credential);
  }
}
