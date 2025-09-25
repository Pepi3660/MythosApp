import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/relatos_vm.dart';
import '../../models/relato.dart';
import 'package:go_router/go_router.dart';

class BibliotecaView extends StatelessWidget {
  const BibliotecaView({super.key});

  bool _isBibliEntry(Relato r) {
    // Ajusta a tus tags reales
    const keys = ['receta', 'gastronomía', 'costumbre', 'artesanía', 'saber'];
    final all = r.tags.map((t) => t.toLowerCase()).toList();
    return all.any(keys.contains);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelatosVM>();
    final cs = Theme.of(context).colorScheme;
    final list = vm.relatos.where(_isBibliEntry).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            final r = GoRouter.of(context);
            if (r.canPop()) context.pop(); else context.go('/home');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
        ),
        title: const Text('Biblioteca colaborativa'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = list[i];
          return Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.titulo, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${r.autorNombre} • ${r.municipio}', style: Theme.of(context).textTheme.bodySmall),
                if ((r.cuerpo ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(r.cuerpo!, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: -6,
                  children: [
                    ...r.tags.map((t) => Chip(label: Text('#$t'))),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/relatos/detalle', extra: r),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Leer'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
