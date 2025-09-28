// Tarjeta compacta para listar un evento en la vista del calendario.
// Muestra portada (si existe), nombre, fecha, lugar y tipo.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/eventos.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback? onTap;

  const EventoCard({super.key, required this.evento, this.onTap});

  @override
  Widget build(BuildContext context) {
    //Construccion de los elementos de la letra yformato de fecha y localizacion
    final scheme = Theme.of(context).colorScheme;
    final dt = DateFormat('EEE d MMM, HH:mm',
            Localizations.localeOf(context).languageCode)
        .format(evento.fecha);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight( //asegura que ambos lados tengan la misma altura
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // estira hijos verticalmente
            children: [
              // -------- Imagen lateral que se estira --------
              if (evento.portada != null && evento.portada!.isNotEmpty)
                SizedBox(
                  width: 140, // ancho fijo, alto se ajusta al de la tarjeta
                  child: (evento.portada != null && evento.portada!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: evento.portada!, // URL guardada en Firestore
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: scheme.surfaceVariant,
                          //child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        color: scheme.surfaceVariant,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                )
              else
                Container(
                  width: 140,
                  color: scheme.surfaceVariant,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),

              // -------- Texto --------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        evento.nombreE,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.event, size: 18, color: scheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dt,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.place, size: 18, color: scheme.tertiary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${evento.nombreLugar} · ${evento.municipio}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: -6,
                        children: [Chip(label: Text(evento.tipoEvento))],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
