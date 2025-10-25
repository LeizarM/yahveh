import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/entities/pais_entity.dart';
import '../providers/pais_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Países con CRUD completo
class PaisesScreen extends ConsumerStatefulWidget {
  const PaisesScreen({super.key});

  @override
  ConsumerState<PaisesScreen> createState() => _PaisesScreenState();
}

class _PaisesScreenState extends ConsumerState<PaisesScreen> {
  @override
  Widget build(BuildContext context) {
    final paisesAsync = ref.watch(paisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Países'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddPaisDialog(context);
            },
            tooltip: 'Agregar país',
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
            child: paisesAsync.when(
              data: (paises) {
                if (paises.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildPaisesList(paises);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
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
            Icons.public_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay países registrados',
            style: context.theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Agrega el primer país usando el botón +'),
        ],
      ),
    );
  }

  Widget _buildPaisesList(List<PaisEntity> paises) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paises.length,
      itemBuilder: (context, index) {
        final pais = paises[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colorScheme.primaryContainer,
              child: Icon(
                Icons.public,
                color: context.colorScheme.primary,
              ),
            ),
            title: Text(pais.pais),
            subtitle: Text('ID: ${pais.codPais}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditPaisDialog(context, pais),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(context, pais),
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

  void _showAddPaisDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaisFormDialog(
        onSubmit: (pais) async {
          final userAsync = ref.read(authProvider);
          final user = userAsync.value;
          await ref.read(paisProvider.notifier).createPais(
                pais: pais,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showEditPaisDialog(BuildContext context, PaisEntity pais) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaisFormDialog(
        pais: pais,
        onSubmit: (paisNombre) async {
          final userAsync = ref.read(authProvider);
          final user = userAsync.value;
          await ref.read(paisProvider.notifier).updatePais(
                codPais: pais.codPais,
                pais: paisNombre,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PaisEntity pais) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar "${pais.pais}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(paisProvider.notifier).deletePais(pais.codPais);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('País eliminado correctamente')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
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

/// Formulario de país (crear/editar)
class _PaisFormDialog extends ConsumerStatefulWidget {
  final PaisEntity? pais;
  final Future<void> Function(String pais) onSubmit;

  const _PaisFormDialog({
    this.pais,
    required this.onSubmit,
  });

  @override
  ConsumerState<_PaisFormDialog> createState() => _PaisFormDialogState();
}

class _PaisFormDialogState extends ConsumerState<_PaisFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _paisController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paisController = TextEditingController(text: widget.pais?.pais ?? '');
  }

  @override
  void dispose() {
    _paisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pais == null ? 'Agregar País' : 'Editar País'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _paisController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del País *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre del país es requerido';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.pais == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSubmit(_paisController.text.trim());

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.pais == null
                  ? 'País creado correctamente'
                  : 'País actualizado correctamente',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
