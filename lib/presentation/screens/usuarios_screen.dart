import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/extensions.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

class UsuariosScreen extends ConsumerStatefulWidget {
  const UsuariosScreen({super.key});

  @override
  ConsumerState<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends ConsumerState<UsuariosScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar usuarios al iniciar
    Future.microtask(() {
      ref.read(usuarioProvider.notifier).cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      drawer: context.screenWidth < 600 ? const AppDrawer() : null,
      body: Row(
        children: [
          // Drawer permanente en desktop/tablet
          if (context.screenWidth >= 600)
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
            child: usuariosAsync.when(
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return const Center(
              child: Text('No hay usuarios registrados'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: usuarios.map((usuario) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: usuario.estado == 'D'
                          ? Colors.green
                          : Colors.red,
                      child: Text(
                        usuario.login.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      usuario.login,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo: ${usuario.tipoUsuario}'),
                        Text(
                          'Estado: ${usuario.estado == "D" ? "Desbloqueado" : "Bloqueado"}',
                        ),
                        Text('Auditoría: ${usuario.audUsuario}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(usuario),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(usuario),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(usuarioProvider.notifier).cargarUsuarios();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFromEmpleadoDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Usuario'),
      ),
    );
  }



  /// Mostrar diálogo para editar usuario
  void _showEditDialog(UsuarioEntity usuario) {
    showDialog(
      context: context,
      builder: (context) => _UsuarioFormDialog(
        title: 'Editar Usuario',
        usuario: usuario,
        onSave: (codEmpleado, login, password, tipoUsuario, estado) async {
          try {
            await ref.read(usuarioProvider.notifier).actualizar(
                  codUsuario: usuario.codUsuario,
                  codEmpleado: codEmpleado,
                  login: login,
                  password: password,
                  tipoUsuario: tipoUsuario,
                  estado: estado,
                );

            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          } on ApiException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  /// Mostrar diálogo para crear usuario desde empleado existente
  void _showCreateFromEmpleadoDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateUsuarioFromEmpleadoDialog(
        onSave: (codEmpleado, login, password, tipoUsuario, estado) async {
          try {
            await ref.read(usuarioProvider.notifier).crear(
                  codEmpleado: codEmpleado,
                  login: login,
                  password: password,
                  tipoUsuario: tipoUsuario,
                  estado: estado,
                );

            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          } on ApiException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  /// Confirmar eliminación
  void _confirmDelete(UsuarioEntity usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Está seguro que desea eliminar al usuario "${usuario.login}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await ref
                    .read(usuarioProvider.notifier)
                    .eliminar(usuario.codUsuario);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario eliminado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } on ApiException catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Diálogo reutilizable para crear/editar usuario
class _UsuarioFormDialog extends StatefulWidget {
  final String title;
  final UsuarioEntity? usuario;
  final Future<void> Function(
    int codEmpleado,
    String login,
    String? password,
    String tipoUsuario,
    String estado,
  ) onSave;

  const _UsuarioFormDialog({
    required this.title,
    this.usuario,
    required this.onSave,
  });

  @override
  State<_UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<_UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codEmpleadoController;
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  String _tipoUsuario = 'lim';
  String _estado = 'D'; // Cambiado de 'A' a 'D' para que coincida con las opciones
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codEmpleadoController = TextEditingController(
      text: widget.usuario?.codEmpleado.toString() ?? '',
    );
    _loginController = TextEditingController(
      text: widget.usuario?.login ?? '',
    );
    _passwordController = TextEditingController();

    if (widget.usuario != null) {
      _tipoUsuario = widget.usuario!.tipoUsuario;
      _estado = widget.usuario!.estado;
    }
  }

  @override
  void dispose() {
    _codEmpleadoController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.usuario != null;

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codEmpleadoController,
                decoration: const InputDecoration(
                  labelText: 'Código Empleado',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Debe ser un número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Login',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                  }
                  if (value.length < 3) {
                    return 'Mínimo 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isEditing
                      ? 'Contraseña (dejar vacío si no desea cambiar)'
                      : 'Contraseña',
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  // Si es creación, la contraseña es obligatoria
                  if (!isEditing && (value == null || value.isEmpty)) {
                    return 'Campo requerido';
                  }
                  // Si se ingresó contraseña, validar longitud mínima
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                decoration: const InputDecoration(
                  labelText: 'Tipo Usuario',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                  DropdownMenuItem(value: 'lim', child: Text('Limitado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoUsuario = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'D', child: Text('Desbloqueado')),
                  DropdownMenuItem(value: 'B', child: Text('Bloqueado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estado = value!;
                  });
                },
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
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final codEmpleado = int.parse(_codEmpleadoController.text);
      final login = _loginController.text;
      final password = _passwordController.text.isEmpty
          ? null
          : _passwordController.text;

      await widget.onSave(
        codEmpleado,
        login,
        password,
        _tipoUsuario,
        _estado,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Diálogo para crear usuario desde empleado existente
class _CreateUsuarioFromEmpleadoDialog extends ConsumerStatefulWidget {
  final Future<void> Function(
    int codEmpleado,
    String login,
    String password,
    String tipoUsuario,
    String estado,
  ) onSave;

  const _CreateUsuarioFromEmpleadoDialog({
    required this.onSave,
  });

  @override
  ConsumerState<_CreateUsuarioFromEmpleadoDialog> createState() =>
      _CreateUsuarioFromEmpleadoDialogState();
}

class _CreateUsuarioFromEmpleadoDialogState
    extends ConsumerState<_CreateUsuarioFromEmpleadoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  int? _selectedEmpleadoId;
  String _tipoUsuario = 'lim';
  String _estado = 'D';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    // Cargar empleados
    Future.microtask(
        () => ref.read(empleadoProvider.notifier).cargarEmpleados());
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empleadosAsync = ref.watch(empleadoProvider);

    return AlertDialog(
      title: const Text('Crear Usuario desde Empleado'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                empleadosAsync.when(
                  data: (empleados) {
                    if (empleados.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No hay empleados registrados.\nRegistre un empleado primero.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return FutureBuilder<Map<int, String>>(
                      future: _buildEmpleadosMap(empleados),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final empleadosMap = snapshot.data!;
                        
                        if (empleadosMap.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Todos los empleados ya tienen un usuario registrado.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<int>(
                          value: _selectedEmpleadoId,
                          decoration: const InputDecoration(
                            labelText: 'Seleccionar Empleado *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          isExpanded: true,
                          items: empleadosMap.entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEmpleadoId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Seleccione un empleado' : null,
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'Error al cargar empleados',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(empleadoProvider.notifier)
                                  .cargarEmpleados();
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _loginController,
                  decoration: const InputDecoration(
                    labelText: 'Login *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (value.length < 3) {
                      return 'Mínimo 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipoUsuario,
                  decoration: const InputDecoration(
                    labelText: 'Tipo Usuario *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrador',
                            overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'lim',
                        child: Text('Limitado', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoUsuario = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _estado,
                  decoration: const InputDecoration(
                    labelText: 'Estado *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.check_circle),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 'D',
                        child: Text('Desbloqueado',
                            overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'B',
                        child: Text('Bloqueado',
                            overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _estado = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear Usuario'),
        ),
      ],
    );
  }

  Future<Map<int, String>> _buildEmpleadosMap(List<dynamic> empleados) async {
    final Map<int, String> map = {};
    
    // Obtener lista de usuarios para filtrar empleados que ya tienen usuario
    final usuariosAsync = ref.read(usuarioProvider);
    final List<int> empleadosConUsuario = usuariosAsync.when(
      data: (usuarios) => usuarios.map((u) => u.codEmpleado).toList(),
      loading: () => [],
      error: (_, __) => [],
    );

    for (var empleado in empleados) {
      // Filtrar solo empleados que NO tienen usuario registrado
      if (empleadosConUsuario.contains(empleado.codEmpleado)) {
        continue;
      }
      
      try {
        final persona = await ref
            .read(personaProvider.notifier)
            .buscarPorCodigo(empleado.codPersona);

        if (persona != null) {
          map[empleado.codEmpleado] =
              '#${empleado.codEmpleado} - ${persona.nombreCompleto} (CI: ${persona.ciNumero})';
        }
      } catch (e) {
        map[empleado.codEmpleado] = '#${empleado.codEmpleado} - Empleado';
      }
    }

    return map;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEmpleadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un empleado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(
        _selectedEmpleadoId!,
        _loginController.text,
        _passwordController.text,
        _tipoUsuario,
        _estado,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
