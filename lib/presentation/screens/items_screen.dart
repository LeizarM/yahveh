import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
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

/// Pantalla de Artículos/Items
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddArticuloDialog(context);
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
            child: articulosAsync.when(
              data: (articulos) {
                final filteredArticulos = _filterArticulos(articulos);
                
                return ResponsiveLayout(
                  mobile: _buildMobileLayout(context, filteredArticulos),
                  tablet: _buildTabletLayout(context, filteredArticulos),
                  desktop: _buildDesktopLayout(context, filteredArticulos),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No se pudieron cargar los artículos',
                        style: context.theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ErrorMessages.getFriendlyMessage(error),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => ref.refresh(articuloProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: context.isMobile
          ? FloatingActionButton(
              onPressed: () => _showAddArticuloDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  List<ArticuloEntity> _filterArticulos(List<ArticuloEntity> articulos) {
    if (_searchQuery.isEmpty) return articulos;
    return articulos.where((articulo) {
      return articulo.descripcion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          articulo.descripcion2.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (articulo.codArticulo?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
    }).toList();
  }

  /// Layout para móvil
  Widget _buildMobileLayout(BuildContext context, List<ArticuloEntity> articulos) {
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
                    return _buildItemCard(context, articulos[index]);
                  },
                ),
        ),
      ],
    );
  }

  /// Layout para tablet
  Widget _buildTabletLayout(BuildContext context, List<ArticuloEntity> articulos) {
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
                    return _buildItemCard(context, articulos[index]);
                  },
                ),
        ),
      ],
    );
  }

  /// Layout para desktop
  Widget _buildDesktopLayout(BuildContext context, List<ArticuloEntity> articulos) {
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
                    return _buildItemCard(context, articulos[index]);
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

  /// Card de artículo con diseño mejorado
  Widget _buildItemCard(BuildContext context, ArticuloEntity articulo) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showItemDetails(context, articulo),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                context.colorScheme.primary.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con código, ícono y botones de precios/inventario
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        size: 20,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            articulo.codArticulo ?? "N/A",
                            style: context.theme.textTheme.labelLarge?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            articulo.linea ?? 'Sin línea',
                            style: context.theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Botón de entrada de inventario
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.warehouse,
                          size: 20,
                          color: Colors.green.shade700,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () => _showEntradaInventarioDialog(context, articulo),
                        tooltip: 'Entrada de inventario',
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Botón de precios
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.amber.shade700,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () => _showPreciosDialog(context, articulo),
                        tooltip: 'Gestionar precios',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Separador visual
                Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                  thickness: 1,
                ),
                
                const SizedBox(height: 12),
                
                // Descripción
                Text(
                  articulo.descripcion,
                  style: context.theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (articulo.descripcion2.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    articulo.descripcion2,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Precio y Stock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Precio
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade700, Colors.green.shade600],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '\$${articulo.precioActual?.toStringAsFixed(2) ?? "0.00"}',
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Stock
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (articulo.stockActual ?? 0) > 0 
                            ? Colors.blue.shade50 
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (articulo.stockActual ?? 0) > 0 
                              ? Colors.blue.shade300 
                              : Colors.red.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (articulo.stockActual ?? 0) > 0 
                                ? Icons.inventory 
                                : Icons.warning_amber_rounded,
                            size: 16,
                            color: (articulo.stockActual ?? 0) > 0 
                                ? Colors.blue.shade700 
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${articulo.stockActual ?? 0}',
                            style: context.theme.textTheme.bodyMedium?.copyWith(
                              color: (articulo.stockActual ?? 0) > 0 
                                  ? Colors.blue.shade700 
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
  void _showItemDetails(BuildContext context, ArticuloEntity articulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(articulo.descripcion),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.inventory_2,
                  size: 80,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Código', articulo.codArticulo ?? 'N/A'),
              _buildDetailRow('Descripción', articulo.descripcion),
              _buildDetailRow('Descripción 2', articulo.descripcion2),
              _buildDetailRow('Línea', articulo.linea ?? 'Sin línea (ID: ${articulo.codLinea})'),
              const Divider(),
              _buildDetailRow('Precio', '\$${articulo.precioActual?.toStringAsFixed(2) ?? "0.00"}'),
              _buildDetailRow('Stock', '${articulo.stockActual ?? 0} unidades'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditArticuloDialog(context, articulo);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content: Text('¿Estás seguro de eliminar "${articulo.descripcion}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                try {
                  final message = await ref.read(articuloProvider.notifier).deleteArticulo(articulo.codArticulo!);
                  if (context.mounted) {
                    context.showSnackBar(message, isError: false);
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showSnackBar(ErrorMessages.getFriendlyMessage(e), isError: true);
                  }
                }
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
  void _showAddArticuloDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ArticuloFormDialog(
        onSubmit: (codArticulo, codLinea, descripcion, descripcion2) async {
          final userAsync = ref.read(authProvider);
          final user = userAsync.value;
          return await ref.read(articuloProvider.notifier).createArticulo(
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
          return await ref.read(articuloProvider.notifier).updateArticulo(
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
  void _showEntradaInventarioDialog(BuildContext context, ArticuloEntity articulo) {
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
  final Future<String> Function(String codArticulo, int codLinea, String descripcion, String descripcion2) onSubmit;

  const _ArticuloFormDialog({
    this.articulo,
    required this.onSubmit,
  });

  @override
  ConsumerState<_ArticuloFormDialog> createState() => _ArticuloFormDialogState();
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
    _codArticuloController = TextEditingController(text: widget.articulo?.codArticulo ?? '');
    _descripcionController = TextEditingController(text: widget.articulo?.descripcion ?? '');
    _descripcion2Controller = TextEditingController(text: widget.articulo?.descripcion2 ?? '');
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

    return AlertDialog(
      title: Text(widget.articulo == null ? 'Nuevo Artículo' : 'Editar Artículo'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Código de artículo
                TextFormField(
                  controller: _codArticuloController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Artículo',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                  ),
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
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Descripción 2
                TextFormField(
                  controller: _descripcion2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Descripción 2',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
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
                            IconButton.filled(
                              onPressed: () {
                                setState(() {
                                  _showLineaQuickAdd = !_showLineaQuickAdd;
                                });
                              },
                              icon: Icon(_showLineaQuickAdd ? Icons.close : Icons.add),
                              tooltip: _showLineaQuickAdd ? 'Cerrar' : 'Agregar línea rápida',
                            ),
                          ],
                        ),
                        
                        // Formulario rápido de línea
                        if (_showLineaQuickAdd) ...[
                          const SizedBox(height: 16),
                          _QuickLineaForm(
                            onLineaCreated: (nuevaLinea) {
                              setState(() {
                                _selectedLineaId = nuevaLinea.codLinea;
                                _showLineaQuickAdd = false;
                              });
                              ref.read(lineaProvider.notifier).loadLineas();
                            },
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _handleSubmit,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(widget.articulo == null ? 'Crear' : 'Actualizar'),
        ),
      ],
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
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
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
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Crear Línea Rápida',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Dropdown de Familias
            familiasAsync.when(
              data: (familias) {
                if (familias.isEmpty) {
                  return Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No hay familias disponibles. Crea una familia primero.',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Familia',
                    prefixIcon: Icon(Icons.folder_special),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedFamiliaId,
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
                  onChanged: _isCreating ? null : (value) {
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
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Error al cargar familias: ${ErrorMessages.getFriendlyMessage(error)}',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _lineaController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la línea',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              enabled: !_isCreating,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isCreating ? null : _createLinea,
                icon: _isCreating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Crear Línea'),
              ),
            ),
          ],
        ),
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
      await ref.read(lineaProvider.notifier).createLinea(
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
  State<_LineaSearchableDropdown> createState() => _LineaSearchableDropdownState();
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
    if (mounted) {
      _searchController.clear();
    }
    _searchQuery = '';
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
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: StatefulBuilder(
              builder: (context, setOverlayState) {
                return Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
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
                          decoration: InputDecoration(
                            hintText: 'Buscar línea...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
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
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setOverlayState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      
                      // Lista de líneas filtradas
                      Flexible(
                        child: Builder(
                          builder: (context) {
                            final filteredLineas = _searchQuery.isEmpty
                                ? widget.lineas
                                : widget.lineas.where((linea) {
                                    return linea.linea.toLowerCase().contains(_searchQuery) ||
                                        (linea.codLinea?.toString() ?? '').contains(_searchQuery);
                                  }).toList();

                            if (filteredLineas.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'No se encontraron líneas',
                                    style: TextStyle(color: Colors.grey),
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
                                final isSelected = linea.codLinea == widget.selectedLineaId;

                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  selectedTileColor: Colors.blue.shade50,
                                  leading: Icon(
                                    Icons.category,
                                    size: 20,
                                    color: isSelected ? Colors.blue : Colors.grey,
                                  ),
                                  title: Text(
                                    linea.linea,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Código: ${linea.codLinea}',
                                    style: const TextStyle(fontSize: 12),
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
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Línea',
                    prefixIcon: const Icon(Icons.category),
                    suffixIcon: Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                    border: const OutlineInputBorder(),
                    errorText: field.errorText,
                  ),
                  child: Text(
                    selectedLinea == null
                        ? ''
                        : '${selectedLinea.codLinea} - ${selectedLinea.linea}',
                    style: TextStyle(
                      color: selectedLinea == null ? Colors.grey : Colors.black,
                    ),
                  ),
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
  final TextEditingController _precioBaseController = TextEditingController(text: '');
  final TextEditingController _porcentajeController = TextEditingController(text: '30'); // 30% por defecto
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
      final precios = await ref.read(precioProvider.notifier).loadPreciosByArticulo(
        widget.articulo.codArticulo!,
      );
      
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
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.attach_money, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Gestionar Precios'),
          ),
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
                            Icon(Icons.inventory_2, 
                              size: 20, 
                              color: Colors.blue.shade700
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
                              Icon(Icons.price_check, 
                                size: 18, 
                                color: Colors.green.shade700
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          }).toList(),
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
                          Icon(Icons.info_outline, 
                            size: 18, 
                            color: Colors.grey.shade600
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
                    prefixIcon: Icon(Icons.monetization_on, color: Colors.green.shade600),
                    prefixText: '\$ ',
                    border: const OutlineInputBorder(),
                    helperText: 'Precio de costo o base del producto',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    prefixIcon: Icon(Icons.percent, color: Colors.purple.shade600),
                    suffixText: '%',
                    border: const OutlineInputBorder(),
                    helperText: 'Porcentaje de ganancia sobre el precio base',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                                    Icon(Icons.calculate, 
                                      size: 20, 
                                      color: Colors.blue.shade700
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.sell, 
                                          size: 16, 
                                          color: Colors.blue.shade700
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.money_off, 
                                          size: 16, 
                                          color: Colors.orange.shade700
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
                        final porcentaje = double.tryParse(porcentajeValue.text);
                        
                        double? ganancia;
                        
                        if (precioBase != null && porcentaje != null && precioBase > 0) {
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
                                    Icon(Icons.trending_up, 
                                      size: 18, 
                                      color: Colors.green.shade900
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Ganancia por unidad:', 
                                        style: TextStyle(fontSize: 12)
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
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
      final message = await ref.read(precioProvider.notifier).createPrecio(
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
  ConsumerState<_EntradaInventarioDialog> createState() => _EntradaInventarioDialogState();
}

class _EntradaInventarioDialogState extends ConsumerState<_EntradaInventarioDialog> {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _tipoMovimiento == 'ENTRADA' ? Colors.green.shade700 : Colors.red.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _tipoMovimiento == 'ENTRADA' ? Icons.arrow_downward : Icons.arrow_upward,
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
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
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
                      Icon(Icons.inventory_2, size: 20, color: context.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        widget.articulo.codArticulo ?? 'N/A',
                        style: context.theme.textTheme.titleMedium?.copyWith(
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
                              style: context.theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _tipoMovimiento = 'ENTRADA'),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      decoration: BoxDecoration(
                                      color: _tipoMovimiento == 'ENTRADA' 
                                          ? Colors.green.shade700 
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _tipoMovimiento == 'ENTRADA'
                                            ? Colors.green.shade700
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_downward,
                                          color: _tipoMovimiento == 'ENTRADA' 
                                              ? Colors.white 
                                              : Colors.green.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ENTRADA',
                                          style: TextStyle(
                                            color: _tipoMovimiento == 'ENTRADA' 
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
                                    onTap: () => setState(() => _tipoMovimiento = 'SALIDA'),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      decoration: BoxDecoration(
                                      color: _tipoMovimiento == 'SALIDA' 
                                          ? Colors.red.shade700 
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _tipoMovimiento == 'SALIDA'
                                            ? Colors.red.shade700
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_upward,
                                          color: _tipoMovimiento == 'SALIDA' 
                                              ? Colors.white 
                                              : Colors.red.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'SALIDA',
                                          style: TextStyle(
                                            color: _tipoMovimiento == 'SALIDA' 
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                              onPressed: _isLoading ? null : () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _registrarMovimiento,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(_tipoMovimiento == 'ENTRADA' ? Icons.check : Icons.remove),
                              label: Text(_isLoading 
                                  ? 'Guardando...' 
                                  : 'Registrar ${_tipoMovimiento == 'ENTRADA' ? 'Entrada' : 'Salida'}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _tipoMovimiento == 'ENTRADA' 
                                    ? Colors.green.shade700 
                                    : Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
      
      final result = await ref.read(inventarioProvider.notifier).crearMovimiento(
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
            backgroundColor: _tipoMovimiento == 'ENTRADA' ? Colors.green : Colors.red,
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
