import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../home/home_view.dart';
import '../search/search_view.dart';
import '../mapa/mapa_view.dart';
import '../perfil/perfil_view.dart';
import '../../widgets/mythos_nav_bar.dart';

class AppShell extends StatefulWidget {
  final Widget? child;
  final bool showFixedNavigation;
  final int initialIndex;
  
  const AppShell({
    super.key, 
    this.child,
    this.showFixedNavigation = true,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _views = [
    const HomeView(),
    const SearchView(),
    const MapaView(),
    const PerfilView(),
  ];

  @override
  Widget build(BuildContext context) {
    final appBar = _buildAppBar(context);
    
    return Scaffold(
      appBar: appBar,
      body: widget.child ?? AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: IndexedStack(
          key: ValueKey(_currentIndex),
          index: _currentIndex,
          children: _views,
        ),
      ),
      bottomNavigationBar: widget.showFixedNavigation ? SafeArea(
        child: _buildBottomNavigation(),
      ) : null,
      extendBodyBehindAppBar: appBar != null,
    );
  }
  
  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    
    // Solo mostrar AppBar si hay botón de retroceso o configuraciones
    if (!canPop && !widget.showFixedNavigation) return null;
    
    // Si solo necesitamos el botón de configuración en la navegación principal, no mostrar AppBar
    if (!canPop && widget.showFixedNavigation) return null;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: canPop ? IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ) : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => context.go('/settings'),
        ),
      ],
    );
  }
  
  Widget _buildBottomNavigation() {
    return MythosNavBar(
      index: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        // Navegar a la ruta correspondiente
        switch (index) {
          case 0:
            context.go('/app');
            break;
          case 1:
            context.go('/search');
            break;
          case 2:
            context.go('/mapa');
            break;
          case 3:
            context.go('/perfil');
            break;
        }
      },
      items: const [
        MythosNavItem(icon: Icons.home, label: 'Inicio'),
        MythosNavItem(icon: Icons.search, label: 'Buscar'),
        MythosNavItem(icon: Icons.map, label: 'Mapa'),
        MythosNavItem(icon: Icons.person, label: 'Perfil'),
      ],
    );
  }
}
