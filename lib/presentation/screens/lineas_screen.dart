import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/linea_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/linea_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Pantalla de gestión de Líneas
class LineasScreen extends ConsumerStatefulWidget {
  const LineasScreen({super.key});

  @override
  ConsumerState<LineasScreen> createState() => _LineasScreenState();
}

class _LineasScreenState extends ConsumerState<LineasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lineaController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isEditing = false;
  int? _editingCodLinea;
  String _searchQuery = '';

  @override
  void dispose() {
    _lineaController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) {
      if (mounted) {
        context.showSnackBar('Error: Usuario no autenticado', isError: true);
      }
      return;
    }

    try {
      if (_isEditing && _editingCodLinea != null) {
        // Actualizar línea existente
        await ref.read(lineaProvider.notifier).updateLinea(
              codLinea: _editingCodLinea!,
              linea: _lineaController.text.trim(),
              audUsuario: user.codUsuario,
            );

        if (mounted) {
          context.showSnackBar('Línea actualizada exitosamente');
        }
      } else {
        // Crear nueva línea
        await ref.read(lineaProvider.notifier).createLinea(
              linea: _lineaController.text.trim(),
              audUsuario: user.codUsuario,
            );

        if (mounted) {
          context.showSnackBar('Línea creada exitosamente');
        }
      }

      _resetForm();
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _handleEdit(LineaEntity linea) {
    setState(() {
      _isEditing = true;
      _editingCodLinea = linea.codLinea;
      _lineaController.text = linea.linea;
    });
  }

  void _handleDelete(int codLinea) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar esta línea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(lineaProvider.notifier).deleteLinea(codLinea);

        if (mounted) {
          context.showSnackBar('Línea eliminada exitosamente');
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(
            'Error al eliminar: ${e.toString()}',
            isError: true,
          );
        }
      }
    }
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingCodLinea = null;
      _lineaController.clear();
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final lineasState = ref.watch(lineaProvider);
    final deviceType = context.deviceType;

    return Scaffold(
      appBar: deviceType != DeviceType.desktop
          ? AppBar(
              title: const Text('Gestión de Líneas'),
            )
          : null,
      drawer: deviceType != DeviceType.desktop ? const AppDrawer() : null,
      body: ResponsiveLayout(
        mobile: _buildContent(lineasState, isMobile: true),
        tablet: _buildContent(lineasState, isMobile: false),
        desktop: Row(
          children: [
            const SizedBox(
              width: 280,
              child: AppDrawer(),
            ),
            Expanded(
              child: _buildContent(lineasState, isMobile: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AsyncValue<List<LineaEntity>> lineasState, {required bool isMobile}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título en desktop
          if (!isMobile) ...[
            Text(
              'Gestión de Líneas',
              style: context.theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Formulario
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isEditing ? 'Editar Línea' : 'Nueva Línea',
                      style: context.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _lineaController,
                      label: 'Nombre de la Línea',
                      prefixIcon: Icons.category_outlined,
                      validator: (value) => Validators.required(
                        value,
                        fieldName: 'Línea',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: _isEditing ? 'Actualizar' : 'Guardar',
                            onPressed: _handleSubmit,
                            icon: _isEditing ? Icons.edit : Icons.save,
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomButton(
                              text: 'Cancelar',
                              onPressed: _resetForm,
                              icon: Icons.cancel_outlined,
                              isOutlined: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título y buscador
          Row(
            children: [
              Expanded(
                child: Text(
                  'Líneas Registradas',
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Campo de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar línea...',
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 8),

          // Usar SizedBox con altura fija para la lista
          SizedBox(
            height: 400, // Altura fija para la lista
            child: lineasState.when(
              data: (lineas) {
                // Filtrar líneas según la búsqueda
                final filteredLineas = _searchQuery.isEmpty
                    ? lineas
                    : lineas.where((linea) {
                        return linea.linea.toLowerCase().contains(_searchQuery) ||
                               (linea.codLinea?.toString() ?? '').contains(_searchQuery);
                      }).toList();

                if (lineas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay líneas registradas',
                          style: context.theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredLineas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron líneas',
                          style: context.theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otro término de búsqueda',
                          style: context.theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Card(
                  child: ListView.separated(
                    itemCount: filteredLineas.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final linea = filteredLineas[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.category,
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          linea.linea,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (linea.codLinea != null)
                              Text('Código: ${linea.codLinea}'),
                            if (linea.totalArticulos != null)
                              Text(
                                'Artículos: ${linea.totalArticulos} (${linea.articulosActivos ?? 0} activos)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _handleEdit(linea),
                              tooltip: 'Editar',
                              color: context.colorScheme.primary,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: linea.codLinea != null
                                  ? () => _handleDelete(linea.codLinea!)
                                  : null,
                              tooltip: 'Eliminar',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar líneas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          error.toString().length > 200
                              ? '${error.toString().substring(0, 200)}...'
                              : error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.read(lineaProvider.notifier).loadLineas(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ), // Cierre del SizedBox
        ],
      ),
    );
  }
}
