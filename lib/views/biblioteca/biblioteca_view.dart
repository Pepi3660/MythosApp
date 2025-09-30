import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/relato.dart';
import '../../viewmodels/relatos_vm.dart';

class BibliotecaView extends StatelessWidget {
  const BibliotecaView({super.key});

  // Palabras clave que clasifican un relato como entrada de biblioteca
  static const _keys = ['receta', 'gastronomía', 'costumbre', 'artesanía', 'saber'];

  bool _isBibliEntry(Relato r) {
    if (r.tipoP != 'texto') return false; // biblioteca solo texto
    final text = r.contenido.toLowerCase();
    return _keys.any((k) => text.contains(k));
  }

  List<String> _extractTags(Relato r) {
    final text = r.contenido.toLowerCase();
    return _keys.where((k) => text.contains(k)).toList();
  }

  String _titleFromContent(String content) {
    final t = content.trim();
    if (t.isEmpty) return 'Relato cultural';
    // primera línea o hasta el primer punto. Luego recorta a 60–80 chars.
    final firstBreak = t.indexOf('\n');
    final firstDot = t.indexOf('.');
    int cut = t.length;
    if (firstDot > 0) cut = firstDot + 1;
    if (firstBreak > 0) cut = cut < firstBreak ? cut : firstBreak;
    final head = t.substring(0, cut).trim();
    return head.length <= 80 ? head : '${head.substring(0, 80)}…';
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
            if (r.canPop()) {
              context.pop();
            } else {
              context.go('/app');
            }
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
        ),
        title: const Text('Biblioteca colaborativa'),
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : (list.isEmpty
              ? const Center(child: Text('Aún no hay relatos de biblioteca'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = list[i];
                    final title = _titleFromContent(r.contenido);
                    final tags = _extractTags(r);
                    final fecha = DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                        .add_Hm()
                        .format(r.fechaCreacion);

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
                          Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(fecha, style: Theme.of(context).textTheme.bodySmall),

                          // Extracto del contenido
                          const SizedBox(height: 8),
                          Text(
                            r.contenido,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Chips de palabras clave encontradas
                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: -6,
                              children: tags.map((t) => Chip(label: Text('#$t'))).toList(),
                            ),
                          ],

                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: () => context.push('/relatos', extra: r),
                              icon: const Icon(Icons.menu_book_outlined),
                              label: const Text('Leer'),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )),
    );
  }
}
