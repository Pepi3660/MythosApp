// lib/views/mapa/mapa_view.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/categorias.dart';
import '../../data/geo_ni.dart';
import '../../models/relato.dart';
import '../../viewmodels/relatos_vm.dart';
import '../../widgets/permission_guard.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});
  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  // ----------------- Mapa
  static const _niDefault = LatLng(12.1364, -86.2514);
  GoogleMapController? _gm;
  MapType _mapType = MapType.normal;

  // ----------------- Estado
  LatLng? _myPos;
  Relato? _selected;

  // Filtros reales
  final Set<String> _catActivas = {...kCategorias}; // todas activas por defecto
  String? _dep;
  String? _muni;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<RelatosVM>();
      if (vm.relatos.isEmpty && !vm.cargando) vm.cargar();
    });
    _initLocation();
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
    if (r.lat == null || r.lng == null) return;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${r.lat},${r.lng}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ----------------- Filtros (sheet)
  Future<void> _openFilterSheet() async {
    final currentDep = _dep;
    final currentMuni = _muni;
    final currentCats = Set<String>.from(_catActivas);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        String? tmpDep = currentDep;
        String? tmpMuni = currentMuni;
        final tmpCats = Set<String>.from(currentCats);

        final cs = Theme.of(ctx).colorScheme;

        List<String> munis(String? dep) =>
            dep == null ? const [] : (kMunicipiosByDep[dep] ?? const []);

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

                  // Categorías
                  Text(
                    'Categorías',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: -6,
                    children: [
                      for (final c in kCategorias)
                        FilterChip(
                          label: Text(c),
                          selected: tmpCats.contains(c),
                          onSelected: (sel) {
                            if (sel) {
                              tmpCats.add(c);
                            } else {
                              tmpCats.remove(c);
                            }
                            // forza rebuild del sheet
                            (ctx as Element).markNeedsBuild();
                          },
                          selectedColor: cs.primaryContainer,
                          checkmarkColor: cs.onPrimaryContainer,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Departamento
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
                    hint: const Text('Selecciona departamento'),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('Todos')),
                      ...kDepartamentos.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                    ],
                    onChanged: (v) {
                      tmpDep = v;
                      tmpMuni = null; // reset al cambiar dep
                    },
                  ),

                  const SizedBox(height: 12),
                  // Municipio (dependiente)
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
                    hint: const Text('Selecciona municipio'),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('Todos')),
                      ...munis(tmpDep).map((m) => DropdownMenuItem(value: m, child: Text(m))),
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
                          tmpCats
                            ..clear()
                            ..addAll(kCategorias);
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
                            _catActivas
                              ..clear()
                              ..addAll(tmpCats);
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

  // ----------------- Capas (map type)
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

    // Dataset con filtros
    final base = vm.relatos.where((r) => r.lat != null && r.lng != null).toList();
    final filtered = base.where((r) {
      // Categoría: hacemos match con tags o tipo interpretado (depende de tus datos)
      final matchCat = _catActivas.isEmpty
          ? true
          : (r.tags.any((t) => _catActivas.contains(_capitalize(t))) ||
              _catActivas.contains(_capitalize(r.tipo)));
      final matchDep = _dep == null ? true : (r.departamento == _dep || r.municipio == _dep);
      final matchMuni = _muni == null ? true : (r.municipio == _muni);
      return matchCat && matchDep && matchMuni;
    }).toList();

    final start = filtered.isNotEmpty
        ? LatLng(filtered.first.lat!, filtered.first.lng!)
        : _niDefault;

    // Marcadores
    final markers = <Marker>{
      for (final r in filtered)
        Marker(
          markerId: MarkerId(r.id),
          position: LatLng(r.lat!, r.lng!),
          onTap: () => setState(() => _selected = r),
          infoWindow: InfoWindow(
            title: r.titulo,
            snippet: '${r.autorNombre} • ${r.municipio}${(r.barrio != null && r.barrio!.isNotEmpty) ? " • ${r.barrio}" : ""}',
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
      // Sin AppBar: header superpuesto con volver + título
      body: Stack(
        children: [
          // Google Map
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
                  // Botón volver
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
                  // Título
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
                        Icon(
                          Icons.map_rounded,
                          size: 20,
                          color: cs.primary,
                        ),
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
                  child: const Text('No hay relatos para los filtros actuales'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Lista (bottom sheet)
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
                    tooltip: 'Volver',
                    onPressed: () {
                      final r = GoRouter.of(context);
                      if (r.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
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
          Text(
            '${r.autorNombre} • ${r.municipio}${(r.barrio != null && r.barrio!.isNotEmpty) ? " • ${r.barrio}" : ""}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if ((r.cuerpo ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r.cuerpo!, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: -6,
            children: [
              Chip(label: Text(_capitalize(r.tipo))),
              ...r.tags.map((t) => Chip(label: Text('#${_capitalize(t)}'))),
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

// helper
String _capitalize(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));