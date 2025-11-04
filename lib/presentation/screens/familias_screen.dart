import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/familia_entity.dart';
import '../providers/familia_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Familias con CRUD completo
class FamiliasScreen extends ConsumerStatefulWidget {
  const FamiliasScreen({super.key});

  @override
  ConsumerState<FamiliasScreen> createState() => _FamiliasScreenState();
}

class _FamiliasScreenState extends ConsumerState<FamiliasScreen> {
  @override
  Widget build(BuildContext context) {
    final familiasAsync = ref.watch(familiaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Familias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFamiliaDialog(context),
            tooltip: 'Agregar familia',
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
            child: familiasAsync.when(
              data: (familias) {
                if (familias.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildFamiliasList(familias);
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
                        'No se pudieron cargar las familias',
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
                        onPressed: () => ref.refresh(familiaProvider),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay familias registradas',
            style: context.theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Agrega la primera familia usando el botón +'),
        ],
      ),
    );
  }

  Widget _buildFamiliasList(List<FamiliaEntity> familias) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: familias.length,
      itemBuilder: (context, index) {
        final familia = familias[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colorScheme.primaryContainer,
              child: Icon(
                Icons.category,
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              familia.familia,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('Código: ${familia.codFamilia}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditFamiliaDialog(context, familia),
                  tooltip: 'Editar',
                  color: context.colorScheme.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showDeleteConfirmation(context, familia),
                  tooltip: 'Eliminar',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddFamiliaDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _FamiliaFormDialog(
        onSubmit: (familia) async {
          final user = ref.read(authProvider).value;
          await ref.read(familiaProvider.notifier).createFamilia(
                familia: familia,
                audUsuario: user!.codUsuario,
              );
        },
      ),
    );
  }

  void _showEditFamiliaDialog(BuildContext context, FamiliaEntity familia) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _FamiliaFormDialog(
        familia: familia,
        onSubmit: (familiaNombre) async {
          final user = ref.read(authProvider).value;
          await ref.read(familiaProvider.notifier).updateFamilia(
                codFamilia: familia.codFamilia,
                familia: familiaNombre,
                audUsuario: user!.codUsuario,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FamiliaEntity familia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar la familia "${familia.familia}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(familiaProvider.notifier).deleteFamilia(familia.codFamilia);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Familia eliminada')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ErrorMessages.getCrudErrorMessage('delete', e))),
                  );
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

/// Formulario de familia (crear/editar)
class _FamiliaFormDialog extends ConsumerStatefulWidget {
  final FamiliaEntity? familia;
  final Future<void> Function(String familia) onSubmit;

  const _FamiliaFormDialog({
    this.familia,
    required this.onSubmit,
  });

  @override
  ConsumerState<_FamiliaFormDialog> createState() => _FamiliaFormDialogState();
}

class _FamiliaFormDialogState extends ConsumerState<_FamiliaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _familiaController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _familiaController = TextEditingController(text: widget.familia?.familia ?? '');
  }

  @override
  void dispose() {
    _familiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.familia == null ? 'Agregar Familia' : 'Editar Familia'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _familiaController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Familia *',
                  border: OutlineInputBorder(),
                  helperText: 'Ej: Electrónica, Ropa, Alimentos',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre de la familia es requerido';
                  }
                  return null;
                },
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
              : Text(widget.familia == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSubmit(_familiaController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.familia == null ? 'Familia creada correctamente' : 'Familia actualizada correctamente',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final operation = widget.familia == null ? 'create' : 'update';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.getCrudErrorMessage(operation, e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
