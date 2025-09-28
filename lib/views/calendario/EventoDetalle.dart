// Pantalla de detalles de un evento.
// Carga el documento por id y muestra información extendida.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/eventos.dart';
import '../../services/eventoService.dart';
import '../mapa/mapaTarget.dart';

class EventoDetallePage extends StatefulWidget {
  final String eventoId; // id del doc o IdE (según repositorio)
  const EventoDetallePage({super.key, required this.eventoId});

  @override
  State<EventoDetallePage> createState() => _EventoDetallePageState();
}

class _EventoDetallePageState extends State<EventoDetallePage> {
  late Future<Evento> _future; // future para el FutureBuilder

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtenemos el servicio inyectado vía Provider
    final service = context.read<EventoService>();
    _future = service.detalle(widget.eventoId);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Evento')),
      body: FutureBuilder<Evento>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            // Indicador de carga
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            // Estado de error
            return const Center(child: Text('No se pudo cargar el evento'));
          }

          final e = snap.data!;
          // Formato de fecha larga + hora, con localización
          final fechaFmt = DateFormat.yMMMMEEEEd(
                  Localizations.localeOf(context).languageCode)
              .add_Hm()
              .format(e.fecha);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de portada (si existe)
                if (e.portada != null && e.portada!.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: e.portada!,
                      fit: BoxFit.cover,
                    ),
                  ),
                // Cuerpo de contenido
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título destacado
                      Text(e.nombreE,
                          style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 8),
                      // Chips con metadatos principales
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(icon: Icons.event, label: fechaFmt),
                          _InfoChip(
                            icon: Icons.place,
                            label: '${e.nombreLugar} · ${e.municipio}',
                          ),
                          if (e.tipoEvento.isNotEmpty)
                            _InfoChip(icon: Icons.category, label: e.tipoEvento),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Sección de descripción
                      Text('Acerca del evento',
                          style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 8),
                      Text(e.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),

                      // Botón para abrir ubicación en Google Maps
                      if (e.ubicacionCoordenadas != null)
                          FilledButton.icon(
                            onPressed: () {
                              final lat = e.ubicacionCoordenadas!.latitude;
                              final lng = e.ubicacionCoordenadas!.longitude;
                              final target = MapaTarget(
                                lat: lat,
                                lng: lng,
                                title: e.nombreE,
                                snippet: '${e.nombreLugar} · ${e.municipio}',
                              );
                             // go_router
                              context.push('/mapa', extra: target);
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('Ver en el mapa'),
                          ),
                      const SizedBox(height: 24),

                      // Información básica del organizador (id de ref)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: scheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  e.organizador != null
                                      ? 'Organizador: ${e.organizador}'
                                      : 'Organizador no especificado',
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Chip reutilizable con icono + texto para metadatos.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(label),
    );
  }
}
