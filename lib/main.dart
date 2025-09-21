import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'utils/app_theme.dart';

import 'services/api_service.dart';
import 'services/permission_service.dart';
import 'repositories/relatos_repository.dart';
import 'viewmodels/relatos_vm.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'models/relato.dart';

// Vistas
import 'views/home/home_view.dart';
import 'views/relatos/relatos_view.dart';
import 'views/relatos/relatos_create_view.dart';
import 'views/relatos/relato_detail_view.dart';
import 'views/mapa/mapa_view.dart';
import 'views/calendario/calendario_view.dart';
import 'views/biblioteca/biblioteca_view.dart';
import 'views/juegos/retos_view.dart';
import 'views/perfil/perfil_view.dart';
import 'views/search/search_view.dart';
import 'views/settings/settings_view.dart';
import 'views/shell/app_shell.dart';
import 'views/auth/login_view.dart';
import 'views/auth/signup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (opcional para desarrollo)
  try {
    await Firebase.initializeApp();
    print('Firebase inicializado correctamente');
  } catch (e) {
    print('Error al inicializar Firebase: $e');
    print('Continuando sin Firebase para desarrollo...');
  }

  // Inicializar servicios
  final permissionService = PermissionService();
  await permissionService.initialize();

  final api = ApiService();
  final relatosRepo = RelatosRepository(api);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => RelatosVM(relatosRepo)),
      ],
      child: const MythosApp(),
    ),
  );
}

class MythosApp extends StatelessWidget {
  const MythosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/auth/login',
      redirect: (context, state) {
        final authViewModel = context.read<AuthViewModel>();
        final isAuthenticated = authViewModel.isAuthenticated;
        final isAuthRoute = state.fullPath?.startsWith('/auth') ?? false;
        
        // Si no está autenticado y no está en una ruta de auth, redirigir a login
        if (!isAuthenticated && !isAuthRoute) {
          return '/auth/login';
        }
        
        // Si está autenticado y está en una ruta de auth, redirigir a app
        if (isAuthenticated && isAuthRoute) {
          return '/app';
        }
        
        return null; // No redirigir
      },
      routes: [
        // Rutas de autenticación
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: '/auth/signup',
          builder: (context, state) => const SignupView(),
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
      title: 'MythosApp',
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

