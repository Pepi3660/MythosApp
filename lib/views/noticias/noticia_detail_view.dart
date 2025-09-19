import 'package:flutter/material.dart';
import '../../models/noticia.dart';

class NoticiaDetailView extends StatelessWidget {
  final Noticia noticia;
  const NoticiaDetailView({super.key, required this.noticia});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final bodyText = (noticia.contenido.isNotEmpty)
        ? noticia.contenido
        : noticia.resumen;

    return Scaffold(
      appBar: AppBar(
        title: Text(noticia.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (noticia.coverUrl != null && noticia.coverUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(noticia.coverUrl!, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Text(
            _fmtFecha(noticia.fecha),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.outline),
          ),
          const SizedBox(height: 8),
          Text(noticia.resumen, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(bodyText, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: noticia.tags.map((t) => Chip(label: Text('#$t'))).toList(),
          ),
        ],
      ),
    );
  }

  String _fmtFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
