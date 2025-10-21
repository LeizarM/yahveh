import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/entities/articulo_entity.dart';
import '../../domain/entities/linea_entity.dart';
import '../providers/articulo_provider.dart';
import '../providers/linea_provider.dart';
import '../providers/auth_provider.dart';
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar artículos',
                      style: context.theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString().substring(0, error.toString().length > 100 ? 100 : error.toString().length),
                      style: context.theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.read(articuloProvider.notifier).loadArticulos(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
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
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
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
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
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

  /// Card de artículo
  Widget _buildItemCard(BuildContext context, ArticuloEntity articulo) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemDetails(context, articulo),
        child: SizedBox(
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen/Ícono
              Container(
                height: 100,
                color: context.colorScheme.primaryContainer,
                child: Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: 48,
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
                        articulo.descripcion,
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        articulo.linea ?? 'Sin línea',
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${articulo.precioActual?.toStringAsFixed(2) ?? "0.00"}',
                                  style: context.theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Stock: ${articulo.stockActual ?? 0}',
                                  style: context.theme.textTheme.bodySmall?.copyWith(
                                    color: (articulo.stockActual ?? 0) > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            articulo.codArticulo ?? "N/A",
                            style: context.theme.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
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
                  await ref.read(articuloProvider.notifier).deleteArticulo(articulo.codArticulo!);
                  if (context.mounted) {
                    context.showSnackBar('Artículo eliminado correctamente');
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showSnackBar('Error al eliminar artículo: $e');
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
          await ref.read(articuloProvider.notifier).createArticulo(
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
          await ref.read(articuloProvider.notifier).updateArticulo(
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
}

/// Formulario de artículo (crear/editar)
class _ArticuloFormDialog extends ConsumerStatefulWidget {
  final ArticuloEntity? articulo;
  final Future<void> Function(String codArticulo, int codLinea, String descripcion, String descripcion2) onSubmit;

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
      await widget.onSubmit(
        _codArticuloController.text,
        _selectedLineaId!,
        _descripcionController.text,
        _descripcion2Controller.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.articulo == null
                ? 'Artículo creado correctamente'
                : 'Artículo actualizado correctamente'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
  bool _isCreating = false;

  @override
  void dispose() {
    _lineaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    setState(() => _isCreating = true);

    try {
      final userAsync = ref.read(authProvider);
      final user = userAsync.value;
      await ref.read(lineaProvider.notifier).createLinea(
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
            content: Text('Error: $e'),
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
