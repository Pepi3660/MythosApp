import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  bool _isFirebaseAvailable = false;
  
  // Para modo desarrollo sin Firebase
  User? _mockUser;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  
  // Usuario de prueba predefinido
  static const String testEmail = 'test@mythos.com';
  static const String testPassword = '123456';
  static const String testDisplayName = 'Usuario de Prueba';

  AuthService._internal() {
    _initializeFirebase();
  }

  void _initializeFirebase() {
    try {
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
      _isFirebaseAvailable = true;
      debugPrint('Firebase Auth disponible');
    } catch (e) {
      debugPrint('Firebase no disponible, usando modo desarrollo: $e');
      _isFirebaseAvailable = false;
    }
  }

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges {
    if (_isFirebaseAvailable && _auth != null) {
      return _auth!.authStateChanges();
    } else {
      return _authStateController.stream;
    }
  }

  // Usuario actual
  User? get currentUser {
    if (_isFirebaseAvailable && _auth != null) {
      return _auth!.currentUser;
    } else {
      return _mockUser;
    }
  }

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  // Registro con email y contraseña
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_isFirebaseAvailable && _auth != null) {
      try {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        // Actualizar el nombre del usuario
        await credential.user?.updateDisplayName(displayName.trim());
        await credential.user?.reload();

        return credential;
      } on FirebaseAuthException catch (e) {
        debugPrint('Error en registro: ${e.code} - ${e.message}');
        throw _handleAuthException(e);
      } catch (e) {
        debugPrint('Error inesperado en registro: $e');
        throw 'Error inesperado. Inténtalo de nuevo.';
      }
    } else {
      // Modo desarrollo sin Firebase
      debugPrint('Registro simulado para: $email');
      await Future.delayed(const Duration(seconds: 1)); // Simular delay
      
      // Permitir registro del usuario de prueba o cualquier email
      _mockUser = _MockUser(
        uid: email.trim().toLowerCase() == testEmail.toLowerCase() ? 'test_user_123' : 'mock_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        displayName: displayName.trim(),
      );
      
      _authStateController.add(_mockUser);
      return null; // En modo desarrollo no retornamos UserCredential real
    }
  }

  // Inicio de sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_isFirebaseAvailable && _auth != null) {
      try {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        return credential;
      } on FirebaseAuthException catch (e) {
        debugPrint('Error en login: ${e.code} - ${e.message}');
        throw _handleAuthException(e);
      } catch (e) {
        debugPrint('Error inesperado en login: $e');
        throw 'Error inesperado. Inténtalo de nuevo.';
      }
    } else {
      // Modo desarrollo sin Firebase
      debugPrint('Login simulado para: $email');
      await Future.delayed(const Duration(seconds: 1)); // Simular delay
      
      // Verificar credenciales del usuario de prueba
      if (email.trim().toLowerCase() == testEmail.toLowerCase() && password == testPassword) {
        // Crear usuario simulado con credenciales válidas
        _mockUser = _MockUser(
          uid: 'test_user_123',
          email: testEmail,
          displayName: testDisplayName,
        );
        
        _authStateController.add(_mockUser);
        return null; // En modo desarrollo no retornamos UserCredential real
      } else {
        // Credenciales incorrectas
        throw 'Credenciales incorrectas. Usa: $testEmail / $testPassword';
      }
    }
  }

  // Inicio de sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    if (_isFirebaseAvailable && _auth != null && _googleSignIn != null) {
      try {
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        
        if (googleUser == null) {
          // El usuario canceló el proceso
          return null;
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        return await _auth!.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        debugPrint('Error en login con Google: ${e.code} - ${e.message}');
        throw _handleAuthException(e);
      } catch (e) {
        debugPrint('Error inesperado en login con Google: $e');
        throw 'Error inesperado con Google. Inténtalo de nuevo.';
      }
    } else {
      // Modo desarrollo sin Firebase
      debugPrint('Login con Google simulado');
      await Future.delayed(const Duration(seconds: 1)); // Simular delay
      
      // Crear usuario simulado
      _mockUser = _MockUser(
        uid: 'mock_google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'usuario.demo@gmail.com',
        displayName: 'Usuario Google Demo',
      );
      
      _authStateController.add(_mockUser);
      return null; // En modo desarrollo no retornamos UserCredential real
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    if (_isFirebaseAvailable && _auth != null && _googleSignIn != null) {
      try {
        await Future.wait([
          _auth!.signOut(),
          _googleSignIn!.signOut(),
        ]);
      } catch (e) {
        debugPrint('Error al cerrar sesión: $e');
        throw 'Error al cerrar sesión. Inténtalo de nuevo.';
      }
    } else {
      // Modo desarrollo sin Firebase
      debugPrint('Logout simulado');
      _mockUser = null;
      _authStateController.add(null);
    }
  }

  // Enviar email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    if (_isFirebaseAvailable && _auth != null) {
      try {
        await _auth!.sendPasswordResetEmail(email: email.trim());
      } on FirebaseAuthException catch (e) {
        debugPrint('Error al enviar email de recuperación: ${e.code} - ${e.message}');
        throw _handleAuthException(e);
      } catch (e) {
        debugPrint('Error inesperado al enviar email de recuperación: $e');
        throw 'Error inesperado. Inténtalo de nuevo.';
      }
    } else {
      // Modo desarrollo sin Firebase
      debugPrint('Envío de email de recuperación simulado para: $email');
      await Future.delayed(const Duration(seconds: 1)); // Simular delay
    }
  }

  // Eliminar cuenta
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      debugPrint('Error al eliminar cuenta: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Error inesperado al eliminar cuenta: $e');
      throw 'Error inesperado. Inténtalo de nuevo.';
    }
  }

  // Manejar excepciones de Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'user-not-found':
        return 'No se encontró una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';
      case 'operation-not-allowed':
        return 'Operación no permitida.';
      case 'invalid-credential':
        return 'Las credenciales no son válidas.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo usando otro método.';
      case 'requires-recent-login':
        return 'Esta operación requiere autenticación reciente.';
      default:
        return e.message ?? 'Error de autenticación desconocido.';
    }
  }
}

// Clase para simular un usuario en modo desarrollo
class _MockUser implements User {
  @override
  final String uid;
  
  @override
  final String? email;
  
  @override
  final String? displayName;
  
  @override
  final bool emailVerified = true;
  
  @override
  final bool isAnonymous = false;
  
  @override
  final UserMetadata metadata = _MockUserMetadata();
  
  @override
  final String? phoneNumber = null;
  
  @override
  final String? photoURL = null;
  
  @override
  final List<UserInfo> providerData = [];
  
  @override
  final String? refreshToken = null;
  
  @override
  final String? tenantId = null;
  
  _MockUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });
  
  @override
  Future<void> delete() async {}
  
  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock_token';
  
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    throw UnimplementedError();
  }
  
  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) async {
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) async {
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> linkWithRedirect(AuthProvider provider) async {}
  
  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) async {}
  
  @override
  Future<void> reload() async {}
  
  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}
  
  @override
  Future<User> unlink(String providerId) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateDisplayName(String? displayName) async {}
  
  @override
  Future<void> updateEmail(String newEmail) async {}
  
  @override
  Future<void> updatePassword(String newPassword) async {}
  
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {}
  
  @override
  Future<void> updatePhotoURL(String? photoURL) async {}
  
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}
  
  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {}
  
  @override
  MultiFactor get multiFactor => throw UnimplementedError();
  
  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) async {
    throw UnimplementedError();
  }
}

class _MockUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
  
  @override
  DateTime? get lastSignInTime => DateTime.now();
}