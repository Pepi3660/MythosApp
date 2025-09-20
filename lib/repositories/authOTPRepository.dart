// Repositorio que expone los casos de uso de OTP (correo mágico),
import 'package:mythosapp/services/auth_OTP_service.dart';

class AuthOtpRepository {
  final AuthOtpService _service;

  AuthOtpRepository({AuthOtpService? service})
      : _service = service ?? AuthOtpService();

    //Enviio del correo magico
  Future<void> sendMagicLink(String email) =>
      _service.sendMagicLink(email);

  bool isEmailLink(String link) =>
      _service.isEmailLink(link);

    //Inicio de sesion con el correo y el link
  Future<void> signInWithEmailLink({
    required String email,
    required String link,
  }) =>
      _service.signInWithEmailLink(email: email, emailLink: link);
}
