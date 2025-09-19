import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/relatos_vm.dart';
import '../../models/relato.dart';

class RelatosView extends StatelessWidget {
  const RelatosView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelatosVM>();
    final relatos = vm.relatos; // usa el arreglo disponible en el VM

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatos'),
        actions: [
          IconButton(
            tooltip: 'Inicio',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/relatos/crear'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: relatos.length,
        itemBuilder: (_, i) {
          final r = relatos[i];
          return _RelatoTile(relato: r, onTap: () {
            context.push('/relatos/detalle', extra: r);
          });
        },
      ),
    );
  }
}

class _RelatoTile extends StatelessWidget {
  const _RelatoTile({required this.relato, required this.onTap});
  final Relato relato;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      tileColor: theme.colorScheme.surface,
      onTap: onTap,
      title: Text(relato.titulo, style: theme.textTheme.titleMedium),
      subtitle: Text(
        (relato.cuerpo ?? '').isEmpty ? '—' : relato.cuerpo!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
