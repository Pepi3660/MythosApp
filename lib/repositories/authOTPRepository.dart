// Repositorio que expone los casos de uso de OTP (correo mágico),
import 'package:mythosapp/services/auth_OTP_service.dart';

class AuthOtpRepository {
  final AuthOtpService _service;

  AuthOtpRepository({AuthOtpService? service})
      : _service = service ?? AuthOtpService();

    //Enviio del correo magico
  Future<void> sendEmail(String email) =>
  _service.sendEmail(email);

  bool isEmailLink(String link) => _service.isEmailLink(link);

  Future<void> signInWithEmailLink({
    required String email,
    required String link,
  }) =>
  _service.signInWithEmailLink(email: email, emailLink: link);

  String? extractOtpFromUri(Uri uri) => _service.extractOtpFromUri(uri);

  String get fixedLetter => _service.fixedLetter;
}
