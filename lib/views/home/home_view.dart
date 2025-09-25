import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/responsive_utils.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final items = <_HomeItem>[
      _HomeItem('Relatos', Icons.menu_book_outlined, '/relatos', 'Comparte historias de tu comunidad'),
      _HomeItem('Mapa', Icons.map_outlined, '/mapa', 'Explora memorias geolocalizadas'),
      _HomeItem('Calendario', Icons.event_outlined, '/calendario', 'Eventos culturales y festividades'),
      _HomeItem('Biblioteca', Icons.local_library_outlined, '/biblioteca', 'Saberes populares y tradiciones'),
      _HomeItem('Juegos', Icons.extension_outlined, '/juegos', 'Retos didácticos sobre identidad'),
      _HomeItem('Perfil', Icons.person_outlined, '/perfil', 'Tu información y estadísticas'),
      _HomeItem('Buscar', Icons.search_outlined, '/search', 'Encuentra contenido específico'),
      _HomeItem('Configuración', Icons.settings_outlined, '/settings', 'Ajustes y privacidad'),
    ];

    // TODO: Reemplaza por el nombre real desde tu VM/usuario autenticado
    const nombreUsuario = 'Visitante';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MythosApp',
          style: GoogleFonts.playfairDisplay(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Hola, $nombreUsuario 👋',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '¿Qué te gustaría explorar hoy?',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sección destacada
                  _buildFeaturedSection(context),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Explorar Módulos',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Grid responsive de módulos
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveUtils.responsiveValue(
                  context: context,
                  mobile: 2,
                  tablet: 3,
                  desktop: 4,
                ),
                mainAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
                crossAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
                childAspectRatio: ResponsiveUtils.responsiveValue(
                  context: context,
                  mobile: 1.0,
                  tablet: 1.1,
                  desktop: 1.2,
                ),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _HomeCard(item: items[index]),
                childCount: items.length,
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final IconData icon;
  final String route;
  final String description;
  const _HomeItem(this.title, this.icon, this.route, this.description);
}

class _HomeCard extends StatelessWidget {
  final _HomeItem item;
  const _HomeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      elevation: 2,
      shadowColor: scheme.shadow.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(item.route),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                scheme.primary.withOpacity(0.05),
                scheme.tertiary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      size: isMobile ? 24 : 28,
                      color: scheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: scheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.title,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              if (!isMobile)
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
   }
}

// Método helper para la sección destacada
Widget _buildFeaturedSection(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          scheme.primary,
          scheme.primary.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🇳🇮 Memoria Viva Nicaragua',
          style: GoogleFonts.playfairDisplay(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preserva, registra y comparte los saberes populares y tradiciones de nuestro pueblo.',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.go('/relatos/crear'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: scheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Compartir Relato',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}