import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final items = <_HomeItem>[
      _HomeItem('Relatos', Icons.menu_book_outlined, '/relatos'),
      _HomeItem('Mapa', Icons.map_outlined, '/mapa'),
      _HomeItem('Calendario', Icons.event_outlined, '/calendario'),
      _HomeItem('Biblioteca', Icons.local_library_outlined, '/biblioteca'), // futuro
      _HomeItem('Juegos', Icons.extension_outlined, '/juegos'), // futuro
    ];

    // Nombre de usuario (placeholder local, sin TODOs)
    const nombre = 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mythos App'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'Hola, $nombre 👋\nBienvenido a MythosApp',
              style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Text(
              '¿Qué te gustaría explorar hoy?',
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de módulos
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.08,
              ),
              itemBuilder: (_, i) => _HomeCard(item: items[i]),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final IconData icon;
  final String route;
  const _HomeItem(this.title, this.icon, this.route);
}

class _HomeCard extends StatelessWidget {
  final _HomeItem item;
  const _HomeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go(item.route),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: .10),
              scheme.tertiary.withValues(alpha: .10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Icon(item.icon, size: 30, color: scheme.primary),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  item.title,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.primary,
                  child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
