///Maneja el estado de la UI y expone acciones (login, signup, reset).

import 'dart:math';

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

  AuthViewModel({AuthRepository? repo,
  AuthOtpRepository? otpRepo,
  UsuariosRepository? userepo })
      : _repo = repo ?? AuthRepository(),                 //Inyecto repositorio o creo uno por defecto
        _otpRepo = otpRepo ?? AuthOtpRepository(),
        _userepo = userepo ?? UsuariosRepository();
        
  bool _isLoading = false;                                //Flag de carga para la UI
  bool get isLoading => _isLoading;                       //Getter de solo lectura

  bool _obscure = true;                                   //Flag para mostrar/ocultar contraseña
  bool get obscure => _obscure;                           //Getter de solo lectura

  bool _rememberMe = false;                               //Flag para “Recordarme”
  bool get rememberMe => _rememberMe;                     //Getter de solo lectura

  String? errorMessage;

  //Generados de un ID unico en base-36
  String _generateUserId() {
  final millis = DateTime.now().millisecondsSinceEpoch;
  final base36 = millis.toRadixString(36); //convierto el número a base-36
  final random2 = Random().nextInt(90) + 10; // 10–99
  return 'U$base36$random2';
  
  }
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
      final autoId = _generateUserId();

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

          final autoId = _generateUserId();

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
  // Envía el email con el enlace mágico y guarda el email localmente.
  Future<bool> sendMagicLink(String email) async {
    _setLoading(true); errorMessage = null;
    try {
      await _otpRepo.sendMagicLink(email);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('magic_email', email.trim()); // guardo el email para completar luego
      return true;
    } on Exception catch (e) {
      errorMessage = _mapError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Completa el login cuando recibes el deep link (lo llamas desde el widget raíz con app_links)
  Future<bool> tryCompleteMagicLinkSignIn(String link) async {
    _setLoading(true);
    errorMessage = null;
    try {
      if (!_otpRepo.isEmailLink(link)) {
        errorMessage = 'El enlace recibido no es válido';
        return false;
      }
      final prefs = await SharedPreferences.getInstance();
      final email = (prefs.getString('magic_email') ?? '').trim();
      if (email.isEmpty) {
        errorMessage = 'No encontramos el correo asociado al enlace';
        return false;
      }
      await _otpRepo.signInWithEmailLink(email: email, link: link);
      await prefs.remove('magic_email');

      // (Opcional recomendado) upsert tras completar OTP
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _userepo.upsert(
          uid: user.uid,
          nombre: user.displayName ?? '',
          email: user.email ?? email,
          fotoUrl: null,
        );
      }

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapError(e);
      return false;
    } catch (_) {
      errorMessage = 'No se pudo completar el enlace';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Envía correo de recuperación
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
