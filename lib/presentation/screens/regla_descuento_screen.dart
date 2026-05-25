import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/articulo_entity.dart';
import '../../domain/entities/regla_descuento_entity.dart';
import '../providers/articulo_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

class ReglaDescuentoScreen extends ConsumerStatefulWidget {
  const ReglaDescuentoScreen({super.key});

  @override
  ConsumerState<ReglaDescuentoScreen> createState() =>
      _ReglaDescuentoScreenState();
}

class _ReglaDescuentoScreenState extends ConsumerState<ReglaDescuentoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(reglaDescuentoProvider.notifier).cargar());
  }

  @override
  Widget build(BuildContext context) {
    final reglasAsync = ref.watch(reglaDescuentoProvider);
    final isMobile = context.isMobile;
    ref.watch(isAdminProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Reglas de Descuento'),
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
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nueva regla',
            onPressed: () => _showFormDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(reglaDescuentoProvider.notifier).cargar(),
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
                child: reglasAsync.when(
                  data: (reglas) => reglas.isEmpty
                      ? _buildEmpty()
                      : _buildList(context, reglas),
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (e, _) => _buildError(context, e),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.discount_outlined,
              size: 64, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Sin reglas de descuento',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showFormDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Agregar primera regla'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ReglaDescuentoEntity> reglas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            '${reglas.length} regla${reglas.length != 1 ? 's' : ''} configurada${reglas.length != 1 ? 's' : ''}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: reglas.length,
            itemBuilder: (context, i) => _buildCard(context, reglas[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, ReglaDescuentoEntity regla) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              const Icon(Icons.discount_rounded, color: Colors.green, size: 24),
        ),
        title: Text(
          regla.descripcionArticulo,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              regla.codArticulo,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildChip(
                    Icons.shopping_cart_outlined,
                    'Desde ${regla.cantidadMinima} unid.',
                    Colors.blue),
                const SizedBox(width: 8),
                _buildChip(Icons.percent_rounded,
                    '${regla.descuento.toStringAsFixed(1)}% dto.', Colors.green),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  color: Colors.white70, size: 20),
              tooltip: 'Editar',
              onPressed: () => _showFormDialog(context, regla: regla),
            ),
            if (ref.read(isAdminProvider))
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.withValues(alpha: 0.8), size: 20),
                tooltip: 'Eliminar',
                onPressed: () => _confirmarEliminar(context, regla),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context,
      {ReglaDescuentoEntity? regla}) {
    final articulosAsync = ref.read(articuloProvider);
    final articulos = articulosAsync.value ?? [];
    final esEdicion = regla != null;

    ArticuloEntity? articuloSeleccionado = esEdicion
        ? articulos
            .where((a) => a.codArticulo == regla.codArticulo)
            .firstOrNull
        : null;

    final cantidadCtrl = TextEditingController(
        text: esEdicion ? regla.cantidadMinima.toString() : '');
    final descuentoCtrl = TextEditingController(
        text: esEdicion ? regla.descuento.toStringAsFixed(1) : '');
    final formKey = GlobalKey<FormState>();
    bool loading = false;
    bool articuloError = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          title: Text(esEdicion ? 'Editar Regla' : 'Nueva Regla de Descuento'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Artículo
                if (!esEdicion)
                  GestureDetector(
                    onTap: () => _showArticuloSearch(
                      ctx,
                      articulos,
                      articuloSeleccionado,
                      (selected) => setDs(() {
                        articuloSeleccionado = selected;
                        articuloError = false;
                      }),
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Artículo *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        suffixIcon: const Icon(Icons.search_rounded),
                        errorText: articuloError
                            ? 'Selecciona un artículo'
                            : null,
                      ),
                      child: Text(
                        articuloSeleccionado != null
                            ? '${articuloSeleccionado!.codArticulo} - ${articuloSeleccionado!.descripcion}'
                            : 'Toca para buscar artículo...',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: articuloSeleccionado != null
                              ? null
                              : Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Artículo',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                        '${regla.codArticulo} - ${regla.descripcionArticulo}'),
                  ),

                const SizedBox(height: 16),

                // Cantidad mínima
                TextFormField(
                  controller: cantidadCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad mínima *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_cart_outlined),
                    helperText:
                        'A partir de esta cantidad se aplica el descuento',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Ingresa un número mayor a 0';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Descuento
                TextFormField(
                  controller: descuentoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descuento (%) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent_rounded),
                    suffixText: '%',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final n = double.tryParse(
                        v?.replaceAll(',', '.') ?? '');
                    if (n == null || n <= 0 || n > 100) {
                      return 'Ingresa un valor entre 0.01 y 100';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      // Validate article selection manually
                      if (!esEdicion && articuloSeleccionado == null) {
                        setDs(() => articuloError = true);
                        return;
                      }
                      if (!formKey.currentState!.validate()) return;
                      setDs(() => loading = true);
                      try {
                        final cantidadMinima =
                            int.parse(cantidadCtrl.text);
                        final descuento = double.parse(
                            descuentoCtrl.text.replaceAll(',', '.'));

                        if (esEdicion) {
                          await ref
                              .read(reglaDescuentoProvider.notifier)
                              .actualizar(
                                regla.codReglaDescuento,
                                ReglaDescuentoEntity(
                                  codReglaDescuento:
                                      regla.codReglaDescuento,
                                  codArticulo: regla.codArticulo,
                                  descripcionArticulo:
                                      regla.descripcionArticulo,
                                  cantidadMinima: cantidadMinima,
                                  descuento: descuento,
                                  audUsuario: regla.audUsuario,
                                ),
                              );
                        } else {
                          await ref
                              .read(reglaDescuentoProvider.notifier)
                              .crear(
                                ReglaDescuentoEntity(
                                  codReglaDescuento: 0,
                                  codArticulo:
                                      articuloSeleccionado!.codArticulo!,
                                  descripcionArticulo:
                                      articuloSeleccionado!.descripcion,
                                  cantidadMinima: cantidadMinima,
                                  descuento: descuento,
                                  audUsuario: 0,
                                ),
                              );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          AppOverlay.showMessage(
                            context,
                            esEdicion ? 'Regla actualizada' : 'Regla creada exitosamente',
                            isSuccess: true,
                          );
                        }
                      } catch (e) {
                        setDs(() => loading = false);
                        if (ctx.mounted) {
                          AppOverlay.showMessage(ctx, ErrorMessages.getFriendlyMessage(e), isError: true);
                        }
                      }
                    },
              child: Text(esEdicion ? 'Guardar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  /// Diálogo de búsqueda y selección de artículo con paginación
  void _showArticuloSearch(
    BuildContext parentCtx,
    List<ArticuloEntity> todos,
    ArticuloEntity? seleccionado,
    void Function(ArticuloEntity) onSelect,
  ) {
    const int pageSize = 20;
    final searchCtrl = TextEditingController();
    List<ArticuloEntity> filtered = List.of(todos);
    int page = 0;

    showDialog(
      context: parentCtx,
      builder: (sCtx) => StatefulBuilder(
        builder: (sCtx, setSt) {
          final totalPages = (filtered.length / pageSize).ceil();
          final start = page * pageSize;
          final end = (start + pageSize).clamp(0, filtered.length);
          final pageItems = filtered.sublist(start, end);

          void applySearch(String q) {
            setSt(() {
              page = 0;
              if (q.isEmpty) {
                filtered = List.of(todos);
              } else {
                final lower = q.toLowerCase();
                filtered = todos
                    .where((a) =>
                        (a.codArticulo ?? '').toLowerCase().contains(lower) ||
                        a.descripcion.toLowerCase().contains(lower))
                    .toList();
              }
            });
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 640),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(sCtx).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Seleccionar Artículo',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sCtx),
                        ),
                      ],
                    ),
                  ),

                  // Search field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: searchCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Buscar por código o descripción...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  searchCtrl.clear();
                                  applySearch('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                      ),
                      onChanged: applySearch,
                    ),
                  ),

                  // Results count
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} artículo${filtered.length != 1 ? 's' : ''}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(sCtx)
                                  .textTheme
                                  .bodySmall
                                  ?.color),
                        ),
                        if (totalPages > 1) ...[
                          const Spacer(),
                          Text(
                            'Página ${page + 1} de $totalPages',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(sCtx)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // List
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('Sin resultados',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: pageItems.length,
                            itemBuilder: (_, i) {
                              final a = pageItems[i];
                              final isSelected =
                                  seleccionado?.codArticulo == a.codArticulo;
                              return ListTile(
                                dense: true,
                                selected: isSelected,
                                selectedTileColor: Theme.of(sCtx)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Theme.of(sCtx)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 16,
                                    color:
                                        Theme.of(sCtx).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  a.descripcion,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  a.codArticulo ?? '',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle_rounded,
                                        color: Theme.of(sCtx)
                                            .colorScheme
                                            .primary,
                                        size: 18)
                                    : null,
                                onTap: () {
                                  onSelect(a);
                                  Navigator.pop(sCtx);
                                },
                              );
                            },
                          ),
                  ),

                  // Pagination bar
                  if (totalPages > 1) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.first_page_rounded),
                            tooltip: 'Primera',
                            onPressed: page > 0
                                ? () => setSt(() => page = 0)
                                : null,
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            tooltip: 'Anterior',
                            onPressed: page > 0
                                ? () => setSt(() => page--)
                                : null,
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${page + 1} / $totalPages',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            tooltip: 'Siguiente',
                            onPressed: page < totalPages - 1
                                ? () => setSt(() => page++)
                                : null,
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page_rounded),
                            tooltip: 'Última',
                            onPressed: page < totalPages - 1
                                ? () => setSt(() => page = totalPages - 1)
                                : null,
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmarEliminar(
      BuildContext context, ReglaDescuentoEntity regla) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Regla'),
        content: Text(
            '¿Eliminar la regla de descuento para "${regla.descripcionArticulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(reglaDescuentoProvider.notifier)
                    .eliminar(regla.codReglaDescuento);
                if (mounted) {
                  AppOverlay.showMessage(context, 'Regla eliminada', isSuccess: true);
                }
              } catch (e) {
                if (mounted) {
                  AppOverlay.showMessage(context, ErrorMessages.getFriendlyMessage(e), isError: true);
                }
              }
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(ErrorMessages.getFriendlyMessage(error),
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                ref.read(reglaDescuentoProvider.notifier).cargar(),
            child: const Text('Reintentar'),
          ),
        ],
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
              right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
    );
  }
}
