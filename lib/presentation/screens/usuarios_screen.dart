import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../core/error/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/animations.dart';
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
    Future.microtask(() {
      ref.read(usuarioProvider.notifier).cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuarioProvider);
    final isMobile = context.screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(usuarioProvider.notifier).cargarUsuarios(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: isMobile ? _buildBlurredDrawer() : null,
      floatingActionButton: FadeSlideAnimation(
        delay: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: _showCreateFromEmpleadoDialog,
          backgroundColor: AppTheme.accentPink,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nuevo Usuario', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Row(
          children: [
            if (!isMobile) _buildPermanentDrawer(),
            Expanded(
              child: SafeArea(
                child: usuariosAsync.when(
                  data: (usuarios) => _buildContent(usuarios),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1D2E).withValues(alpha: 0.95),
                  const Color(0xFF2D3250).withValues(alpha: 0.92),
                ],
              ),
            ),
            child: const AppDrawer(),
          ),
        ),
      ),
    );
  }

  Widget _buildPermanentDrawer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E).withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
    );
  }

  Widget _buildContent(List<UsuarioEntity> usuarios) {
    if (usuarios.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final usuario = usuarios[index];
        return FadeSlideAnimation(
          delay: Duration(milliseconds: 50 * index),
          child: _buildUsuarioCard(usuario),
        );
      },
    );
  }

  Widget _buildUsuarioCard(UsuarioEntity usuario) {
    final isActive = usuario.estado == 'D';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditDialog(usuario),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: (isActive ? AppTheme.accentGreen : AppTheme.accentOrange).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      usuario.login.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppTheme.accentGreen : AppTheme.accentOrange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.login,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPink.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              usuario.tipoUsuario.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentPink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isActive ? AppTheme.accentGreen : AppTheme.accentOrange).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isActive ? 'ACTIVO' : 'BLOQUEADO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isActive ? AppTheme.accentGreen : AppTheme.accentOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      onPressed: () => _showEditDialog(usuario),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: AppTheme.accentOrange.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      onPressed: () => _confirmDelete(usuario),
                      tooltip: 'Eliminar',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_off_rounded,
              size: 50,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay usuarios registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea un usuario para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando usuarios...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar usuarios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(usuarioProvider.notifier).cargarUsuarios(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
              _buildSnackBar('Usuario actualizado exitosamente'),
            );
          } on ApiException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              _buildSnackBar('Error: ${e.message}', isError: true),
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
              _buildSnackBar('Usuario creado exitosamente'),
            );
          } on ApiException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              _buildSnackBar(e.message, isError: true),
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
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2D3250).withValues(alpha: 0.95),
                const Color(0xFF1A1D2E).withValues(alpha: 0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 32,
                  color: AppTheme.accentOrange,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '¿Eliminar Usuario?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción eliminará al usuario "${usuario.login}" de forma permanente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        try {
                          await ref.read(usuarioProvider.notifier).eliminar(usuario.codUsuario);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            _buildSnackBar('Usuario eliminado'),
                          );
                        } on ApiException catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            _buildSnackBar('Error: ${e.message}', isError: true),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SnackBar _buildSnackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.errorColor : AppTheme.accentGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
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

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2D3250).withValues(alpha: 0.95),
              const Color(0xFF1A1D2E).withValues(alpha: 0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.accentPink,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _codEmpleadoController,
                  label: 'Código Empleado',
                  icon: Icons.badge_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo requerido';
                    if (int.tryParse(value) == null) return 'Debe ser un número';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _loginController,
                  label: 'Login',
                  icon: Icons.account_circle_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo requerido';
                    if (value.length < 3) return 'Mínimo 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: isEditing ? 'Contraseña (opcional)' : 'Contraseña',
                  icon: Icons.lock_rounded,
                  obscureText: true,
                  validator: (value) {
                    if (!isEditing && (value == null || value.isEmpty)) return 'Campo requerido';
                    if (value != null && value.isNotEmpty && value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  value: _tipoUsuario,
                  label: 'Tipo Usuario',
                  icon: Icons.admin_panel_settings_rounded,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    DropdownMenuItem(value: 'lim', child: Text('Limitado')),
                  ],
                  onChanged: (value) => setState(() => _tipoUsuario = value!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  value: _estado,
                  label: 'Estado',
                  icon: Icons.check_circle_rounded,
                  items: const [
                    DropdownMenuItem(value: 'D', child: Text('Desbloqueado')),
                    DropdownMenuItem(value: 'B', child: Text('Bloqueado')),
                  ],
                  onChanged: (value) => setState(() => _estado = value!),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Guardar',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      cursorColor: AppTheme.accentPink,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: AppTheme.accentPink, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: AppTheme.accentPink),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      dropdownColor: const Color(0xFF1A1D2E),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: AppTheme.accentPink, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: AppTheme.accentPink),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentPink, width: 2),
        ),
      ),
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
                          initialValue: _selectedEmpleadoId,
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
                  initialValue: _tipoUsuario,
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
                  initialValue: _estado,
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
