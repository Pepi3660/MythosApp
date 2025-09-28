//Vista de los relatos que se encuentran en la base de datos

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mythosapp/views/relatos/relatos_create_view.dart';
import 'package:provider/provider.dart';

import '../../models/relato.dart';
import '../../viewmodels/relatos_vm.dart';

class RelatosPage extends StatefulWidget {
  const RelatosPage({super.key});
  @override
  State<RelatosPage> createState() => _RelatosPageState();
}

class _RelatosPageState extends State<RelatosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<RelatosVM>();
      if (vm.relatos.isEmpty && !vm.cargando) vm.cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelatosVM>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Relatos')),
      body: RefreshIndicator(
        onRefresh: () => vm.cargar(),
        child: vm.cargando
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) => _RelatoCard(r: vm.relatos[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: vm.relatos.length,
              ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const RelatoNuevoPage()),
          );
          if (created == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Relato creado')),
            );
          }
        },
        backgroundColor: cs.secondary,
        child: Icon(Icons.add, color: cs.onSecondary),
      ),
    );
  }
}

class _RelatoCard extends StatelessWidget {
  final Relato r;
  const _RelatoCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fecha = DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
        .add_Hm()
        .format(r.fechaCreacion);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fecha, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (r.tipoP == 'texto')
              Text(r.contenido, style: Theme.of(context).textTheme.bodyLarge)
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: r.contenido,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (_, __, ___) =>
                      Container(color: cs.surfaceVariant, child: const Icon(Icons.broken_image)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}