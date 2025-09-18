import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/relatos_vm.dart';
import '../../widgets/relato_card.dart';

class RelatosView extends StatefulWidget {
  const RelatosView({super.key});
  @override
  State<RelatosView> createState() => _RelatosViewState();
}

class _RelatosViewState extends State<RelatosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelatosVM>().cargar();
    });
  }

  Future<void> _refresh() async {
    await context.read<RelatosVM>().cargar();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelatosVM>();

    return Scaffold(
      appBar: AppBar(title: const Text('Relatos')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Builder(
          builder: (_) {
            if (vm.cargando) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.error!),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (vm.relatos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Aún no hay relatos'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await context.push('/relatos/crear');
                        if (mounted) _refresh();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Publicar el primero'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: vm.relatos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => RelatoCard(relato: vm.relatos[i]),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/relatos');
          if (i == 1) context.go('/mapa');
          if (i == 2) context.go('/calendario');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.article), label: 'Relatos'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Calendario'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/relatos/crear');
          if (mounted) _refresh(); // al volver de crear, refresca el feed
        },
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
    );
  }
}
