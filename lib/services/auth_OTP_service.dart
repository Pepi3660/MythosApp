// Servicio EXCLUSIVO para OTP / Email Link (passwordless).
// Envía el enlace mágico al correo dicho enlace lo redirigue a una pagina
// donde se muestra el codigo generado

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthOtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

    //Letra fija del OTP
  static const String _fixedLetter = 'M';

  //Configuración del enlace de acción
  //Inyectamos el OTP en la `url` como query param para poder leerlo al regresar
  Future<ActionCodeSettings> _actionCodeSettingsWithOtp(String otp) async {
      //Ruta Hostin
    final continueUrl = Uri.parse('https://mythosapp-c7bec.web.app/Bienvenida')
        .replace(queryParameters: {'otp': otp}).toString();

    return ActionCodeSettings(
      url: continueUrl,
      handleCodeInApp: true,
      androidPackageName: 'com.example.mythosapp',
      androidInstallApp: true,
      androidMinimumVersion: '21',
      iOSBundleId: 'com.example.mythosapp',
    );
  }

  /// ✅ NUEVO: genera un OTP de 4 dígitos con letra fija (p.ej. M1234)
  String generateOtp() {
    final rnd = Random.secure().nextInt(10000); // 0..9999
    final digits = rnd.toString().padLeft(4, '0');
    return '$_fixedLetter$digits';
  }

  /// Envía el email link de Firebase **y** guarda el OTP localmente.
  Future<void> sendEmail(String email) async {
    final otp = generateOtp();

    // Guardamos el OTP localmente para validarlo luego en la pantalla
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_otp', otp);
    await prefs.setString('otp_email', email.trim());

    if (kDebugMode) {
      // Útil en desarrollo para ver el código en consola
      // ignore: avoid_print
      print('DEBUG OTP para $email => $otp');
    }

    // Enviamos el email link de Firebase con el OTP en el continueUrl
    final acs = await _actionCodeSettingsWithOtp(otp);
    await _auth.sendSignInLinkToEmail(
      email: email.trim(),
      actionCodeSettings: acs,
    );
  }

  /// Verifica si una URL es válida para completar el inicio por email link
  bool isEmailLink(String link) => _auth.isSignInWithEmailLink(link);

  /// Completa el inicio de sesión con el enlace y el email original (si decides usar email-link)
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

  /// (Opcional) obtiene el OTP embebido en el continueUrl (si capturas el deep link)
  String? extractOtpFromUri(Uri uri) {
    return uri.queryParameters['otp'];
  }

  String get fixedLetter => _fixedLetter;
}
