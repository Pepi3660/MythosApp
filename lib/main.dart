import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'repositories/relatos_repository.dart';
import 'viewmodels/relatos_vm.dart';
import 'models/relato.dart';

import 'utils/app_theme.dart';
import 'views/home/home_view.dart';
import 'views/relatos/relatos_view.dart';
import 'views/relatos/relatos_create_view.dart';
import 'views/relatos/relato_detail_view.dart';
import 'views/mapa/mapa_view.dart';
import 'views/calendario/calendario_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiService();
  final relatosRepo = RelatosRepository(api);

  runApp(
    MultiProvider(
      providers: [
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
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeView()),
        GoRoute(
          path: '/relatos',
          builder: (_, __) => const RelatosView(),
          routes: [
            GoRoute(path: 'crear', builder: (_, __) => const RelatoCreateView()),
            GoRoute(
              path: 'detalle',
              builder: (_, state) => RelatoDetailView(relato: state.extra as Relato),
            ),
          ],
        ),
        GoRoute(path: '/mapa', builder: (_, __) => const MapaView()),
        GoRoute(path: '/calendario', builder: (_, __) => const CalendarioView()),
      ],
    );

    return MaterialApp.router(
      title: 'Mythos App',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
