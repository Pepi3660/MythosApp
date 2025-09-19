import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/noticias_vm.dart';
import '../../models/noticia.dart';

class NoticiasView extends StatefulWidget {
  const NoticiasView({super.key});

  @override
  State<NoticiasView> createState() => _NoticiasViewState();
}

class _NoticiasViewState extends State<NoticiasView> {
  @override
  void initState() {
    super.initState();
    // Cargar al entrar
    Future.microtask(() => context.read<NoticiasVM>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoticiasVM>();
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NotiMythos'),
        actions: [
          IconButton(
            tooltip: 'Inicio',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: vm.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final Noticia n = vm.items[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/noticias/detalle', extra: n),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (n.coverUrl != null && n.coverUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(n.coverUrl!, fit: BoxFit.cover),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.titulo, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 6),
                              Text(
                                n.resumen,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: n.tags
                                    .map((t) => Chip(
                                          label: Text('#$t'),
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _fmtFecha(n.fecha),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: c.outline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _fmtFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
