import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/extensions.dart';
import '../providers/providers.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UsuarioEntity? _currentUser;
  dynamic _empleado;
  dynamic _persona;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener información del usuario actual desde el auth provider
      final authState = ref.read(authProvider);
      
      // Extraer el UserEntity del AsyncValue usando when
      UserEntity? userEntity;
      authState.when(
        data: (user) => userEntity = user,
        loading: () => null,
        error: (_, __) => null,
      );

      if (userEntity == null) {
        throw ApiException(
          message: 'No se pudo obtener información del usuario',
          statusCode: 401,
        );
      }

      final codUsuario = userEntity!.codUsuario;
      final usuario =
          await ref.read(usuarioProvider.notifier).buscarPorCodigo(codUsuario);

      // Cargar datos del empleado
      try {
        final empleado = await ref.read(empleadoProvider.notifier).buscarPorCodigo(usuario!.codEmpleado);
        if (empleado != null) {
          _empleado = empleado;
          
          // Cargar datos de la persona
          try {
            final persona = await ref.read(personaProvider.notifier).buscarPorCodigo(empleado.codPersona);
            _persona = persona;
          } catch (e) {
            print('Error al cargar persona: $e');
          }
        }
      } catch (e) {
        print('Error al cargar empleado: $e');
      }

      setState(() {
        _currentUser = usuario;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
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
            child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('No se pudo cargar el perfil'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCurrentUser,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar y nombre
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                _persona != null
                                    ? _persona!.nombres.substring(0, 1).toUpperCase()
                                    : _currentUser!.login.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _persona?.nombreCompleto ?? _currentUser!.login,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            if (_persona != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '@${_currentUser!.login}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Información de la Persona
                      if (_persona != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Datos Personales',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Nombre Completo',
                                  _persona!.nombreCompleto,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'CI',
                                  '${_persona!.ciNumero} ${_persona!.ciExpedido}',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Dirección',
                                  _persona!.direccion,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Lugar de Nacimiento',
                                  _persona!.lugarNacimiento,
                                ),
                                if (_empleado != null) ...[
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    'Código Empleado',
                                    '#${_empleado!.codEmpleado}',
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      if (_persona != null) const SizedBox(height: 16),

                      // Información del usuario
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Información de Usuario',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Login',
                                _currentUser!.login,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Tipo Usuario',
                                _currentUser!.tipoUsuario == 'admin'
                                    ? 'Administrador'
                                    : 'Limitado',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Estado',
                                _currentUser!.estado == 'D'
                                    ? 'Desbloqueado'
                                    : 'Bloqueado',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'ID Usuario',
                                '#${_currentUser!.codUsuario}',
                              ),
                              if (_empleado != null) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'ID Empleado',
                                  '#${_currentUser!.codEmpleado}',
                                ),
                              ],
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Creado por',
                                _currentUser!.audUsuario.toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón para cambiar contraseña
                      ElevatedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        icon: const Icon(Icons.lock),
                        label: const Text('Cambiar Contraseña'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(
        onSave: (newPassword) async {
          try {
            await ref.read(usuarioProvider.notifier).actualizar(
                  codUsuario: _currentUser!.codUsuario,
                  codEmpleado: _currentUser!.codEmpleado,
                  login: _currentUser!.login,
                  password: newPassword,
                  tipoUsuario: _currentUser!.tipoUsuario,
                  estado: _currentUser!.estado,
                );

            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contraseña actualizada exitosamente'),
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
}

/// Diálogo para cambiar contraseña
class _ChangePasswordDialog extends StatefulWidget {
  final Future<void> Function(String newPassword) onSave;

  const _ChangePasswordDialog({required this.onSave});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar Contraseña'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
              ),
              obscureText: _obscureNew,
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirm,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido';
                }
                if (value != _newPasswordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
          ],
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
      await widget.onSave(_newPasswordController.text);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
