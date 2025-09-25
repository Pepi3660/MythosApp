import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart'; //Libreria que permite el uso de firebase
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mythosapp/firebase_options.dart'; //Referencia al archivo que guarda las configuraciones de firebase
import 'package:mythosapp/services/permission_service.dart';
import 'package:mythosapp/utils/app_theme.dart';
import 'package:mythosapp/views/login/login_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/relato.dart';
import 'repositories/relatos_repository.dart';
import 'services/api_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/relatos_vm.dart';
import 'views/biblioteca/biblioteca_view.dart';
import 'views/calendario/calendario_view.dart';
//Archivos del login
import 'views/home/home_view.dart';
import 'views/juegos/retos_view.dart';
import 'views/mapa/mapa_view.dart';
import 'views/perfil/perfil_view.dart';
import 'views/relatos/relato_detail_view.dart';
import 'views/relatos/relatos_create_view.dart';
import 'views/relatos/relatos_view.dart';
import 'views/search/search_view.dart';
import 'views/settings/settings_view.dart';
import 'views/shell/app_shell.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //asegura la inicializacion exitosa de todos los widgets

  //Inicializaion de firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final api = ApiService();
  final relatosRepo = RelatosRepository(api);

  // Inicializar servicios
  final permissionService = PermissionService();
  await permissionService.initialize();


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
    final authVM = context.watch<AuthViewModel>();

  final router = GoRouter(
      refreshListenable: authVM, //hace que redirect se re-evalúe
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuthenticated = authVM.isAuthenticated;
        final loc = state.matchedLocation; // o state.fullPath ?? ''
        final isAuthRoute = loc.startsWith('/login') || loc.startsWith('/register') || loc.startsWith('/otp');

        // No logueado: bloquear rutas privadas
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // Logueado: evitar pantallas de auth
        if (isAuthenticated && isAuthRoute) {
          return '/app'; // tu “home” privada
        }

        return null; // no redirigir
      },
      routes: [
        // Rutas de autenticación
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginView(),
        ),
        // Ruta principal con shell y navegación fija
        ShellRoute(
          builder: (context, state, child) {
            // Determinar si mostrar navegación fija basado en la ruta
            final showFixedNav = _shouldShowFixedNavigation(state.fullPath ?? '');
            return AppShell(
              child: child,
              showFixedNavigation: showFixedNav,
            );
          },
          routes: [
            GoRoute(
              path: '/app',
              builder: (context, state) {
                final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
                return const HomeView();
              },
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchView(),
            ),
            GoRoute(
              path: '/mapa',
              builder: (context, state) => const MapaView(),
            ),
            GoRoute(
              path: '/perfil',
              builder: (context, state) => const PerfilView(),
            ),
            GoRoute(
              path: '/relatos',
              builder: (context, state) => const RelatosView(),
              routes: [
                GoRoute(
                  path: '/crear',
                  builder: (context, state) => RelatoCreateView(),
                ),
                GoRoute(
                  path: '/detalle',
                  builder: (context, state) => RelatoDetailView(
                    relato: state.extra as Relato,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/calendario',
              builder: (context, state) => const CalendarioView(),
            ),
            GoRoute(
              path: '/biblioteca',
              builder: (context, state) => const BibliotecaView(),
            ),
            GoRoute(
              path: '/juegos',
              builder: (context, state) => const RetosView(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsView(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Mythos',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
  
  // Determinar en qué rutas mostrar navegación fija
  bool _shouldShowFixedNavigation(String path) {
    final fixedNavRoutes = [
      '/app',
      '/search',
      '/mapa',
      '/perfil',
      '/relatos',
      '/calendario',
      '/biblioteca',
      '/juegos',
      '/settings',
    ];
    
    return fixedNavRoutes.any((route) => path.startsWith(route));
  }
}

