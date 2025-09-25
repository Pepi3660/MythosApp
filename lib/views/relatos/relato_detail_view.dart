import 'package:flutter/material.dart';
import '../../models/relato.dart';
import 'package:go_router/go_router.dart';

class RelatoDetailView extends StatelessWidget {
  const RelatoDetailView({super.key, required this.relato});
  final Relato relato;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del relato'),
        actions: [
          IconButton(
            tooltip: 'Ver mapa',
            onPressed: () => context.go('/mapa'),
            icon: const Icon(Icons.map_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(relato.titulo, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(relato.autorNombre, style: theme.textTheme.labelLarge),
          const SizedBox(height: 16),
          if ((relato.cuerpo ?? '').isNotEmpty)
            Text(relato.cuerpo!),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: (relato.tags).map((t) => Chip(label: Text('#$t'))).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/mapa'),
            icon: const Icon(Icons.place_outlined),
            label: const Text('Ubicación en el mapa'),
          ),
        ],
      ),
    );
  }
}
