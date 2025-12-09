
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yahveh/core/utils/error_messages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import 'dart:math' as math;

/// Pantalla de Login con diseño moderno y animaciones
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Animaciones
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .login(_usernameController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Escuchar cambios en el estado de autenticación para mostrar errores
    // La navegación al dashboard se maneja automáticamente por el router
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      console('🔔 Login listener - previous: $previous, next: $next');

      if (next.hasError) {
        final error = next.error;
        console('❌ Error detectado en login: $error');

        final errorMessage = _parseErrorMessage(error.toString());
        final errorIcon = _getErrorIcon(error.toString());

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(errorIcon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Error de autenticación',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(errorMessage, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });

    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            // Partículas de fondo animadas
            ...List.generate(15, (index) => _buildParticle(index)),

            // Círculos decorativos
            Positioned(
              top: -100,
              right: -100,
              child: _buildDecorativeCircle(250, 0.08),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _buildDecorativeCircle(280, 0.06),
            ),
            Positioned(
              top: context.screenHeight * 0.3,
              left: -50,
              child: _buildDecorativeCircle(100, 0.1),
            ),

            // Contenido principal
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo con efecto glassmorphism
                            _buildLogo(),

                            const SizedBox(height: 48),

                            // Card de login con glassmorphism
                            _buildLoginCard(isLoading),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Icono con efecto de brillo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.church_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        // Nombre de la app
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFE0E0E0)],
          ).createShader(bounds),
          child: const Text(
            'YAHVEH',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Sistema de Gestión',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            const Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Ingresa tus credenciales para continuar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Campo de usuario
            _buildTextField(
              controller: _usernameController,
              label: 'Usuario',
              icon: Icons.person_outline_rounded,
              enabled: !isLoading,
              validator: (value) =>
                  Validators.required(value, fieldName: 'Usuario'),
            ),

            const SizedBox(height: 20),

            // Campo de contraseña
            _buildTextField(
              controller: _passwordController,
              label: 'Contraseña',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              enabled: !isLoading,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: Validators.password,
            ),

            const SizedBox(height: 32),

            // Botón de login
            _buildLoginButton(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        errorStyle: TextStyle(color: Colors.red.shade200),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primaryColor.withValues(alpha: 0.7),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index);
    final size = random.nextDouble() * 5 + 2;
    final initialX = random.nextDouble() * 400;
    final initialY = random.nextDouble() * 800;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = (_particleController.value + index / 15) % 1.0;
        final x = initialX + math.sin(progress * math.pi * 2) * 25;
        final y = (initialY - progress * 150) % 800;

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: (1 - progress) * 0.4,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: size,
                    spreadRadius: size / 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecorativeCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: opacity),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  /// Parsea el mensaje de error para hacerlo más amigable
  String _parseErrorMessage(String error) {
    // Remover prefijos comunes de Exception
    String cleanError = error
        .replaceAll('Exception: ', '')
        .replaceAll('Error: ', '')
        .trim();

    // Si el mensaje está vacío o es muy genérico
    if (cleanError.isEmpty || cleanError == 'null') {
      return 'Ocurrió un error inesperado. Por favor, intenta de nuevo.';
    }

    return cleanError;
  }

  /// Obtiene el icono apropiado según el tipo de error
  IconData _getErrorIcon(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('conexión') ||
        lowerError.contains('internet') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return Icons.wifi_off_rounded;
    }

    if (lowerError.contains('usuario') && lowerError.contains('no existe') ||
        lowerError.contains('user not found')) {
      return Icons.person_off_rounded;
    }

    if (lowerError.contains('contraseña') ||
        lowerError.contains('password') ||
        lowerError.contains('credencial') ||
        lowerError.contains('inválidas') ||
        lowerError.contains('invalidas')) {
      return Icons.lock_outline_rounded;
    }

    if (lowerError.contains('deshabilitad') ||
        lowerError.contains('disabled') ||
        lowerError.contains('bloqueado') ||
        lowerError.contains('locked')) {
      return Icons.block_rounded;
    }

    if (lowerError.contains('servidor') || lowerError.contains('server')) {
      return Icons.cloud_off_rounded;
    }

    return Icons.error_outline_rounded;
  }
}
