import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/articulo_entity.dart';
import '../providers/articulo_provider.dart';
import '../widgets/app_drawer.dart';

class CatalogoScreen extends ConsumerStatefulWidget {
  const CatalogoScreen({super.key});

  @override
  ConsumerState<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends ConsumerState<CatalogoScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _lineaFiltro;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArticuloEntity> _filtrar(List<ArticuloEntity> articulos) {
    return articulos.where((a) {
      final matchSearch = _searchQuery.isEmpty ||
          a.descripcion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.descripcion2.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (a.codArticulo?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
      final matchLinea = _lineaFiltro == null || a.linea == _lineaFiltro;
      return matchSearch && matchLinea;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final articulosAsync = ref.watch(articuloProvider);
    final isMobile = context.isMobile;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Catálogo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(articuloProvider),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: isMobile ? _buildBlurredDrawer() : null,
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
                    final lineas = articulos
                        .map((a) => a.linea)
                        .whereType<String>()
                        .toSet()
                        .toList()
                      ..sort();
                    final filtrados = _filtrar(articulos);
                    return ResponsiveLayout(
                      mobile: _buildLayout(context, filtrados, lineas),
                      tablet: _buildLayout(context, filtrados, lineas),
                      desktop: _buildLayout(context, filtrados, lineas),
                    );
                  },
                  loading: () => _buildLoading(),
                  error: (e, _) => _buildError(context, e),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayout(
    BuildContext context,
    List<ArticuloEntity> articulos,
    List<String> lineas,
  ) {
    return Column(
      children: [
        _buildSearchBar(lineas),
        _buildStats(articulos),
        Expanded(child: _buildGrid(context, articulos)),
      ],
    );
  }

  Widget _buildSearchBar(List<String> lineas) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar artículo...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.6)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: Colors.white.withValues(alpha: 0.6)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          if (lineas.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildLineaFilter(lineas),
          ],
        ],
      ),
    );
  }

  Widget _buildLineaFilter(List<String> lineas) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _lineaFiltro,
          dropdownColor: AppTheme.cardSurfaceLight,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: Icon(Icons.filter_list_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
          hint: Text('Línea', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Todas', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
            ),
            ...lineas.map((l) => DropdownMenuItem<String?>(
                  value: l,
                  child: Text(l, style: const TextStyle(color: Colors.white)),
                )),
          ],
          onChanged: (v) => setState(() => _lineaFiltro = v),
        ),
      ),
    );
  }

  Widget _buildStats(List<ArticuloEntity> articulos) {
    final conStock = articulos.where((a) => (a.stockActual ?? 0) > 0).length;
    final sinStock = articulos.where((a) => (a.stockActual ?? 0) == 0).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _buildStatChip(Icons.inventory_2_outlined, '${articulos.length}', 'artículos', Colors.white),
          const SizedBox(width: 8),
          _buildStatChip(Icons.check_circle_outline_rounded, '$conStock', 'con stock', Colors.green),
          const SizedBox(width: 8),
          _buildStatChip(Icons.remove_circle_outline_rounded, '$sinStock', 'sin stock', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text('$count $label', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<ArticuloEntity> articulos) {
    if (articulos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Sin resultados',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = context.isDesktop ? 4 : (context.isTablet ? 3 : 2);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: articulos.length,
        itemBuilder: (context, i) => _buildCard(articulos[i]),
      ),
    );
  }

  Widget _buildCard(ArticuloEntity articulo) {
    final stock = articulo.stockActual ?? 0;
    final precio = articulo.precioActual;
    final stockColor = stock > 10
        ? Colors.green
        : stock > 0
            ? Colors.orange
            : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Code + line badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    articulo.codArticulo ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (articulo.linea != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      articulo.linea!,
                      style: TextStyle(
                        color: AppTheme.accentCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              articulo.descripcion,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (articulo.descripcion2.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                articulo.descripcion2,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Spacer(),

            const Divider(color: Colors.white12, height: 16),

            // Stock + Price row
            Row(
              children: [
                // Stock
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            stock > 0 ? Icons.inventory_2_rounded : Icons.remove_circle_outline,
                            color: stockColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$stock',
                            style: TextStyle(
                              color: stockColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price
                if (precio != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Precio',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bs. ${precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.8)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando catálogo...',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withValues(alpha: 0.8)),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el catálogo',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              ErrorMessages.getFriendlyMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(articuloProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
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
                  AppTheme.cardSurface.withValues(alpha: 0.95),
                  AppTheme.cardSurfaceLight.withValues(alpha: 0.92),
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
            color: AppTheme.cardSurface.withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
    );
  }
}
