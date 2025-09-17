import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/relato.dart';

class RelatoDetailView extends StatelessWidget {
  final Relato relato;
  const RelatoDetailView({super.key, required this.relato});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(relato.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(Icons.place, color: cs.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${relato.municipio}${relato.barrio != null ? " • ${relato.barrio}" : ""}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if ((relato.cuerpo ?? '').isNotEmpty)
            Text(relato.cuerpo!),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              Chip(label: Text(relato.tipo)),
              ...relato.tags.map((t) => Chip(label: Text('#$t'))),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${relato.lat},${relato.lng}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.directions_outlined),
            label: const Text('Cómo llegar'),
          ),
        ],
      ),
    );
  }
}
