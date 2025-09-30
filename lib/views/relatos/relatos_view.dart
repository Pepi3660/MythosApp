//Vista de los relatos que se encuentran en la base de datos

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Carga inicial del feed de relatos
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
      appBar: AppBar(title: const Text('Relatos Publicados')),
      body: RefreshIndicator(
        onRefresh: () => vm.cargar(),
        child: vm.cargando
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vm.relatos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _RelatoCard(r: vm.relatos[i]),
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

// Tarjeta de Relato

class _RelatoCard extends StatefulWidget {
  final Relato r;
  const _RelatoCard({required this.r});

  @override
  State<_RelatoCard> createState() => _RelatoCardState();
}

class _RelatoCardState extends State<_RelatoCard> {
  final _comentCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comentCtrl.dispose();
    super.dispose();
  }

  // Envía un comentario usando el VM
  Future<void> _enviarComentario(BuildContext context) async {
    final texto = _comentCtrl.text.trim();
    if (texto.isEmpty) return;
    setState(() => _sending = true);
    try {
      await context.read<RelatosVM>().crearComentario(
            idRelato: widget.r.idP!,
            texto: texto,
          );
      _comentCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al comentar: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final fecha = DateFormat.yMMMd(locale).add_Hm().format(r.fechaCreacion);

    final userRef = r.idU as DocumentReference<Map<String, dynamic>>?;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: avatar + nombre + título
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: userRef?.get(),
              builder: (ctx, snap) {
                final data = snap.data?.data();
                final nombre = (data?['nombre'] ?? 'Anónimo').toString();
                final fotoUrl = (data?['fotoUrl'] ?? '').toString();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Avatar(fotoUrl: fotoUrl),
                    const SizedBox(width: 10),
                    Flexible( //evita forzar ancho si el contenedor es estrecho
                      fit: FlexFit.loose,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.titulo,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 8),

            // Fecha + municipio + categoría
            Wrap(
              spacing: 12,
              runSpacing: -8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(
                      fecha,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(.8),
                          ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: cs.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      r.municipio,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(.8),
                          ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(r.categoria),
                  side: BorderSide(color: cs.outlineVariant),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Contenido
            if (r.tipoP == 'texto')
              Text(
                r.contenido,
                style: Theme.of(context).textTheme.bodyLarge,
              )
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

            const SizedBox(height: 12),

            // Acciones: like + contador
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final ref = FirebaseFirestore.instance
                        .collection('Publicaciones')
                        .doc(r.idP);
                    await ref.set(
                      {'likes': FieldValue.increment(1)},
                      SetOptions(merge: true),
                    );
                  },
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  label: const Text('Me gusta'),
                ),
                const SizedBox(width: 10),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Publicaciones')
                      .doc(r.idP)
                      .snapshots(),
                  builder: (ctx, snap) {
                    final likesRaw = snap.data?.data()?['likes'];
                    final likes = (likesRaw is int)
                        ? likesRaw
                        : (likesRaw is num ? likesRaw.toInt() : 0);
                    return Text(
                      '$likes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(.8),
                            fontWeight: FontWeight.w600,
                          ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Lista de comentarios
            _ComentariosList(idP: r.idP!),

            const SizedBox(height: 12),

            // Form para comentar
            Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: TextField(
                    controller: _comentCtrl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : () => _enviarComentario(context),
                  icon: _sending
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//Lista de comentarios

class _ComentariosList extends StatelessWidget {
  final String idP; // id del documento en "Publicaciones"
  const _ComentariosList({required this.idP});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final query = FirebaseFirestore.instance
        .collection('Publicaciones')
        .doc(idP)
        .collection('Comentarios')
        .orderBy('FechaComentario', descending: false);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snap.hasError) {
          return Text(
            'No se pudieron cargar los comentarios',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.error),
          );
        }

        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) {
          return Text(
            'Sé el primero en comentar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(.6),
                ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _ComentarioTile(data: docs[i].data()),
        );
      },
    );
  }
}

//Ítem de comentario

class _ComentarioTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ComentarioTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    final texto = (data['Texto'] ?? '').toString();
    final ts = data['FechaComentario'];
    final fecha = (ts is Timestamp)
        ? DateFormat.yMMMd(locale).add_Hm().format(ts.toDate())
        : '';

    final ref = data['iDU'];
    final DocumentReference<Map<String, dynamic>>? userRef =
        ref is String
            ? FirebaseFirestore.instance.collection('usuarios').doc(ref)
            : (ref is DocumentReference<Map<String, dynamic>> ? ref : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: userRef?.get(),
          builder: (ctx, snap) {
            final foto = (snap.data?.data()?['fotoUrl'] ?? '').toString();
            return _Avatar(fotoUrl: foto, radius: 14);
          },
        ),
        const SizedBox(width: 8),
        Flexible(
          fit: FlexFit.loose, //Evita expandirse infinito
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: userRef?.get(),
                  builder: (ctx, snap) {
                    final nombre = (snap.data?.data()?['nombre'] ?? 'usuarios').toString();
                    return Text(
                      nombre,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(texto),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.schedule, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      fecha,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cs.onSurface.withOpacity(.6),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//Avatar

class _Avatar extends StatelessWidget {
  final String fotoUrl;
  final double radius;
  const _Avatar({required this.fotoUrl, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (fotoUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: cs.primary.withOpacity(.15),
        child: Icon(Icons.person, size: radius, color: cs.primary),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: cs.surfaceVariant,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: fotoUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (_, __, ___) =>
              Icon(Icons.person, size: radius, color: cs.primary),
        ),
      ),
    );
  }
}