import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _selectedCategory = 'Todos';
  String _selectedFilter = 'Recientes';
  bool _isSearching = false;
  List<SearchResult> _searchResults = [];

  final List<String> _categories = [
    'Todos',
    'Relatos',
    'Eventos',
    'Recetas',
    'Tradiciones',
    'Lugares'
  ];

  final List<String> _filters = [
    'Recientes',
    'Populares',
    'Alfabético',
    'Más antiguos'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Datos de ejemplo
    _searchResults = [
      SearchResult(
        title: 'La Leyenda del Güegüense',
        subtitle: 'Teatro folklórico nicaragüense',
        category: 'Relatos',
        author: 'María González',
        date: '2 días',
        icon: Icons.theater_comedy,
        isPopular: true,
      ),
      SearchResult(
        title: 'Festival de Santo Domingo',
        subtitle: 'Celebración tradicional en Managua',
        category: 'Eventos',
        author: 'Carlos Mendoza',
        date: '1 semana',
        icon: Icons.festival,
        isPopular: true,
      ),
      SearchResult(
        title: 'Receta del Nacatamal',
        subtitle: 'Plato típico de la gastronomía nicaragüense',
        category: 'Recetas',
        author: 'Ana Pérez',
        date: '3 días',
        icon: Icons.restaurant,
        isPopular: false,
      ),
      SearchResult(
        title: 'Danza del Toro Huaco',
        subtitle: 'Tradición indígena de Masaya',
        category: 'Tradiciones',
        author: 'José Martínez',
        date: '5 días',
        icon: Icons.music_note,
        isPopular: true,
      ),
      SearchResult(
        title: 'Volcán Masaya',
        subtitle: 'Lugar sagrado y turístico',
        category: 'Lugares',
        author: 'Luis Hernández',
        date: '1 semana',
        icon: Icons.landscape,
        isPopular: false,
      ),
      SearchResult(
        title: 'El Cadejo',
        subtitle: 'Leyenda popular centroamericana',
        category: 'Relatos',
        author: 'Elena Rodríguez',
        date: '4 días',
        icon: Icons.pets,
        isPopular: true,
      ),
    ];
  }

  List<SearchResult> get _filteredResults {
    List<SearchResult> filtered = _searchResults;

    // Filtrar por categoría
    if (_selectedCategory != 'Todos') {
      filtered = filtered.where((result) => result.category == _selectedCategory).toList();
    }

    // Filtrar por texto de búsqueda
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((result) {
        return result.title.toLowerCase().contains(query) ||
               result.subtitle.toLowerCase().contains(query) ||
               result.author.toLowerCase().contains(query);
      }).toList();
    }

    // Aplicar filtro de ordenamiento
    switch (_selectedFilter) {
      case 'Populares':
        filtered.sort((a, b) => b.isPopular ? 1 : -1);
        break;
      case 'Alfabético':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Más antiguos':
        filtered = filtered.reversed.toList();
        break;
      default: // Recientes
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            _buildSearchBar(context),
            
            // Filtros y categorías
            _buildFiltersSection(context),
            
            // Resultados
            Expanded(
              child: _buildResultsSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.outline.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar relatos, eventos, tradiciones...',
                  hintStyle: GoogleFonts.poppins(
                    color: scheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: scheme.primary,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune),
              color: scheme.onPrimary,
              onPressed: () {
                _showFilterBottomSheet(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: scheme.surfaceVariant.withOpacity(0.3),
                    selectedColor: scheme.primary,
                    checkmarkColor: scheme.onPrimary,
                    side: BorderSide(
                      color: isSelected ? scheme.primary : scheme.outline.withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filteredResults = _filteredResults;
    
    if (filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: scheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros términos de búsqueda',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Header con contador y filtro
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredResults.length} resultado${filteredResults.length != 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
              DropdownButton<String>(
                value: _selectedFilter,
                underline: const SizedBox(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: scheme.primary,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: scheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                items: _filters.map((filter) {
                  return DropdownMenuItem(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        
        // Lista de resultados
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildResultItem(context, filteredResults[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(BuildContext context, SearchResult result) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navegar al detalle del resultado
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de categoría
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(result.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  result.icon,
                  color: _getCategoryColor(result.category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (result.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 12,
                                  color: scheme.secondary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Popular',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: scheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: scheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.author,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: scheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: scheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.date,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: scheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botón de favorito
              IconButton(
                icon: const Icon(Icons.favorite_border),
                color: scheme.onSurface.withOpacity(0.5),
                onPressed: () {
                  // Agregar a favoritos
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final scheme = Theme.of(context).colorScheme;
    switch (category) {
      case 'Relatos':
        return scheme.primary;
      case 'Eventos':
        return scheme.secondary;
      case 'Recetas':
        return scheme.tertiary;
      case 'Tradiciones':
        return Colors.purple;
      case 'Lugares':
        return Colors.green;
      default:
        return scheme.primary;
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros de Búsqueda',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ordenar por:',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _filters.map((filter) {
                final isSelected = filter == _selectedFilter;
                return FilterChip(
                  label: Text(
                    filter,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResult {
  final String title;
  final String subtitle;
  final String category;
  final String author;
  final String date;
  final IconData icon;
  final bool isPopular;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.author,
    required this.date,
    required this.icon,
    required this.isPopular,
  });
}
