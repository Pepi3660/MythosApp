import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/relato.dart';

class RelatoCard extends StatelessWidget {
  final Relato relato;
  const RelatoCard({super.key, required this.relato});

  @override
  Widget build(BuildContext context) {
    final f = DateFormat.yMMMd().add_Hm();
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(relato.titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place, size: 16),
                const SizedBox(width: 4),
                Text(relato.municipio),
                const Spacer(),
                Text(f.format(relato.fechaCreacion),
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            if ((relato.cuerpo ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(relato.cuerpo!, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                Chip(label: Text(relato.tipo)),
                ...relato.tags.map((t) => Chip(label: Text('#$t'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
