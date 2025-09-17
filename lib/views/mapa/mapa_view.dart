import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/relato.dart';
import '../../viewmodels/relatos_vm.dart';


MapType _mapType = MapType.normal;          // ✅ tipo de mapa
String? _municipioFilter;                   // ✅ filtro simple por municipio
final Set<String> _tiposActivos = {'texto','imagen','audio','video'};

class MapaView extends StatefulWidget {
  const MapaView({super.key});
  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  // --------- Estado base
  static const _niDefault = LatLng(12.1364, -86.2514);
  GoogleMapController? _gm;
  LatLng? _myPos;

  final Set<String> _tipos = {'texto', 'imagen', 'audio', 'video'};
  final Set<String> _activos = {'texto', 'imagen', 'audio', 'video'};

  // selección de relato (para barra de acciones / ficha)
  Relato? _selected;
  // “panel” de acciones visible?
  bool get _hasSelection => _selected != null;

  // --------- Init / permisos
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<RelatosVM>();
      if (vm.relatos.isEmpty && !vm.cargando) vm.cargar();
    });
    _trackLocation();
  }

  Future<void> _trackLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) return;

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _myPos = LatLng(pos.latitude, pos.longitude));
    } catch (_) {/*silencio*/}
  }

  // --------- Helpers UI
  Future<void> _moveTo(LatLng target, {double zoom = 14}) async {
    final c = _gm;
    if (c == null) return;
    await c.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)));
  }

  Future<void> _goToMyLocation() async {
    if (_myPos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener tu ubicación')),
      );
      return;
    }
    _moveTo(_myPos!, zoom: 16);
  }

  Future<void> _openDirections(Relato r) async {
    if (r.lat == null || r.lng == null) return;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${r.lat},${r.lng}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // --------- Construcción
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelatosVM>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // dataset filtrado
    final all = vm.relatos.where((r) => _activos.contains(r.tipo)).toList();
    final withCoords = all.where((r) => r.lat != null && r.lng != null).toList();
    final start = withCoords.isNotEmpty ? LatLng(withCoords.first.lat!, withCoords.first.lng!) : _niDefault;

    // Markers
    final markers = <Marker>{
      for (final r in withCoords)
        Marker(
          markerId: MarkerId(r.id),
          position: LatLng(r.lat!, r.lng!),
          onTap: () => setState(() => _selected = r),
          infoWindow: InfoWindow(
            title: r.titulo,
            snippet: '${r.autorNombre} • ${r.municipio}${r.barrio != null ? " • ${r.barrio}" : ""}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      if (_myPos != null)
        Marker(
          markerId: const MarkerId('me'),
          position: _myPos!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de memorias')),
      body: Column(
        children: [
          // --------- Fila de chips (alto contraste en claro/oscuro)
          Container(
            color: isDark ? cs.surfaceContainerHighest : cs.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                children: _tipos.map((t) {
                  final on = _activos.contains(t);
                  return FilterChip(
                    selected: on,
                    label: Text(t),
                    onSelected: (_) => setState(() => on ? _activos.remove(t) : _activos.add(t)),
                    selectedColor: cs.primaryContainer,
                    checkmarkColor: cs.onPrimaryContainer,
                    side: BorderSide(color: on ? Colors.transparent : cs.outlineVariant),
                    labelStyle: TextStyle(
                      color: on ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // --------- MAPA + overlays
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: start, zoom: 12),
                  markers: markers,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (c) => _gm = c,
                  onTap: (_) => setState(() => _selected = null),
                  mapType: _mapType,
                ),

                // Botonera flotante (siempre visible)
                Positioned(
                  right: 16,
                  bottom: 110 + MediaQuery.of(context).viewPadding.bottom,
                  child: Column(
                    children: [
                      _RoundFab(
                        tooltip: 'Centrar en mi ubicación',
                        icon: Icons.my_location,
                        onTap: _goToMyLocation,
                      ),
                      const SizedBox(height: 12),
                      _RoundFab(
                        tooltip: 'Listar relatos',
                        icon: Icons.list_alt,
                        onTap: () => _openListBottomSheet(withCoords),
                      ),
                    ],
                  ),
                ),

                // Barra de acciones (solo cuando hay selección)
                _ActionBar(
                  visible: _hasSelection,
                  relato: _selected,
                  onClose: () => setState(() => _selected = null),
                  onDirections: () {
                    final r = _selected;
                    if (r != null) _openDirections(r);
                  },
                  onMore: () {
                    final r = _selected;
                    if (r != null) context.push('/relatos/detalle', extra: r);
                  },
                ),

                if (withCoords.isEmpty)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(.96),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
                      ),
                      child: const Text('No hay relatos con ubicación para los filtros actuales'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // Nav inferior (igual a tu app)
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/relatos');
          if (i == 1) context.go('/mapa');
          if (i == 2) context.go('/calendario');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Relatos'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Calendario'),
        ],
      ),
    );
  }

  // ------- Lista en bottom-sheet (legible + acciones claras)
  Future<void> _openListBottomSheet(List<Relato> items) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('Relatos encontrados', style: Theme.of(context).textTheme.titleMedium),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemBuilder: (_, i) => _RelatoCardList(
                      r: items[i],
                      onMapa: () {
                        Navigator.pop(context);
                        _moveTo(LatLng(items[i].lat!, items[i].lng!), zoom: 15);
                        setState(() => _selected = items[i]);
                      },
                      onVer: () {
                        Navigator.pop(context);
                        context.push('/relatos/detalle', extra: items[i]);
                      },
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: items.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ====== UI widgets ======

class _RoundFab extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String tooltip;
  const _RoundFab({required this.onTap, required this.icon, required this.tooltip});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: cs.onPrimary),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool visible;
  final Relato? relato;
  final VoidCallback onClose;
  final VoidCallback onDirections;
  final VoidCallback onMore;
  const _ActionBar({
    required this.visible,
    required this.relato,
    required this.onClose,
    required this.onDirections,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      left: 16,
      right: 16,
      bottom: visible ? 16 + MediaQuery.of(context).viewPadding.bottom : -120,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 240),
          opacity: visible ? 1 : 0,
          child: Material(
            elevation: 8,
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: onDirections,
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text('Cómo llegar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onMore,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Ver más'),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    tooltip: 'Ocultar',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatoCardList extends StatelessWidget {
  final Relato r;
  final VoidCallback onMapa;
  final VoidCallback onVer;
  const _RelatoCardList({required this.r, required this.onMapa, required this.onVer});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.titulo, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('${r.autorNombre} • ${r.municipio}${r.barrio != null ? " • ${r.barrio}" : ""}',
              style: Theme.of(context).textTheme.bodySmall),
          if ((r.cuerpo ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r.cuerpo!, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: -6,
            children: [
              Chip(label: Text(r.tipo)),
              ...r.tags.map((t) => Chip(label: Text('#$t'))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(onPressed: onMapa, icon: const Icon(Icons.map_outlined), label: const Text('Mapa')),
              const Spacer(),
              FilledButton.icon(onPressed: onVer, icon: const Icon(Icons.chevron_right), label: const Text('Ver')),
            ],
          ),
        ],
      ),
    );
  }
}
