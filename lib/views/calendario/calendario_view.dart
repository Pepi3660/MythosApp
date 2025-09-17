import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalendarioView extends StatelessWidget {
  const CalendarioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: const Center(child: Text('Calendario cultural (pendiente)')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/relatos');
          if (i == 1) context.go('/mapa');
          if (i == 2) context.go('/calendario');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Relatos'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Calendario'),
        ],
      ),
    );
  }
}
