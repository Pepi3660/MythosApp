import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; //Libreria que permite el uso de firebase
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mythosapp/firebase_options.dart'; //Referencia al archivo que guarda las configuraciones de firebase
import 'package:mythosapp/services/StorageService.dart';
import 'package:mythosapp/services/permission_service.dart';
import 'package:mythosapp/utils/app_theme.dart';
import 'package:mythosapp/views/calendario/CalendarioView.dart';
import 'package:mythosapp/views/login/login_view.dart';
import 'package:mythosapp/views/login/registerView.dart';
import 'package:mythosapp/views/login/verificationOTP.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/eventoRepository.dart';
import 'repositories/relatoRepository.dart';
import 'services/RelatoService.dart';
import 'services/eventoService.dart';
import 'viewmodels/calendarioViewModel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/relatos_vm.dart';
import 'views/biblioteca/biblioteca_view.dart';
//Archivos del login
import 'views/home/home_view.dart';
import 'views/juegos/retos_view.dart';
import 'views/mapa/mapa_view.dart';
import 'views/perfil/perfil_view.dart';
import 'views/relatos/relatos_view.dart';
import 'views/search/search_view.dart';
import 'views/settings/settings_view.dart';
import 'views/shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();                         //Inicializador de los componentes
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es', null);
  await initializeDateFormatting();

  //Servicios previos
  final permissionService = PermissionService();
  await permissionService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => StorageService()),
        //Eventos
        Provider<EventoRepository>(create: (_) => EventoRepository()),
        Provider<EventoService>(
          create: (ctx) => EventoService(ctx.read<EventoRepository>()),
        ),
        ChangeNotifierProvider(
            create: (ctx) => CalendarioViewModel(
              ctx.read<EventoService>(),
              storage: ctx.read<StorageService>(),
            )..cargarMes(DateTime.now()),
          ),
        //Relatos
        Provider<RelatoRepository>(create: (_) => RelatoRepository()),
        Provider<RelatoService>(create: (ctx) => RelatoService(ctx.read<RelatoRepository>())),
        ChangeNotifierProvider<RelatosVM>(
          create: (ctx) => RelatosVM(ctx.read<RelatoService>())..cargar(),
        ),

        //Autentificacion
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        
      ],
      child: const MythosApp(),
    ),
  );
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

// Helper para refrescar el router cuando cambie el auth de Firebase
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class MythosApp extends StatefulWidget {
  const MythosApp({super.key});
  @override
  State<MythosApp> createState() => _MythosAppState();
}

class _MythosAppState extends State<MythosApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri?>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // Escucha deep links (incluye enlace inicial si abrió desde el correo)
    _linkSub = _appLinks.uriLinkStream.listen((uri) async {
      if (!mounted || uri == null) return;

      // Intentar extraer OTP del deep link (si venía como query param)
      final vm = context.read<AuthViewModel>();
      final otp = await vm.tryExtractOtpFromUri(uri);
      if (!mounted) return;

      if (otp != null && otp.isNotEmpty) {
        // Recupera lo que guardaste al pulsar el botón en RegisterView
        final prefs = await SharedPreferences.getInstance();
        final name = (prefs.getString('pending_name') ?? '').trim();
        final email = (prefs.getString('otp_email') ?? '').trim();
        final password = (prefs.getString('pending_password') ?? '').trim();

        if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
          context.push(
            '/otp',
            extra: OtpArgs(
              name: name,
              email: email,
              password: password,
              prefilledOtp: otp, // p.ej. 'M1234'
            ),
          );
        }
        return; // ya manejamos OTP, no seguimos con email-link
      }
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Router que se refresca cuando cambia el login de Firebase
    final router = GoRouter(
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(
        FirebaseAuth.instance.authStateChanges(),
      ),

      // Guardo global con rutas públicas
      redirect: (context, state) {
        final loggedIn = FirebaseAuth.instance.currentUser != null;
        final loc = state.matchedLocation;

        // Rutas públicas
        const publicPaths = <String>{
          '/login',
          '/register',
          '/otp',
        };

        // No logueado → si NO va a una pública, mandarlo a /login
        if (!loggedIn && !publicPaths.contains(loc)) {
          return '/login';
        }

        // Logueado → si va a una pública, mandarlo a /app
        if (loggedIn && publicPaths.contains(loc)) {
          return '/app';
        }

        return null;
      },

      initialLocation: '/login',
      routes: [
        // --- Rutas públicas ---
        GoRoute(path: '/login', builder: (_, __) => const LoginView()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterView()),

        // Ruta de verificación OTP (pública)
        GoRoute(
          path: '/otp',
          builder: (_, state) {
            // Ahora leemos los argumentos como tu clase OtpArgs
            final args = state.extra as OtpArgs;
            return OtpVerificationView(
              name: args.name,
              email: args.email,
              password: args.password,
              //prefilledOtp: args.prefilledOtp,
            );
          },
        ),

        // --- Rutas privadas dentro del Shell ---
        ShellRoute(
          builder: (context, state, child) {
            final showFixedNav = _shouldShowFixedNavigation(state.fullPath ?? '');
            return AppShell(child: child, showFixedNavigation: showFixedNav);
          },
          routes: [
            GoRoute(path: '/app', builder: (_, __) => const HomeView()),
            GoRoute(path: '/search', builder: (_, __) => const SearchView()),
            GoRoute(path: '/mapa', builder: (ctx, state) => MapaView(
                initial: state.extra is MapaTarget ? state.extra as MapaTarget : null)),
            GoRoute(path: '/perfil', builder: (_, __) => const PerfilView()),
            GoRoute(
              path: '/relatos',
              builder: (_, __) => const RelatosPage(), // listado/feed
            ),
            GoRoute(path: '/calendario', builder: (_, __) => const CalendarioViews()),
            GoRoute(path: '/biblioteca', builder: (_, __) => const BibliotecaView()),
            GoRoute(path: '/juegos', builder: (_, __) => const RetosView()),
            GoRoute(path: '/settings', builder: (_, __) => const SettingsView()),
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

  bool _shouldShowFixedNavigation(String path) {
    const fixedNavRoutes = [
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
    return fixedNavRoutes.any((r) => path.startsWith(r));
  }
}
