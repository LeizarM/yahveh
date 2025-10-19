import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Artículos/Items
class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Datos de ejemplo - aquí irían los datos desde el backend
  final List<Map<String, dynamic>> _items = [
    {
      'id': 1,
      'nombre': 'Biblia Reina Valera 1960',
      'categoria': 'Biblias',
      'precio': 150.00,
      'stock': 25,
      'imagen': Icons.book,
    },
    {
      'id': 2,
      'nombre': 'Himnario Bautista',
      'categoria': 'Música',
      'precio': 80.00,
      'stock': 15,
      'imagen': Icons.music_note,
    },
    {
      'id': 3,
      'nombre': 'Devocional Diario',
      'categoria': 'Devocionales',
      'precio': 50.00,
      'stock': 30,
      'imagen': Icons.calendar_today,
    },
    {
      'id': 4,
      'nombre': 'Cruz de Madera',
      'categoria': 'Decoración',
      'precio': 120.00,
      'stock': 10,
      'imagen': Icons.church,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    return _items.where((item) {
      return item['nombre']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item['categoria']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddItemDialog(context);
            },
            tooltip: 'Agregar artículo',
          ),
        ],
      ),
      drawer: context.isMobile ? const AppDrawer() : null,
      body: Row(
        children: [
          // Drawer permanente en desktop/tablet
          if (!context.isMobile)
            Container(
              width: 280,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: context.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: const AppDrawer(),
            ),

          // Contenido principal
          Expanded(
            child: ResponsiveLayout(
              mobile: _buildMobileLayout(context),
              tablet: _buildTabletLayout(context),
              desktop: _buildDesktopLayout(context),
            ),
          ),
        ],
      ),
      floatingActionButton: context.isMobile
          ? FloatingActionButton(
              onPressed: () => _showAddItemDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  /// Layout para móvil
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: context.screenPadding,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, _filteredItems[index]);
                  },
                ),
        ),
      ],
    );
  }

  /// Layout para tablet
  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  padding: context.screenPadding,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, _filteredItems[index]);
                  },
                ),
        ),
      ],
    );
  }

  /// Layout para desktop
  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  padding: context.screenPadding,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, _filteredItems[index]);
                  },
                ),
        ),
      ],
    );
  }

  /// Barra de búsqueda
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar artículos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
    );
  }

  /// Card de artículo
  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemDetails(context, item),
        child: SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen/Ícono
              Container(
                height: 120,
                color: context.colorScheme.primaryContainer,
                child: Center(
                  child: Icon(
                    item['imagen'] as IconData,
                    size: 64,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),

              // Información
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nombre'],
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['categoria'],
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${item['precio'].toStringAsFixed(2)}',
                            style: context.theme.textTheme.titleMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text(
                              'Stock: ${item['stock']}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
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

  /// Estado vacío
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No hay artículos disponibles'
                : 'No se encontraron artículos',
            style: context.theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Agrega tu primer artículo'
                : 'Intenta con otra búsqueda',
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra los detalles del artículo
  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['nombre']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item['imagen'] as IconData,
              size: 80,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Categoría', item['categoria']),
            _buildDetailRow('Precio', '\$${item['precio'].toStringAsFixed(2)}'),
            _buildDetailRow('Stock', '${item['stock']} unidades'),
            _buildDetailRow('ID', '#${item['id']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.showSnackBar('Función en desarrollo');
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  /// Fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  /// Diálogo para agregar artículo
  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Artículo'),
        content: const Text(
          'Esta función estará disponible próximamente.\n\n'
          'Aquí podrás agregar nuevos artículos al sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
