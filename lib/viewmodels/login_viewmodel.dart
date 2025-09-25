///Maneja el estado de la UI y expone acciones (login, signup, reset).

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mythosapp/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/authOTPRepository.dart';
import '../repositories/authRepository.dart';


class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;                             //Mantengo referencia al repositorio
  final AuthOtpRepository _otpRepo;  //Guarda temporalmente el email a enviar el OTP
  final UsuariosRepository _userepo;

  /// ¿Hay sesión iniciada?
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  /// Opcional pero MUY útil: re-notificar cuando cambia el estado de FirebaseAuth
  late final StreamSubscription<User?> _authSub;
  
  AuthViewModel({AuthRepository? repo, AuthOtpRepository? otpRepo, UsuariosRepository? userepo})
      : _repo = repo ?? AuthRepository(),
        _otpRepo = otpRepo ?? AuthOtpRepository(),
        _userepo = userepo ?? UsuariosRepository() {
    // Escucha cambios de sesión para que el router vuelva a evaluar redirect
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

    @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
  
  //Estado de la interfaz
  bool _isLoading = false;                                //Flag de carga para la UI
  bool get isLoading => _isLoading;                       //Getter de solo lectura

  bool _obscure = true;                                   //Flag para mostrar/ocultar contraseña
  bool get obscure => _obscure;                           //Getter de solo lectura

  bool _rememberMe = false;                               //Flag para “Recordarme”
  bool get rememberMe => _rememberMe;                     //Getter de solo lectura

  String? errorMessage;

  /// Alterna visibilidad de la contraseña y notifica a la vista
  void toggleObscure() {
    _obscure = !_obscure;                                 //Cambio el estado local
    notifyListeners();                                    //Notifico a los listeners para que redibujen
  }

  /// Actualiza el valor de “Recordarme”
  void setRemember(bool value) {
    _rememberMe = value;                                  //Persiste en memoria del ViewModel
    notifyListeners();                                    //Notifico cambio
  }

  /// Ejecuta el inicio de sesión y maneja errores comunes
  Future<bool> login(String email, String password) async {
    _setLoading(true);                                    //Activo indicador de carga
    errorMessage = null;
    try {
      await _repo.signIn(email, password);                //Delego login al repositorio
      return true;                                        //Devuelvo éxito
    } on FirebaseAuthException catch (e) {
          errorMessage = _mapError(e);
          return false;
        } catch (e) {
          errorMessage = 'Ocurrió un error. Intenta nuevamente';
          return false;
        } finally {
          _setLoading(false);
        }
      }
  
  /// Crea cuenta nueva
  Future<bool> registerEmail({required String name,required String email,required  String password}) async {
    _setLoading(true); errorMessage = null;               //Inicio flow con loading y limpio error
    try {
      await _repo.signUp(email.trim(), password);                //Delego registro
      await _repo.updateDisplayName(name.trim());
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw FirebaseAuthException(code: 'user-null');

      //Crear/actualizar documento en Firestore
      await _userepo.upsert(
        uid: user.uid,
        nombre: name,
        email: user.email ?? email,
        fotoUrl: null,
      );
      return true;
    } on FirebaseAuthException catch (e) {
          errorMessage = _mapError(e);
          return false;
        } catch (_) {
          errorMessage = 'No fue posible crear la cuenta';
          return false;
        } finally {
          _setLoading(false);
        }
      }

   // Inicio de sesion con Google
  Future<bool> signInOrRegisterWithGoogle() async {
    _setLoading(true); errorMessage = null;

    try {
          final cred = await _repo.signInWithGoogle();
          final user = cred.user ?? FirebaseAuth.instance.currentUser;

          if(user == null){
            throw FirebaseAuthException(code: 'user-null', message: 'No se obtuvo el usuario');
          }

          // Upsert en Firestore tras Google
          await _userepo.upsert(
            uid: user.uid,
            nombre: user.displayName ?? '',
            email: user.email ?? '',
            fotoUrl: user.photoURL,
          );
          return true;
        } on FirebaseAuthException catch (e) {
          errorMessage = _mapError(e);
          return false;
        } catch (e,st) {
            errorMessage = 'No se pudo usar Google: $e';
            debugPrint('Google sign-in unknown error: $e\n$st');
            return false;
        } finally {
          _setLoading(false);
        }
      }

  // -------- OTP / Email Link --------
  // Envía el email con el enlace mágico que va acompañado de un OTP local.
  Future<bool> sendMagicLink(String email) async {
    _setLoading(true); errorMessage = null;
    try {
      await _otpRepo.sendEmail(email.trim());
      //Guarda el correo para futuras verificaciones
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('OTP_email', email.trim());
      return true;
    } catch (e) {
      errorMessage = 'No fue posible enviar el correo';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  //Pasa el valor del ORP a la pantalla de verificación para autocompletar.
  Future<String?> tryExtractOtpFromUri(Uri uri) async {
    try {
      // El repo expone extractOtpFromUri()
      return _otpRepo.extractOtpFromUri(uri);
    } catch (_) {
      return null;
    }
  }

  //Compara contra el 'local_otp' guardado por el service en SharedPreferences.
  //Si coincide, devuelve true; si no, deja errorMessage.
  Future<bool> verifyLocalOtp(String fullCode) async {
    _setLoading(true);
    errorMessage = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = (prefs.getString('local_otp') ?? '').trim().toUpperCase();
      final entered = fullCode.trim().toUpperCase();

      if (saved.isEmpty) {
        errorMessage = 'No encontramos un código pendiente';
        return false;
      }
      final ok = saved == entered;
      if (!ok) errorMessage = 'Código inválido';
      return ok;
    } catch (_) {
      errorMessage = 'Error verificando el código';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Envía correo de recuperación
  Future<bool> reset(String email) async {
    _setLoading(true);
    errorMessage = null;
    try {
      final trimmed = email.trim();
      if (trimmed.isEmpty) {
        errorMessage = 'Ingresa un correo válido';
        return false;
      }

      //Llamada directa a FirebaseAuth (más robusta para evitar configs inválidas en el repo)
      await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmed);

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapError(e);
      return false;
    } catch (_) {
      errorMessage = 'No se pudo enviar el correo';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza el estado de carga y notifica
  void _setLoading(bool value) {
    _isLoading = value;                                   //Seteo flag
    notifyListeners();                                    //Notifico a la UI
  }

  /// Traduce códigos de FirebaseAuth a mensajes comprensibles
  String _mapError(Object e) {
    final m = e.toString();                               //Tomo el texto de la excepción
    if (m.contains('user-not-found')) return 'Usuario no encontrado';
    if (m.contains('wrong-password')) return 'Contraseña incorrecta';
    if (m.contains('invalid-email')) return 'Correo inválido';
    if (m.contains('email-already-in-use')) return 'El correo ya está en uso';
    if (m.contains('network-request-failed')) return 'Problema de red, inténtalo de nuevo';
    return 'Ocurrió un error. Intenta nuevamente';        // -> Fallback genérico
  }
}
