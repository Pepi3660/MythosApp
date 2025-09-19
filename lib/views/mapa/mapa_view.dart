import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/relato.dart';
import '../../viewmodels/relatos_vm.dart';

MapType _mapType = MapType.normal;

class MapaView extends StatefulWidget {
  const MapaView({super.key});
  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  static const _niDefault = LatLng(12.1364, -86.2514);
  GoogleMapController? _gm;
  LatLng? _myPos;

  // Filtros (no nulos con “Todos”)
  String _catSel = 'Todos';
  String _depSel = 'Todos';
  String _muniSel = 'Todos';

  static const List<String> _categorias = <String>[
    'Todos', 'Historia', 'Relato', 'Danza', 'Mito', 'Gastronomía', 'Música'
  ];

  Relato? _selected;

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
      if (!mounted) return;
      setState(() => _myPos = LatLng(pos.latitude, pos.longitude));
    } catch (_) {/* ignore */}
  }

  Future<void> _moveTo(LatLng target, {double zoom = 14}) async {
    final c = _gm;
    if (c == null) return;
    await c.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)));
  }

  Future<void> _goToMyLocation() async {
    if (_myPos == null) {
      if (!mounted) return;
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

  bool _matchCategoria(Relato r) {
    if (_catSel == 'Todos') return true;
    final t = _catSel.toLowerCase();
    return r.tags.map((e) => e.toLowerCase()).contains(t);
  }

  bool _matchDep(Relato r) => _depSel == 'Todos' || r.departamento == _depSel;
  bool _matchMuni(Relato r) => _muniSel == 'Todos' || r.municipio == _muniSel;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelatosVM>();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

 
    final Set<String> depsSet = vm.relatos
        .map((r) => r.departamento)
        .whereType<String>()                 // <- elimina nulos
        .toSet();
    final List<String> deps = ['Todos', ...(depsSet.toList()..sort())];

    final Set<String> muniSet = vm.relatos
        .where((e) => _depSel == 'Todos' || e.departamento == _depSel)
        .map((e) => e.municipio)
        .whereType<String>()                 // <- elimina nulos
        .toSet();
    final List<String> munis = ['Todos', ...(muniSet.toList()..sort())];


    // dataset filtrado
    final List<Relato> filtered = vm.relatos
        .where((r) => r.lat != null && r.lng != null && _matchCategoria(r) && _matchDep(r) && _matchMuni(r))
        .toList();

    final LatLng start = filtered.isNotEmpty
        ? LatLng(filtered.first.lat!, filtered.first.lng!)
        : (_myPos ?? _niDefault);

    final markers = <Marker>{
      for (final r in filtered)
        Marker(
          markerId: MarkerId(r.id),
          position: LatLng(r.lat!, r.lng!),
          infoWindow: InfoWindow(
            title: r.titulo,
            snippet: '${r.autorNombre} • ${r.municipio}${r.barrio != null ? " • ${r.barrio}" : ""}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () => _showActionBar(r),
        ),
      if (_myPos != null)
        Marker(
          markerId: const MarkerId('me'),
          position: _myPos!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
    };

    return Scaffold(
      body: Column(
        children: [
          // Encabezado con volver + título + botón de filtros
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Material(
                  color: cs.surface,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      final r = GoRouter.of(context);
                      if (r.canPop()) r.pop(); else context.go('/home');
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Mapa de memorias',
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtrar'),
                  onPressed: () => _openFiltersSheet(deps, munis),
                ),
              ],
            ),
          ),

          // Mapa
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
                  mapType: _mapType,
                ),

                // Botones flotantes
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
                    ],
                  ),
                ),

                if (filtered.isEmpty)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: .96),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
                      ),
                      child: const Text('No hay relatos para los filtros actuales'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- Sheets & barras
  void _showActionBar(Relato r) {
    setState(() => _selected = r);
    _openActionBar();
  }

  Future<void> _openActionBar() async {
    final r = _selected;
    if (r == null || !mounted) return;
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.titulo, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${r.autorNombre} • ${r.municipio}${r.barrio != null ? " • ${r.barrio}" : ""}'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _openDirections(r),
                        icon: const Icon(Icons.directions_outlined),
                        label: const Text('Cómo llegar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.push('/relatos/detalle', extra: r),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Ver más'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

  Future<void> _openFiltersSheet(List<String> deps, List<String> munis) async {
    final cs = Theme.of(context).colorScheme;
    if (!mounted) return;

    String catTemp = _catSel;
    String depTemp = _depSel;
    String muniTemp = _muniSel;

    await showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSh) {
          // munis dependientes del dep temp (mismo fix Set -> List)
          final Set<String> muniSetLocal = context.read<RelatosVM>().relatos
          .where((e) => depTemp == 'Todos' || e.departamento == depTemp)
          .map((e) => e.municipio)
          .whereType<String>()                 // <- clave
          .toSet();
          final List<String> munisLocal = ['Todos', ...(muniSetLocal.toList()..sort())];


          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FilterRow(
                    label: 'Categoría',
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: catTemp,
                      items: _categorias
                          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setSh(() => catTemp = v ?? 'Todos'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FilterRow(
                    label: 'Departamento',
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: depTemp,
                      items: deps
                          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setSh(() {
                          depTemp = v ?? 'Todos';
                          muniTemp = 'Todos';
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FilterRow(
                    label: 'Municipio',
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: muniTemp,
                      items: munisLocal
                          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setSh(() => muniTemp = v ?? 'Todos'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            if (!mounted) return;
                            setState(() {
                              _catSel = 'Todos';
                              _depSel = 'Todos';
                              _muniSel = 'Todos';
                            });
                          },
                          child: const Text('Limpiar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            if (!mounted) return;
                            setState(() {
                              _catSel = catTemp;
                              _depSel = depTemp;
                              _muniSel = muniTemp;
                            });
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

// ------- Widgets auxiliares

class _FilterRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FilterRow({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelLarge),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: child,
          ),
        ),
      ],
    );
  }
}

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
