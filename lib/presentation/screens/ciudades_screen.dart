import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/entities/ciudad_entity.dart';
import '../../data/models/ciudad_model.dart';
import '../providers/ciudad_provider.dart';
import '../providers/pais_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Ciudades con CRUD completo
class CiudadesScreen extends ConsumerStatefulWidget {
  const CiudadesScreen({super.key});

  @override
  ConsumerState<CiudadesScreen> createState() => _CiudadesScreenState();
}

class _CiudadesScreenState extends ConsumerState<CiudadesScreen> {
  @override
  Widget build(BuildContext context) {
    final ciudadesAsync = ref.watch(ciudadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciudades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCiudadDialog(context),
            tooltip: 'Agregar ciudad',
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
            child: ciudadesAsync.when(
              data: (ciudades) {
                if (ciudades.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_city_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No hay ciudades registradas', style: context.theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text('Agrega la primera ciudad usando el botón +'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ciudades.length,
                  itemBuilder: (context, index) {
                    final ciudad = ciudades[index];
                    final ciudadModel = ciudad is CiudadModel ? ciudad : null;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colorScheme.primaryContainer,
                          child: Icon(Icons.location_city, color: context.colorScheme.primary),
                        ),
                        title: Text(ciudad.ciudad),
                        subtitle: Text('País: ${ciudadModel?.paisNombre ?? "ID ${ciudad.codPais}"}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditCiudadDialog(context, ciudad),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(context, ciudad),
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

  void _showAddCiudadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CiudadFormDialog(
        onSubmit: (codPais, ciudad) async {
          final user = ref.read(authProvider).value;
          await ref.read(ciudadProvider.notifier).createCiudad(
                codPais: codPais,
                ciudad: ciudad,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showEditCiudadDialog(BuildContext context, CiudadEntity ciudad) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CiudadFormDialog(
        ciudad: ciudad,
        onSubmit: (codPais, ciudadNombre) async {
          final user = ref.read(authProvider).value;
          await ref.read(ciudadProvider.notifier).updateCiudad(
                codCiudad: ciudad.codCiudad,
                codPais: codPais,
                ciudad: ciudadNombre,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CiudadEntity ciudad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar "${ciudad.ciudad}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(ciudadProvider.notifier).deleteCiudad(ciudad.codCiudad);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ciudad eliminada')),
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

/// Formulario de ciudad
class _CiudadFormDialog extends ConsumerStatefulWidget {
  final CiudadEntity? ciudad;
  final Future<void> Function(int codPais, String ciudad) onSubmit;

  const _CiudadFormDialog({this.ciudad, required this.onSubmit});

  @override
  ConsumerState<_CiudadFormDialog> createState() => _CiudadFormDialogState();
}

class _CiudadFormDialogState extends ConsumerState<_CiudadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ciudadController;
  int? _selectedPaisId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ciudadController = TextEditingController(text: widget.ciudad?.ciudad ?? '');
    _selectedPaisId = widget.ciudad?.codPais;
  }

  @override
  void dispose() {
    _ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paisesAsync = ref.watch(paisProvider);

    return AlertDialog(
      title: Text(widget.ciudad == null ? 'Agregar Ciudad' : 'Editar Ciudad'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              paisesAsync.when(
                data: (paises) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedPaisId,
                    decoration: const InputDecoration(
                      labelText: 'País *',
                      border: OutlineInputBorder(),
                    ),
                    items: paises.map((pais) {
                      return DropdownMenuItem(
                        value: pais.codPais,
                        child: Text(pais.pais),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedPaisId = value),
                    validator: (value) => value == null ? 'Selecciona un país' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error al cargar países: $e'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ciudadController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Ciudad *',
                  border: OutlineInputBorder(),
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
              : Text(widget.ciudad == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSubmit(_selectedPaisId!, _ciudadController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.ciudad == null ? 'Ciudad creada' : 'Ciudad actualizada')),
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
