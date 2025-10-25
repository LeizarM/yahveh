import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/entities/cliente_entity.dart';
import '../../data/models/cliente_model.dart';
import '../providers/cliente_provider.dart';
import '../providers/zona_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Clientes con CRUD completo
class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clienteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddClienteDialog(context),
            tooltip: 'Agregar cliente',
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
            child: Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar cliente',
                      hintText: 'Nombre, NIT, razón social...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                // Lista de clientes
                Expanded(
                  child: clientesAsync.when(
                    data: (clientes) {
                      final filteredClientes = _searchQuery.isEmpty
                          ? clientes
                          : clientes.where((c) {
                              return c.nombreCliente.toLowerCase().contains(_searchQuery) ||
                                  c.nit.toLowerCase().contains(_searchQuery) ||
                                  c.razonSocial.toLowerCase().contains(_searchQuery);
                            }).toList();

                      if (filteredClientes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No hay clientes registrados'
                                    : 'No se encontraron clientes',
                                style: context.theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Agrega el primer cliente usando el botón +'
                                    : 'Intenta con otra búsqueda',
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredClientes.length,
                        itemBuilder: (context, index) {
                          final cliente = filteredClientes[index];
                          final clienteModel = cliente is ClienteModel ? cliente : null;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: context.colorScheme.primaryContainer,
                                child: Text(
                                  cliente.nombreCliente[0].toUpperCase(),
                                  style: TextStyle(
                                    color: context.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                cliente.nombreCliente,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('NIT: ${cliente.nit}'),
                                  if (clienteModel?.zonaNombre != null)
                                    Text(
                                      '📍 ${clienteModel!.zonaNombre}'
                                      '${clienteModel.ciudadNombre != null ? " - ${clienteModel.ciudadNombre}" : ""}'
                                      '${clienteModel.paisNombre != null ? " - ${clienteModel.paisNombre}" : ""}',
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
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditClienteDialog(context, cliente),
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _showDeleteConfirmation(context, cliente),
                                    color: Colors.red,
                                    tooltip: 'Eliminar',
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow('Razón Social', cliente.razonSocial),
                                      _buildDetailRow('Dirección', cliente.direccion),
                                      _buildDetailRow('Referencia', cliente.referencia),
                                      if (cliente.obs.isNotEmpty)
                                        _buildDetailRow('Observaciones', cliente.obs),
                                    ],
                                  ),
                                ),
                              ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddClienteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ClienteFormDialog(
        onSubmit: (codZona, nit, razonSocial, nombreCliente, direccion, referencia, obs) async {
          final user = ref.read(authProvider).value;
          await ref.read(clienteProvider.notifier).createCliente(
                codZona: codZona,
                nit: nit,
                razonSocial: razonSocial,
                nombreCliente: nombreCliente,
                direccion: direccion,
                referencia: referencia,
                obs: obs,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showEditClienteDialog(BuildContext context, ClienteEntity cliente) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ClienteFormDialog(
        cliente: cliente,
        onSubmit: (codZona, nit, razonSocial, nombreCliente, direccion, referencia, obs) async {
          final user = ref.read(authProvider).value;
          await ref.read(clienteProvider.notifier).updateCliente(
                codCliente: cliente.codCliente,
                codZona: codZona,
                nit: nit,
                razonSocial: razonSocial,
                nombreCliente: nombreCliente,
                direccion: direccion,
                referencia: referencia,
                obs: obs,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClienteEntity cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar al cliente "${cliente.nombreCliente}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(clienteProvider.notifier).deleteCliente(cliente.codCliente);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente eliminado')),
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

/// Formulario de cliente
class _ClienteFormDialog extends ConsumerStatefulWidget {
  final ClienteEntity? cliente;
  final Future<void> Function(
    int codZona,
    String nit,
    String razonSocial,
    String nombreCliente,
    String direccion,
    String referencia,
    String obs,
  ) onSubmit;

  const _ClienteFormDialog({this.cliente, required this.onSubmit});

  @override
  ConsumerState<_ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends ConsumerState<_ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nitController;
  late TextEditingController _razonSocialController;
  late TextEditingController _nombreClienteController;
  late TextEditingController _direccionController;
  late TextEditingController _referenciaController;
  late TextEditingController _obsController;
  int? _selectedZonaId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nitController = TextEditingController(text: widget.cliente?.nit ?? '');
    _razonSocialController = TextEditingController(text: widget.cliente?.razonSocial ?? '');
    _nombreClienteController = TextEditingController(text: widget.cliente?.nombreCliente ?? '');
    _direccionController = TextEditingController(text: widget.cliente?.direccion ?? '');
    _referenciaController = TextEditingController(text: widget.cliente?.referencia ?? '');
    _obsController = TextEditingController(text: widget.cliente?.obs ?? '');
    _selectedZonaId = widget.cliente?.codZona;
  }

  @override
  void dispose() {
    _nitController.dispose();
    _razonSocialController.dispose();
    _nombreClienteController.dispose();
    _direccionController.dispose();
    _referenciaController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zonasAsync = ref.watch(zonaProvider);

    return AlertDialog(
      title: Text(widget.cliente == null ? 'Agregar Cliente' : 'Editar Cliente'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown de Zona
                zonasAsync.when(
                  data: (zonas) {
                    if (zonas.isEmpty) {
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
                                  'No hay zonas registradas.\nPrimero debes crear una zona.',
                                  style: TextStyle(color: Colors.orange[900]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      value: _selectedZonaId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Zona *',
                        border: OutlineInputBorder(),
                        helperText: 'Zona - Ciudad - País',
                      ),
                      items: zonas.map((zona) {
                        final zonaModel = zona as dynamic;
                        final ciudadNombre = zonaModel.ciudadNombre ?? '';
                        final paisNombre = zonaModel.paisNombre ?? '';
                        
                        String displayText = zona.zona;
                        if (ciudadNombre.isNotEmpty && paisNombre.isNotEmpty) {
                          displayText = '${zona.zona} - $ciudadNombre - $paisNombre';
                        } else if (ciudadNombre.isNotEmpty) {
                          displayText = '${zona.zona} - $ciudadNombre';
                        }

                        return DropdownMenuItem(
                          value: zona.codZona,
                          child: Text(
                            displayText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedZonaId = value),
                      validator: (value) => value == null ? 'Selecciona una zona' : null,
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
                        'Error al cargar zonas: $e',
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // NIT
                TextFormField(
                  controller: _nitController,
                  decoration: const InputDecoration(
                    labelText: 'NIT *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'El NIT es requerido' : null,
                ),
                const SizedBox(height: 16),
                // Razón Social
                TextFormField(
                  controller: _razonSocialController,
                  decoration: const InputDecoration(
                    labelText: 'Razón Social *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'La razón social es requerida' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                // Nombre del Cliente
                TextFormField(
                  controller: _nombreClienteController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Cliente *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'El nombre es requerido' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                // Dirección
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'La dirección es requerida' : null,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Referencia
                TextFormField(
                  controller: _referenciaController,
                  decoration: const InputDecoration(
                    labelText: 'Referencia *',
                    border: OutlineInputBorder(),
                    helperText: 'Punto de referencia para ubicar',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'La referencia es requerida' : null,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Observaciones
                TextFormField(
                  controller: _obsController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    border: OutlineInputBorder(),
                    helperText: 'Opcional',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
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
        FilledButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.cliente == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSubmit(
        _selectedZonaId!,
        _nitController.text.trim(),
        _razonSocialController.text.trim(),
        _nombreClienteController.text.trim(),
        _direccionController.text.trim(),
        _referenciaController.text.trim(),
        _obsController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cliente == null ? 'Cliente creado correctamente' : 'Cliente actualizado correctamente',
            ),
          ),
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
