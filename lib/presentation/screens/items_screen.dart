import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
import '../../core/utils/animations.dart';
import '../../domain/entities/articulo_entity.dart';
import '../../domain/entities/linea_entity.dart';
import '../../domain/entities/precio_entity.dart';
import '../providers/articulo_provider.dart';
import '../providers/linea_provider.dart';
import '../providers/familia_provider.dart';
import '../providers/precio_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Artículos/Items con diseño moderno
class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articulosAsync = ref.watch(articuloProvider);
    final isMobile = context.isMobile;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Artículos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          // Solo admin puede agregar artículos
          if (!isMobile && isAdmin)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _showAddArticuloDialog(context),
              tooltip: 'Agregar artículo',
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(articuloProvider),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: isMobile ? _buildBlurredDrawer() : null,
      // Solo admin puede ver el FAB para agregar artículos
      floatingActionButton: isAdmin
          ? (isMobile
                ? FadeSlideAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: FloatingActionButton.extended(
                      onPressed: () => _showAddArticuloDialog(context),
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Nuevo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                : FloatingActionButton.extended(
                    onPressed: () => _showAddArticuloDialog(context),
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Nuevo Artículo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ))
          : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Row(
          children: [
            if (!isMobile) _buildPermanentDrawer(),
            Expanded(
              child: SafeArea(
                child: articulosAsync.when(
                  data: (articulos) {
                    final filteredArticulos = _filterArticulos(articulos);
                    return ResponsiveLayout(
                      mobile: _buildMobileLayout(context, filteredArticulos),
                      tablet: _buildTabletLayout(context, filteredArticulos),
                      desktop: _buildDesktopLayout(context, filteredArticulos),
                    );
                  },
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(context, error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1D2E).withValues(alpha: 0.95),
                  const Color(0xFF2D3250).withValues(alpha: 0.92),
                ],
              ),
            ),
            child: const AppDrawer(),
          ),
        ),
      ),
    );
  }

  Widget _buildPermanentDrawer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E).withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando artículos...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No se pudieron cargar los artículos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ErrorMessages.getFriendlyMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(articuloProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ArticuloEntity> _filterArticulos(List<ArticuloEntity> articulos) {
    if (_searchQuery.isEmpty) return articulos;
    return articulos.where((articulo) {
      return articulo.descripcion.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          articulo.descripcion2.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (articulo.codArticulo?.toLowerCase() ?? '').contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  /// Layout para móvil
  Widget _buildMobileLayout(
    BuildContext context,
    List<ArticuloEntity> articulos,
  ) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: articulos.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: context.screenPadding,
                  itemCount: articulos.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, articulos[index], index);
                  },
                ),
        ),
      ],
    );
  }

  /// Layout para tablet
  Widget _buildTabletLayout(
    BuildContext context,
    List<ArticuloEntity> articulos,
  ) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: articulos.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  padding: context.screenPadding,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: articulos.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, articulos[index], index);
                  },
                ),
        ),
      ],
    );
  }

  /// Layout para desktop
  Widget _buildDesktopLayout(
    BuildContext context,
    List<ArticuloEntity> articulos,
  ) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: articulos.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  padding: context.screenPadding,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: articulos.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, articulos[index], index);
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
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppTheme.accentCyan,
            decoration: InputDecoration(
              hintText: 'Buscar artículos...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search, color: AppTheme.accentCyan),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
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
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentCyan, width: 2),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.15),
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

  /// Card de artículo con diseño mejorado y control de permisos
  Widget _buildItemCard(
    BuildContext context,
    ArticuloEntity articulo,
    int index,
  ) {
    final isAdmin = ref.watch(isAdminProvider);
    final stockActual = articulo.stockActual ?? 0;
    final hasStock = stockActual > 0;
    final isLowStock = stockActual > 0 && stockActual <= 10;

    return FadeSlideAnimation(
      delay: Duration(milliseconds: 50 * (index % 10)),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasStock
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.red.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showItemDetails(context, articulo),
            borderRadius: BorderRadius.circular(20),
            splashColor: AppTheme.accentCyan.withValues(alpha: 0.2),
            highlightColor: AppTheme.accentCyan.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header con código, ícono y botones de acción
                  Row(
                    children: [
                      // Ícono principal con gradiente
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accentCyan.withValues(alpha: 0.3),
                              AppTheme.accentCyan.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          size: 22,
                          color: AppTheme.accentCyan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              articulo.codArticulo ?? "N/A",
                              style: TextStyle(
                                color: AppTheme.accentCyan,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 15,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.accentCyan.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                articulo.linea ?? 'Sin línea',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botones de acción - solo para admin
                      if (isAdmin) ...[
                        // Botón de entrada de inventario
                        _buildActionButton(
                          icon: Icons.warehouse_rounded,
                          color: AppTheme.accentGreen,
                          tooltip: 'Gestionar inventario',
                          onPressed: () =>
                              _showEntradaInventarioDialog(context, articulo),
                        ),
                        const SizedBox(width: 8),
                        // Botón de precios
                        _buildActionButton(
                          icon: Icons.monetization_on_rounded,
                          color: AppTheme.accentOrange,
                          tooltip: 'Gestionar precios',
                          onPressed: () =>
                              _showPreciosDialog(context, articulo),
                        ),
                      ] else ...[
                        // Para usuarios no admin, mostrar botón de ver precios (solo lectura)
                        _buildActionButton(
                          icon: Icons.visibility_rounded,
                          color: Colors.white.withValues(alpha: 0.5),
                          tooltip: 'Ver detalles',
                          onPressed: () => _showItemDetails(context, articulo),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Separador con gradiente
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Descripción con mejor tipografía
                  Text(
                    articulo.descripcion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (articulo.descripcion2.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      articulo.descripcion2,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Precio y Stock con mejor diseño
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Precio con gradiente mejorado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accentGreen,
                              AppTheme.accentGreen.withValues(alpha: 0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGreen.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.attach_money_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            Text(
                              articulo.precioActual?.toStringAsFixed(2) ??
                                  "0.00",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stock con indicador visual mejorado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: hasStock
                              ? (isLowStock
                                    ? Colors.orange.withValues(alpha: 0.2)
                                    : AppTheme.accentCyan.withValues(
                                        alpha: 0.15,
                                      ))
                              : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasStock
                                ? (isLowStock
                                      ? Colors.orange.withValues(alpha: 0.5)
                                      : AppTheme.accentCyan.withValues(
                                          alpha: 0.4,
                                        ))
                                : Colors.red.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasStock
                                  ? (isLowStock
                                        ? Icons.warning_rounded
                                        : Icons.inventory_rounded)
                                  : Icons.error_outline_rounded,
                              size: 18,
                              color: hasStock
                                  ? (isLowStock
                                        ? Colors.orange
                                        : AppTheme.accentCyan)
                                  : Colors.red.shade300,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$stockActual',
                              style: TextStyle(
                                color: hasStock
                                    ? (isLowStock
                                          ? Colors.orange
                                          : AppTheme.accentCyan)
                                    : Colors.red.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'uds',
                              style: TextStyle(
                                color: hasStock
                                    ? (isLowStock
                                          ? Colors.orange.withValues(alpha: 0.7)
                                          : AppTheme.accentCyan.withValues(
                                              alpha: 0.7,
                                            ))
                                    : Colors.red.shade300.withValues(
                                        alpha: 0.7,
                                      ),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Botón de acción circular para las cards
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty
                ? 'No hay artículos disponibles'
                : 'No se encontraron artículos',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? (isAdmin
                      ? 'Agrega tu primer artículo'
                      : 'Aún no hay artículos registrados')
                : 'Intenta con otra búsqueda',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra los detalles del artículo
  void _showItemDetails(BuildContext context, ArticuloEntity articulo) {
    final isAdmin = ref.read(isAdminProvider);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header mejorado
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accentCyan.withValues(alpha: 0.2),
                          AppTheme.accentCyan.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.accentCyan.withValues(alpha: 0.3),
                                AppTheme.accentCyan.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.accentCyan.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            color: AppTheme.accentCyan,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                articulo.descripcion,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCyan.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  articulo.codArticulo ?? 'N/A',
                                  style: TextStyle(
                                    color: AppTheme.accentCyan,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content mejorado
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Código',
                          articulo.codArticulo ?? 'N/A',
                        ),
                        _buildDetailRow('Descripción', articulo.descripcion),
                        if (articulo.descripcion2.isNotEmpty)
                          _buildDetailRow(
                            'Descripción 2',
                            articulo.descripcion2,
                          ),
                        _buildDetailRow(
                          'Línea',
                          articulo.linea ??
                              'Sin línea (ID: ${articulo.codLinea})',
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Precio y Stock destacados
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentGreen.withValues(
                                        alpha: 0.2,
                                      ),
                                      AppTheme.accentGreen.withValues(
                                        alpha: 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.accentGreen.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.attach_money_rounded,
                                      color: AppTheme.accentGreen,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${articulo.precioActual?.toStringAsFixed(2) ?? "0.00"}',
                                      style: TextStyle(
                                        color: AppTheme.accentGreen,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Precio',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentCyan.withValues(
                                        alpha: 0.2,
                                      ),
                                      AppTheme.accentCyan.withValues(
                                        alpha: 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.accentCyan.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inventory_rounded,
                                      color: AppTheme.accentCyan,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${articulo.stockActual ?? 0}',
                                      style: TextStyle(
                                        color: AppTheme.accentCyan,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Stock',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions - Solo admin puede editar/eliminar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          label: Text(
                            'Cerrar',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        // Solo admin puede editar
                        if (isAdmin) ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditArticuloDialog(context, articulo);
                            },
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('Editar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentCyan,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              final confirmed = await _showDeleteConfirmation(
                                context,
                                articulo,
                              );
                              if (confirmed == true && context.mounted) {
                                try {
                                  final message = await ref
                                      .read(articuloProvider.notifier)
                                      .deleteArticulo(articulo.codArticulo!);
                                  if (context.mounted) {
                                    context.showSnackBar(
                                      message,
                                      isError: false,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    context.showSnackBar(
                                      ErrorMessages.getFriendlyMessage(e),
                                      isError: true,
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_rounded, size: 16),
                            label: const Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    ArticuloEntity articulo,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirmar eliminación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¿Estás seguro de eliminar "${articulo.descripcion}"?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                        ),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// Diálogo para agregar artículo
  void _showAddArticuloDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ArticuloFormDialog(
        onSubmit: (codArticulo, codLinea, descripcion, descripcion2) async {
          final userAsync = ref.read(authProvider);
          final user = userAsync.value;
          return await ref
              .read(articuloProvider.notifier)
              .createArticulo(
                codArticulo: codArticulo,
                codLinea: codLinea,
                descripcion: descripcion,
                descripcion2: descripcion2,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  /// Diálogo para editar artículo
  void _showEditArticuloDialog(BuildContext context, ArticuloEntity articulo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ArticuloFormDialog(
        articulo: articulo,
        onSubmit: (codArticulo, codLinea, descripcion, descripcion2) async {
          final userAsync = ref.read(authProvider);
          final user = userAsync.value;
          return await ref
              .read(articuloProvider.notifier)
              .updateArticulo(
                codArticulo: codArticulo,
                codLinea: codLinea,
                descripcion: descripcion,
                descripcion2: descripcion2,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  /// Diálogo para gestionar precios del artículo
  void _showPreciosDialog(BuildContext context, ArticuloEntity articulo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PreciosFormDialog(articulo: articulo),
    );
  }

  /// Diálogo para entrada de inventario
  void _showEntradaInventarioDialog(
    BuildContext context,
    ArticuloEntity articulo,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EntradaInventarioDialog(articulo: articulo),
    );
  }
}

/// Formulario de artículo (crear/editar)
class _ArticuloFormDialog extends ConsumerStatefulWidget {
  final ArticuloEntity? articulo;
  final Future<String> Function(
    String codArticulo,
    int codLinea,
    String descripcion,
    String descripcion2,
  )
  onSubmit;

  const _ArticuloFormDialog({this.articulo, required this.onSubmit});

  @override
  ConsumerState<_ArticuloFormDialog> createState() =>
      _ArticuloFormDialogState();
}

class _ArticuloFormDialogState extends ConsumerState<_ArticuloFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codArticuloController;
  late TextEditingController _descripcionController;
  late TextEditingController _descripcion2Controller;

  int? _selectedLineaId;
  bool _isLoading = false;
  bool _showLineaQuickAdd = false;

  @override
  void initState() {
    super.initState();
    _codArticuloController = TextEditingController(
      text: widget.articulo?.codArticulo ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.articulo?.descripcion ?? '',
    );
    _descripcion2Controller = TextEditingController(
      text: widget.articulo?.descripcion2 ?? '',
    );
    _selectedLineaId = widget.articulo?.codLinea;
  }

  @override
  void dispose() {
    _codArticuloController.dispose();
    _descripcionController.dispose();
    _descripcion2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineasAsync = ref.watch(lineaProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: screenWidth > 500 ? 500 : screenWidth * 0.95,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.articulo == null
                              ? Icons.add_circle
                              : Icons.edit,
                          color: AppTheme.accentCyan,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.articulo == null
                              ? 'Nuevo Artículo'
                              : 'Editar Artículo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Código de artículo
                          _buildGlassTextField(
                            controller: _codArticuloController,
                            label: 'Código de Artículo',
                            icon: Icons.qr_code,
                            enabled: widget.articulo == null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El código es obligatorio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Descripción
                          _buildGlassTextField(
                            controller: _descripcionController,
                            label: 'Descripción',
                            icon: Icons.description,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La descripción es obligatoria';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Descripción 2
                          _buildGlassTextField(
                            controller: _descripcion2Controller,
                            label: 'Descripción 2',
                            icon: Icons.notes,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La descripción 2 es obligatoria';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Línea con búsqueda integrada
                          lineasAsync.when(
                            data: (lineas) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _LineaSearchableDropdown(
                                          lineas: lineas,
                                          selectedLineaId: _selectedLineaId,
                                          onChanged: (lineaId) {
                                            setState(() {
                                              _selectedLineaId = lineaId;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'La línea es obligatoria';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentCyan.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showLineaQuickAdd =
                                                  !_showLineaQuickAdd;
                                            });
                                          },
                                          icon: Icon(
                                            _showLineaQuickAdd
                                                ? Icons.close
                                                : Icons.add,
                                            color: AppTheme.accentCyan,
                                          ),
                                          tooltip: _showLineaQuickAdd
                                              ? 'Cerrar'
                                              : 'Agregar línea rápida',
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Formulario rápido de línea
                                  if (_showLineaQuickAdd) ...[
                                    const SizedBox(height: 16),
                                    _QuickLineaForm(
                                      onLineaCreated: (nuevaLinea) {
                                        setState(() {
                                          _selectedLineaId =
                                              nuevaLinea.codLinea;
                                          _showLineaQuickAdd = false;
                                        });
                                        ref
                                            .read(lineaProvider.notifier)
                                            .loadLineas();
                                      },
                                    ),
                                  ],
                                ],
                              );
                            },
                            loading: () => Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.accentCyan,
                              ),
                            ),
                            error: (error, stack) => Text(
                              'Error: $error',
                              style: TextStyle(color: Colors.red.shade300),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleSubmit,
                        icon: _isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          widget.articulo == null ? 'Crear' : 'Actualizar',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppTheme.accentCyan,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppTheme.accentCyan,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: AppTheme.accentCyan),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accentCyan, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
      ),
      validator: validator,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final message = await widget.onSubmit(
        _codArticuloController.text,
        _selectedLineaId!,
        _descripcionController.text,
        _descripcion2Controller.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Formulario rápido para crear línea sin salir del diálogo de artículo
class _QuickLineaForm extends ConsumerStatefulWidget {
  final Function(LineaEntity) onLineaCreated;

  const _QuickLineaForm({required this.onLineaCreated});

  @override
  ConsumerState<_QuickLineaForm> createState() => _QuickLineaFormState();
}

class _QuickLineaFormState extends ConsumerState<_QuickLineaForm> {
  final _lineaController = TextEditingController();
  int? _selectedFamiliaId;
  bool _isCreating = false;

  @override
  void dispose() {
    _lineaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familiasAsync = ref.watch(familiaProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accentCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle, color: AppTheme.accentCyan),
              const SizedBox(width: 8),
              Text(
                'Crear Línea Rápida',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dropdown de Familias
          familiasAsync.when(
            data: (familias) {
              if (familias.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade300),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No hay familias disponibles. Crea una familia primero.',
                          style: TextStyle(color: Colors.orange.shade300),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Familia',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: AppTheme.accentCyan,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    Icons.folder_special,
                    color: AppTheme.accentCyan,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentCyan,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.15),
                ),
                dropdownColor: const Color(0xFF2A2A4A),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                initialValue: _selectedFamiliaId,
                isExpanded: true,
                items: familias.map((familia) {
                  return DropdownMenuItem<int>(
                    value: familia.codFamilia,
                    child: Text(
                      '${familia.codFamilia} - ${familia.familia}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: _isCreating
                    ? null
                    : (value) {
                        setState(() {
                          _selectedFamiliaId = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'La familia es obligatoria';
                  }
                  return null;
                },
              );
            },
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircularProgressIndicator(color: AppTheme.accentCyan),
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Error al cargar familias: ${ErrorMessages.getFriendlyMessage(error)}',
                style: TextStyle(color: Colors.red.shade300),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _lineaController,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppTheme.accentCyan,
            decoration: InputDecoration(
              labelText: 'Nombre de la línea',
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelStyle: TextStyle(
                color: AppTheme.accentCyan,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentCyan, width: 2),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.15),
            ),
            enabled: !_isCreating,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCreating ? null : _createLinea,
              icon: _isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add),
              label: const Text('Crear Línea'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createLinea() async {
    if (_lineaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de la línea es obligatorio')),
      );
      return;
    }

    if (_selectedFamiliaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar una familia')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final userAsync = ref.read(authProvider);
      final user = userAsync.value;
      await ref
          .read(lineaProvider.notifier)
          .createLinea(
            codFamilia: _selectedFamiliaId!,
            linea: _lineaController.text,
            audUsuario: user?.codUsuario ?? 0,
          );

      // Recargar líneas y obtener la recién creada
      await ref.read(lineaProvider.notifier).loadLineas();
      final lineas = ref.read(lineaProvider).value ?? [];
      final nuevaLinea = lineas.firstWhere(
        (l) => l.linea == _lineaController.text,
        orElse: () => lineas.last,
      );

      if (mounted) {
        widget.onLineaCreated(nuevaLinea);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Línea creada correctamente')),
        );
        _lineaController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.getCrudErrorMessage('create', e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Dropdown con búsqueda integrada para seleccionar línea
class _LineaSearchableDropdown extends StatefulWidget {
  final List<LineaEntity> lineas;
  final int? selectedLineaId;
  final ValueChanged<int?> onChanged;
  final FormFieldValidator<int?>? validator;

  const _LineaSearchableDropdown({
    required this.lineas,
    required this.selectedLineaId,
    required this.onChanged,
    this.validator,
  });

  @override
  State<_LineaSearchableDropdown> createState() =>
      _LineaSearchableDropdownState();
}

class _LineaSearchableDropdownState extends State<_LineaSearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _closeDropdown();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    _searchQuery = '';
    // Programar la limpieza para después del frame actual para evitar
    // el error "setState() called when widget tree was locked"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchController.clear();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Material(
                color: Colors.transparent,
                child: StatefulBuilder(
                  builder: (context, setOverlayState) {
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A4A).withValues(alpha: 0.95),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Buscador dentro del dropdown
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Buscar línea...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 20,
                                  color: AppTheme.accentCyan,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          size: 20,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setOverlayState(() {
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme.accentCyan,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.15),
                              ),
                              onChanged: (value) {
                                setOverlayState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),

                          // Lista de líneas filtradas
                          Flexible(
                            child: Builder(
                              builder: (context) {
                                final filteredLineas = _searchQuery.isEmpty
                                    ? widget.lineas
                                    : widget.lineas.where((linea) {
                                        return linea.linea
                                                .toLowerCase()
                                                .contains(_searchQuery) ||
                                            (linea.codLinea?.toString() ?? '')
                                                .contains(_searchQuery);
                                      }).toList();

                                if (filteredLineas.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'No se encontraron líneas',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: filteredLineas.length,
                                  itemBuilder: (context, index) {
                                    final linea = filteredLineas[index];
                                    final isSelected =
                                        linea.codLinea ==
                                        widget.selectedLineaId;

                                    return ListTile(
                                      dense: true,
                                      selected: isSelected,
                                      selectedTileColor: AppTheme.accentCyan
                                          .withValues(alpha: 0.2),
                                      leading: Icon(
                                        Icons.category,
                                        size: 20,
                                        color: isSelected
                                            ? AppTheme.accentCyan
                                            : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                      ),
                                      title: Text(
                                        linea.linea,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppTheme.accentCyan
                                              : Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Código: ${linea.codLinea}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        widget.onChanged(linea.codLinea);
                                        _closeDropdown();
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener la línea seleccionada de manera segura
    LineaEntity? selectedLinea;
    if (widget.selectedLineaId != null) {
      try {
        selectedLinea = widget.lineas.firstWhere(
          (linea) => linea.codLinea == widget.selectedLineaId,
        );
      } catch (e) {
        // Si no se encuentra, selectedLinea queda null
      }
    }

    return FormField<int?>(
      key: ValueKey(widget.selectedLineaId),
      initialValue: widget.selectedLineaId,
      validator: widget.validator,
      builder: (FormFieldState<int?> field) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _toggleDropdown,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: field.hasError
                          ? Colors.red.shade300
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category, color: AppTheme.accentCyan),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Línea',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedLinea == null
                                  ? 'Seleccionar línea'
                                  : '${selectedLinea.codLinea} - ${selectedLinea.linea}',
                              style: TextStyle(
                                color: selectedLinea == null
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(color: Colors.red.shade300, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Diálogo para gestionar precios de un artículo
class _PreciosFormDialog extends ConsumerStatefulWidget {
  final ArticuloEntity articulo;

  const _PreciosFormDialog({required this.articulo});

  @override
  ConsumerState<_PreciosFormDialog> createState() => _PreciosFormDialogState();
}

class _PreciosFormDialogState extends ConsumerState<_PreciosFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _precioBaseController = TextEditingController(
    text: '',
  );
  final TextEditingController _porcentajeController = TextEditingController(
    text: '30',
  ); // 30% por defecto
  bool _isLoading = false;
  bool _isLoadingPrecios = true;
  List<PrecioEntity> _preciosExistentes = [];
  String? _errorPrecios;

  @override
  void initState() {
    super.initState();
    _cargarPreciosExistentes();
  }

  @override
  void dispose() {
    _precioBaseController.dispose();
    _porcentajeController.dispose();
    super.dispose();
  }

  Future<void> _cargarPreciosExistentes() async {
    setState(() {
      _isLoadingPrecios = true;
      _errorPrecios = null;
    });

    try {
      final precios = await ref
          .read(precioProvider.notifier)
          .loadPreciosByArticulo(widget.articulo.codArticulo!);

      if (mounted) {
        setState(() {
          _preciosExistentes = precios;
          _isLoadingPrecios = false;
        });
      }
    } catch (e, stackTrace) {
      // Log para debugging
      debugPrint('Error al cargar precios: $e');
      debugPrint('StackTrace: $stackTrace');

      if (mounted) {
        setState(() {
          _errorPrecios = ErrorMessages.getFriendlyMessage(e);
          _isLoadingPrecios = false;
          _preciosExistentes = []; // Lista vacía en caso de error
        });
      }
    }
  }

  // Calcula el precio de venta basado en el precio base y el porcentaje
  double? _calcularPrecioVenta() {
    final precioBase = double.tryParse(_precioBaseController.text.trim());
    final porcentaje = double.tryParse(_porcentajeController.text.trim());

    if (precioBase != null && porcentaje != null) {
      return precioBase * (1 + (porcentaje / 100));
    }
    return null;
  }

  // Calcula el precio sin factura (mismo que precio de venta por ahora)
  double? _calcularPrecioSinFactura() {
    return _calcularPrecioVenta();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.attach_money, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(isAdmin ? 'Gestionar Precios' : 'Ver Precios')),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del artículo
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.articulo.codArticulo ?? 'N/A',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.articulo.descripcion,
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (widget.articulo.linea != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Línea: ${widget.articulo.linea}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Precios existentes del artículo
                if (_isLoadingPrecios)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorPrecios != null)
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorPrecios!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_preciosExistentes.isNotEmpty)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.price_check,
                                size: 18,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Precios Existentes (${_preciosExistentes.length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 12),
                          ..._preciosExistentes.map((precio) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lista: ${precio.listaPrecio}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Base: \$${precio.precioBase.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Venta: \$${precio.precio.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'S/Fact: \$${precio.precioSinFactura.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este artículo no tiene precios registrados',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Solo admin puede agregar/actualizar precios
                if (isAdmin) ...[
                  const SizedBox(height: 20),

                  // Divider con texto
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade400)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'AGREGAR/ACTUALIZAR PRECIO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade400)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Precio Base
                  TextFormField(
                    controller: _precioBaseController,
                    decoration: InputDecoration(
                      labelText: 'Precio Base (Costo)',
                      hintText: '0.00',
                      prefixIcon: Icon(
                        Icons.monetization_on,
                        color: Colors.green.shade600,
                      ),
                      prefixText: '\$ ',
                      border: const OutlineInputBorder(),
                      helperText: 'Precio de costo o base del producto',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) => setState(() {}), // Recalcular precios
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El precio base es requerido';
                      }
                      final precio = double.tryParse(value.trim());
                      if (precio == null) {
                        return 'Ingrese un precio válido';
                      }
                      if (precio <= 0) {
                        return 'El precio debe ser mayor a 0';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Porcentaje de Incremento
                  TextFormField(
                    controller: _porcentajeController,
                    decoration: InputDecoration(
                      labelText: 'Porcentaje de Incremento',
                      hintText: '0',
                      prefixIcon: Icon(
                        Icons.percent,
                        color: Colors.purple.shade600,
                      ),
                      suffixText: '%',
                      border: const OutlineInputBorder(),
                      helperText: 'Porcentaje de ganancia sobre el precio base',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) => setState(() {}), // Recalcular precios
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El porcentaje es requerido';
                      }
                      final porcentaje = double.tryParse(value.trim());
                      if (porcentaje == null) {
                        return 'Ingrese un porcentaje válido';
                      }
                      if (porcentaje < 0) {
                        return 'El porcentaje no puede ser negativo';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Precios Calculados (solo lectura)
                  ValueListenableBuilder(
                    valueListenable: _precioBaseController,
                    builder: (context, baseValue, _) {
                      return ValueListenableBuilder(
                        valueListenable: _porcentajeController,
                        builder: (context, porcentajeValue, _) {
                          final precioVenta = _calcularPrecioVenta();
                          final precioSinFactura = _calcularPrecioSinFactura();

                          return Card(
                            color: Colors.blue.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calculate,
                                        size: 20,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Precios Calculados',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.sell,
                                            size: 16,
                                            color: Colors.blue.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Precio de Venta:',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        precioVenta != null
                                            ? '\$${precioVenta.toStringAsFixed(2)}'
                                            : '\$0.00',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.money_off,
                                            size: 16,
                                            color: Colors.orange.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Precio Sin Factura:',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        precioSinFactura != null
                                            ? '\$${precioSinFactura.toStringAsFixed(2)}'
                                            : '\$0.00',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade900,
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
                    },
                  ),

                  const SizedBox(height: 16),

                  // Resumen de ganancia
                  ValueListenableBuilder(
                    valueListenable: _precioBaseController,
                    builder: (context, baseValue, _) {
                      return ValueListenableBuilder(
                        valueListenable: _porcentajeController,
                        builder: (context, porcentajeValue, _) {
                          final precioBase = double.tryParse(baseValue.text);
                          final porcentaje = double.tryParse(
                            porcentajeValue.text,
                          );

                          double? ganancia;

                          if (precioBase != null &&
                              porcentaje != null &&
                              precioBase > 0) {
                            ganancia = precioBase * (porcentaje / 100);
                          }

                          return Card(
                            color: Colors.green.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        size: 18,
                                        color: Colors.green.shade900,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Resumen de Ganancia',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (ganancia != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Ganancia por unidad:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          '\$${ganancia.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 12),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Los precios serán calculados automáticamente y aplicados al artículo.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ], // Fin del if (isAdmin)
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(isAdmin ? 'Cancelar' : 'Cerrar'),
        ),
        // Solo admin puede guardar precios
        if (isAdmin)
          FilledButton.icon(
            onPressed: _isLoading ? null : _handleSubmit,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Guardar Precios'),
          ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final precioBase = double.parse(_precioBaseController.text.trim());
      final porcentaje = double.parse(_porcentajeController.text.trim());
      final precioVenta = _calcularPrecioVenta()!;
      final precioSinFactura = _calcularPrecioSinFactura()!;

      // Obtener el usuario actual desde el provider de autenticación
      final authState = ref.read(authProvider);
      final userId = authState.value?.codUsuario ?? 0;

      // Llamar al provider para crear el precio
      // codPrecio es auto-increment, no se envía desde el frontend
      final message = await ref
          .read(precioProvider.notifier)
          .createPrecio(
            codArticulo: widget.articulo.codArticulo!,
            precioBase: precioBase,
            precio: precioVenta,
            precioSinFactura: precioSinFactura,
            audUsuario: userId,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$message\n'
              'Base: \$${precioBase.toStringAsFixed(2)} + ${porcentaje.toStringAsFixed(0)}%\n'
              'Venta: \$${precioVenta.toStringAsFixed(2)} | '
              'Sin Factura: \$${precioSinFactura.toStringAsFixed(2)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Recargar los precios del artículo después de guardar
        _cargarPreciosExistentes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ============================================================================
// DIÁLOGO DE ENTRADA DE INVENTARIO
// ============================================================================

/// Diálogo para registrar entrada de inventario
class _EntradaInventarioDialog extends ConsumerStatefulWidget {
  final ArticuloEntity articulo;

  const _EntradaInventarioDialog({required this.articulo});

  @override
  ConsumerState<_EntradaInventarioDialog> createState() =>
      _EntradaInventarioDialogState();
}

class _EntradaInventarioDialogState
    extends ConsumerState<_EntradaInventarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _observacionController = TextEditingController();

  bool _isLoading = false;
  String _tipoMovimiento = 'ENTRADA'; // Por defecto ENTRADA

  @override
  void dispose() {
    _cantidadController.dispose();
    _observacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _tipoMovimiento == 'ENTRADA'
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _tipoMovimiento == 'ENTRADA'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _tipoMovimiento == 'ENTRADA'
                          ? 'Entrada de Inventario'
                          : 'Salida de Inventario',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Información del artículo
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 20,
                                color: context.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.articulo.codArticulo ?? 'N/A',
                                style: context.theme.textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.articulo.descripcion,
                            style: context.theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Formulario
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Selector de tipo de movimiento
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tipo de Movimiento *',
                                    style: context.theme.textTheme.labelSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => setState(
                                            () => _tipoMovimiento = 'ENTRADA',
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  _tipoMovimiento == 'ENTRADA'
                                                  ? Colors.green.shade700
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    _tipoMovimiento == 'ENTRADA'
                                                    ? Colors.green.shade700
                                                    : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.arrow_downward,
                                                  color:
                                                      _tipoMovimiento ==
                                                          'ENTRADA'
                                                      ? Colors.white
                                                      : Colors.green.shade700,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'ENTRADA',
                                                  style: TextStyle(
                                                    color:
                                                        _tipoMovimiento ==
                                                            'ENTRADA'
                                                        ? Colors.white
                                                        : Colors.green.shade700,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => setState(
                                            () => _tipoMovimiento = 'SALIDA',
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _tipoMovimiento == 'SALIDA'
                                                  ? Colors.red.shade700
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    _tipoMovimiento == 'SALIDA'
                                                    ? Colors.red.shade700
                                                    : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.arrow_upward,
                                                  color:
                                                      _tipoMovimiento ==
                                                          'SALIDA'
                                                      ? Colors.white
                                                      : Colors.red.shade700,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'SALIDA',
                                                  style: TextStyle(
                                                    color:
                                                        _tipoMovimiento ==
                                                            'SALIDA'
                                                        ? Colors.white
                                                        : Colors.red.shade700,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Cantidad
                            TextFormField(
                              controller: _cantidadController,
                              decoration: InputDecoration(
                                labelText: 'Cantidad *',
                                hintText: _tipoMovimiento == 'ENTRADA'
                                    ? 'Cantidad a recibir'
                                    : 'Cantidad a retirar',
                                prefixIcon: const Icon(Icons.pin),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La cantidad es obligatoria';
                                }
                                final cantidad = int.tryParse(value);
                                if (cantidad == null || cantidad <= 0) {
                                  return 'Debe ser un número entero positivo';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Observación
                            TextFormField(
                              controller: _observacionController,
                              decoration: const InputDecoration(
                                labelText: 'Observación (opcional)',
                                hintText: 'Observación adicional',
                                prefixIcon: Icon(Icons.note),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Botones de acción
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _registrarMovimiento,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      _tipoMovimiento == 'ENTRADA'
                                          ? Icons.check
                                          : Icons.remove,
                                    ),
                              label: Text(
                                _isLoading
                                    ? 'Guardando...'
                                    : 'Registrar ${_tipoMovimiento == 'ENTRADA' ? 'Entrada' : 'Salida'}',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _tipoMovimiento == 'ENTRADA'
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registrarMovimiento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cantidad = int.parse(_cantidadController.text);
      final observacion = _observacionController.text.trim();

      // Usar el precio actual del artículo, o 1.0 si no tiene precio
      final precioUnitario = widget.articulo.precioActual ?? 1.0;

      final result = await ref
          .read(inventarioProvider.notifier)
          .crearMovimiento(
            codArticulo: widget.articulo.codArticulo!,
            tipoMovimiento: _tipoMovimiento,
            cantidad: cantidad,
            precioUnitario: precioUnitario,
            observacion: observacion.isEmpty ? null : observacion,
          );

      if (result != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.message}\n'
              'Tipo: $_tipoMovimiento\n'
              'Cantidad: $cantidad unidades',
            ),
            backgroundColor: _tipoMovimiento == 'ENTRADA'
                ? Colors.green
                : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // Recargar la lista de artículos para actualizar el stock
        ref.read(articuloProvider.notifier).loadArticulos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
