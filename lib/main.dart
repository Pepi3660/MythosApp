import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart'; //Libreria que permite el uso de firebase
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mythosapp/firebase_options.dart'; //Referencia al archivo que guarda las configuraciones de firebase
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/relato.dart';
import 'repositories/relatos_repository.dart';
import 'services/api_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/relatos_vm.dart';
import 'views/calendario/calendario_view.dart';
//Archivos del login
import 'views/login/login_view.dart';
import 'views/mapa/mapa_view.dart';
import 'views/relatos/relato_detail_view.dart';
import 'views/relatos/relatos_create_view.dart';
import 'views/relatos/relatos_view.dart';

void main() async{
  final api = ApiService();
  final relatosRepo = RelatosRepository(api);

  WidgetsFlutterBinding.ensureInitialized(); //asegura la inicializacion exitosa de todos los widgets

  //Inicializaion de firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RelatosVM(relatosRepo)),
      ChangeNotifierProvider(create: (_) => AuthViewModel()),  //inyeccion VM de la autentificacion para el login
    ],
    child: const MythosApp(),
  ));
}

// ------------ Args para /otp ------------
class OtpArgs {
  final String name;
  final String email;
  final String password;
  final String? prefilledOtp;
  OtpArgs({
    required this.name,
    required this.email,
    required this.password,
    this.prefilledOtp,
  });
}

class MythosApp extends StatefulWidget {
  const MythosApp({super.key});

  @override
  State<MythosApp> createState() => _MythosAppState();
}

class _MythosAppState extends State<MythosApp> {
   late final AppLinks _appLinks; //Instancia Unica
    StreamSubscription<Uri?>? _linkSub;
    
  @override
  void initState() {
    super.initState();

    //Instanciamos AppLinks una sola vez
    _appLinks = AppLinks();

    //Suscribirse al stream: incluye el enlace inicial (cold start) y los siguientes
    _linkSub = _appLinks.uriLinkStream.listen((uri) async {
      if (!mounted || uri == null) return;

      //Intentar completar el OTP (email link) en el ViewModel
      final vm = context.read<AuthViewModel>();
      final ok = await vm.tryExtractOtpFromUri(uri);
      if (!mounted) return;

      if (ok != null && ok.isNotEmpty) {
        // Recuperamos lo que guardaste al pulsar el botón (en RegisterView)
        final prefs = await SharedPreferences.getInstance();
        final name = (prefs.getString('pending_name') ?? '').trim();
        final email = (prefs.getString('otp_email') ?? '').trim(); // vm.sendEmailOtp lo guarda
        final password = (prefs.getString('pending_password') ?? '').trim();

        if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
          // Navega a la verificación con OTP prellenado
          if (!mounted) return;
          context.push(
            '/otp',
            extra: OtpArgs(
              name: name,
              email: email,
              password: password,
              prefilledOtp: ok, // 'M1234'
            ),
          );
        }
        return; // no seguimos con email-link si ya usamos OTP
      }

      // Si no trae OTP, puedes omitir o intentar completar el email-link clásico:
      // final ok = await vm.tryCompleteEmailLink(uri.toString());
      // if (mounted && ok) context.go('/relatos');
    }, onError: (e) {
      // opcional: log de error
    });
  }

  @override
  void dispose() {
    // Evitar fugas de memoria
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        //Ruta del login
        GoRoute(path: '/login',
        builder: (_,__) => const LoginView(),
        ),
        //Ruta de los relatos
        GoRoute(
          path: '/relatos',
          builder: (_, __) => const RelatosView(),
          routes: [
            GoRoute(
              path: 'crear',
              builder: (_, __) => const RelatoCreateView(),
            ),
            GoRoute(
              path: 'detalle',
              builder: (ctx, state) {
                final r = state.extra as Relato;
                return RelatoDetailView(relato: r);
              },
            ),
          ],
        ),
        GoRoute(path: '/mapa', builder: (_, __) => const MapaView()),
        GoRoute(path: '/calendario', builder: (_, __) => const CalendarioView()),
      ],
    );

    //Paleta Morado + Dorado
    const kPrimary = Color(0xFF42085F);
    const kSecondary = Color(0xFF530878);
    const kAccent = Color(0xFFFFCF61);

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        primary: kPrimary,
        secondary: kSecondary,
        tertiary: kAccent,
        background: const Color(0xFFF8F7FB),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F7FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kSecondary,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Color(0xFF1B1323)),
        bodyMedium: TextStyle(color: Color(0xFF2A2230)),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        primary: kPrimary,
        secondary: kSecondary,
        tertiary: kAccent,
        background: const Color(0xFF17131C),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF17131C),
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kSecondary,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Color(0xFFE6E0EA)),
      ),
    );

    return MaterialApp.router(
      title: 'Mythos',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
