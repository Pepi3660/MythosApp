// lib/views/mapa/mapa_view.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

//import '../../data/categorias.dart';
//import '../../data/geo_ni.dart';
import '../../models/relato.dart';
import '../../viewmodels/relatos_vm.dart';
import '../../widgets/permission_guard.dart';
//import 'mapaTarget.dart';

class MapaView extends StatefulWidget {
  final MapaTarget? initial; // opcional, si ya la tienes
  const MapaView({super.key, this.initial});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  // Mapa
  static const _niDefault = LatLng(12.1364, -86.2514);
  GoogleMapController? _gm;
  MapType _mapType = MapType.normal;

  //Estado
  LatLng? _myPos;
  Relato? _selected;

  // Filtros
  // final Set<String> _catActivas = {...kCategorias}; // si tuvieras categorías
  String? _dep;
  String? _muni;

  // Marcador temporal para destinos externos
  Marker? _tempMarker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<RelatosVM>();
      if (vm.relatos.isEmpty && !vm.cargando) vm.cargar();
    });
    _initLocation();

    // Si recibimos un destino inicial, preparamos el marcador temporal
    if (widget.initial != null) {
      final t = widget.initial!;
      _tempMarker = Marker(
        markerId: const MarkerId('destino-externo'),
        position: LatLng(t.lat, t.lng),
        infoWindow: InfoWindow(title: t.title, snippet: t.snippet),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        await _moveTo(LatLng(t.lat, t.lng), zoom: 15);
      });
    }
  }

  Future<void> _initLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) return;

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() => _myPos = LatLng(pos.latitude, pos.longitude));
    } catch (_) {/* no-op */}
  }

  Future<void> _moveTo(LatLng target, {double zoom = 14}) async {
    if (_gm == null) return;
    await _gm!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: zoom),
    ));
  }

  Future<void> _goToMyLocation() async {
    if (_myPos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener tu ubicación')),
      );
      return;
    }
    await _moveTo(_myPos!, zoom: 16);
  }

  Future<void> _openDirections(Relato r) async {
    final gp = r.ubicacion;
    if (gp == null) return;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${gp.latitude},${gp.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // Filtros (sheet) - por ahora sin lógica real
  Future<void> _openFilterSheet() async {
    final currentDep = _dep;
    final currentMuni = _muni;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        String? tmpDep = currentDep;
        String? tmpMuni = currentMuni;
        final cs = Theme.of(ctx).colorScheme;

        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: .78,
            minChildSize: .5,
            maxChildSize: .95,
            expand: false,
            builder: (_, controller) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ListView(
                controller: controller,
                children: [
                  Text(
                    'Filtros',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Departamento (placeholder)
                  Text(
                    'Departamento',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: tmpDep,
                    hint: const Text('Todos'),
                    items: const [
                      DropdownMenuItem<String>(value: null, child: Text('Todos')),
                    ],
                    onChanged: (v) => tmpDep = v,
                  ),

                  const SizedBox(height: 12),
                  // Municipio (placeholder)
                  Text(
                    'Municipio',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: tmpMuni,
                    hint: const Text('Todos'),
                    items: const [
                      DropdownMenuItem<String>(value: null, child: Text('Todos')),
                    ],
                    onChanged: (v) => tmpMuni = v,
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          tmpDep = null;
                          tmpMuni = null;
                          (ctx as Element).markNeedsBuild();
                        },
                        icon: const Icon(Icons.clear_all_rounded),
                        label: Text(
                          'Limpiar',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _dep = tmpDep;
                            _muni = tmpMuni;
                          });
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.filter_alt_rounded),
                        label: Text(
                          'Aplicar',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Capas (map type)
  Future<void> _openLayersSheet() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<MapType>(
                value: MapType.normal,
                groupValue: _mapType,
                onChanged: (v) => setState(() => _mapType = v!),
                title: const Text('Normal'),
              ),
              RadioListTile<MapType>(
                value: MapType.hybrid,
                groupValue: _mapType,
                onChanged: (v) => setState(() => _mapType = v!),
                title: const Text('Satélite (Hybrid)'),
              ),
              RadioListTile<MapType>(
                value: MapType.terrain,
                groupValue: _mapType,
                onChanged: (v) => setState(() => _mapType = v!),
                title: const Text('Terreno'),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      featureName: 'mapa',
      customTitle: 'Mapa Interactivo Bloqueado',
      customMessage: 'Para usar el mapa interactivo y ver los relatos geolocalizados, necesitas otorgar permiso de ubicación.',
      customIcon: Icons.map_outlined,
      child: _buildMapContent(context),
    );
  }

  Widget _buildMapContent(BuildContext context) {
    final vm = context.watch<RelatosVM>();
    final cs = Theme.of(context).colorScheme;

    // Dataset: SOLO relatos con ubicación
    final base = vm.relatos.where((r) => r.ubicacion != null).toList();

    // Filtros (por ahora no se aplican, porque el modelo Relato actual no tiene dep/muni/categorías)
    final filtered = base;

    final start = filtered.isNotEmpty
        ? LatLng(filtered.first.ubicacion!.latitude, filtered.first.ubicacion!.longitude)
        : _niDefault;

    // Marcadores
    final markers = <Marker>{
      for (final r in filtered)
        Marker(
          markerId: MarkerId(r.idP),
          position: LatLng(r.ubicacion!.latitude, r.ubicacion!.longitude),
          onTap: () => setState(() => _selected = r),
          infoWindow: InfoWindow(
            title: r.tipoP == 'texto' ? 'Relato (texto)' : 'Relato (imagen)',
            snippet: _buildSnippet(r),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            r.tipoP == 'texto' ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueViolet,
          ),
        ),
      if (_myPos != null)
        Marker(
          markerId: const MarkerId('me'),
          position: _myPos!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      if (_tempMarker != null) _tempMarker!,
    };

    return Scaffold(
      body: Stack(
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

          // Header superpuesto
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  Material(
                    color: cs.surface.withValues(alpha: .92),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      tooltip: 'Volver',
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded, size: 20, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Mapa de memorias',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Botonera flotante derecha
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
                  onTap: () => _openListBottomSheet(filtered),
                ),
                const SizedBox(height: 12),
                _RoundFab(
                  tooltip: 'Filtros',
                  icon: Icons.filter_alt_outlined,
                  onTap: _openFilterSheet,
                ),
                const SizedBox(height: 12),
                _RoundFab(
                  tooltip: 'Capas',
                  icon: Icons.layers_outlined,
                  onTap: _openLayersSheet,
                ),
              ],
            ),
          ),

          // Barra de acciones (si hay selección)
          _ActionBar(
            visible: _selected != null,
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

          // Aviso si no hay datos
          if (filtered.isEmpty)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 64),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: .96),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                    boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
                  ),
                  child: const Text('No hay relatos con ubicación'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _buildSnippet(Relato r) {
    if (r.tipoP == 'texto') {
      final txt = r.contenido.trim();
      if (txt.isEmpty) return 'Relato de texto';
      return txt.length <= 60 ? txt : '${txt.substring(0, 60)}…';
    } else {
      return 'Relato con imagen';
    }
  }

  //Lista (bottom sheet)
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
            initialChildSize: 0.78,
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
                        final gp = items[i].ubicacion!;
                        _moveTo(LatLng(gp.latitude, gp.longitude), zoom: 15);
                        setState(() => _selected = items[i]);
                      },
                      onVer: () {
                        Navigator.pop(context);
                        context.push('/relatos', extra: items[i]);
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
      bottom: visible ? 16 + MediaQuery.of(context).viewPadding.bottom : -140,
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
                    tooltip: 'Cerrar',
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
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
    final tipo = r.tipoP == 'texto' ? 'Texto' : 'Imagen';
    final snippet = r.tipoP == 'texto'
        ? (r.contenido.length <= 80 ? r.contenido : '${r.contenido.substring(0, 80)}…')
        : 'Relato con imagen';

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
          Text(tipo, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(snippet, maxLines: 2, overflow: TextOverflow.ellipsis),
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

// (Opcional) si usas un tipo MapaTarget
class MapaTarget {
  final double lat;
  final double lng;
  final String? title;
  final String? snippet;
  MapaTarget({required this.lat, required this.lng, this.title, this.snippet});
}