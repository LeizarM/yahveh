import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/entities/zona_entity.dart';
import '../../data/models/zona_model.dart';
import '../providers/zona_provider.dart';
import '../providers/ciudad_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Zonas con CRUD completo
class ZonasScreen extends ConsumerStatefulWidget {
  const ZonasScreen({super.key});

  @override
  ConsumerState<ZonasScreen> createState() => _ZonasScreenState();
}

class _ZonasScreenState extends ConsumerState<ZonasScreen> {
  @override
  Widget build(BuildContext context) {
    final zonasAsync = ref.watch(zonaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zonas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddZonaDialog(context),
            tooltip: 'Agregar zona',
          ),
        ],
      ),
      drawer: context.isMobile ? const AppDrawer() : null,
      body: Row(
        children: [
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
          Expanded(
            child: zonasAsync.when(
              data: (zonas) {
                if (zonas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No hay zonas registradas', style: context.theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text('Agrega la primera zona usando el botón +'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: zonas.length,
                  itemBuilder: (context, index) {
                    final zona = zonas[index];
                    final zonaModel = zona is ZonaModel ? zona : null;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colorScheme.primaryContainer,
                          child: Icon(Icons.map, color: context.colorScheme.primary),
                        ),
                        title: Text(zona.zona),
                        subtitle: Text(
                          zonaModel?.ciudadNombre != null && zonaModel?.paisNombre != null
                              ? '${zonaModel!.ciudadNombre} - ${zonaModel.paisNombre}'
                              : 'Ciudad ID: ${zona.codCiudad}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditZonaDialog(context, zona),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(context, zona),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddZonaDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ZonaFormDialog(
        onSubmit: (codCiudad, zona) async {
          final user = ref.read(authProvider).value;
          await ref.read(zonaProvider.notifier).createZona(
                codCiudad: codCiudad,
                zona: zona,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showEditZonaDialog(BuildContext context, ZonaEntity zona) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ZonaFormDialog(
        zona: zona,
        onSubmit: (codCiudad, zonaNombre) async {
          final user = ref.read(authProvider).value;
          await ref.read(zonaProvider.notifier).updateZona(
                codZona: zona.codZona,
                codCiudad: codCiudad,
                zona: zonaNombre,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ZonaEntity zona) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar la zona "${zona.zona}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(zonaProvider.notifier).deleteZona(zona.codZona);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Zona eliminada')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Formulario de zona
class _ZonaFormDialog extends ConsumerStatefulWidget {
  final ZonaEntity? zona;
  final Future<void> Function(int codCiudad, String zona) onSubmit;

  const _ZonaFormDialog({this.zona, required this.onSubmit});

  @override
  ConsumerState<_ZonaFormDialog> createState() => _ZonaFormDialogState();
}

class _ZonaFormDialogState extends ConsumerState<_ZonaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _zonaController;
  int? _selectedCiudadId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _zonaController = TextEditingController(text: widget.zona?.zona ?? '');
    _selectedCiudadId = widget.zona?.codCiudad;
  }

  @override
  void dispose() {
    _zonaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ciudadesAsync = ref.watch(ciudadProvider);

    return AlertDialog(
      title: Text(widget.zona == null ? 'Agregar Zona' : 'Editar Zona'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown de Ciudad
              ciudadesAsync.when(
                data: (ciudades) {
                  if (ciudades.isEmpty) {
                    return Card(
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No hay ciudades registradas.\nPrimero debes crear una ciudad.',
                                style: TextStyle(color: Colors.orange[900]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<int>(
                    value: _selectedCiudadId,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad *',
                      border: OutlineInputBorder(),
                      helperText: 'Selecciona la ciudad a la que pertenece la zona',
                    ),
                    items: ciudades.map((ciudad) {
                      // Intentar obtener el modelo con paisNombre
                      final ciudadModel = ciudad as dynamic;
                      final paisNombre = ciudadModel.paisNombre ?? '';
                      final displayText = paisNombre.isNotEmpty
                          ? '${ciudad.ciudad} - $paisNombre'
                          : ciudad.ciudad;

                      return DropdownMenuItem(
                        value: ciudad.codCiudad,
                        child: Text(displayText),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCiudadId = value),
                    validator: (value) => value == null ? 'Selecciona una ciudad' : null,
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Error al cargar ciudades: $e',
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Campo de Zona
              TextFormField(
                controller: _zonaController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Zona *',
                  border: OutlineInputBorder(),
                  helperText: 'Ejemplo: Zona Norte, Zona Centro, etc.',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'El nombre es requerido' : null,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.zona == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSubmit(_selectedCiudadId!, _zonaController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.zona == null ? 'Zona creada correctamente' : 'Zona actualizada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
