import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yahveh/core/utils/error_messages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/vista_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';

/// NavigationDrawer personalizado con menú dinámico desde el backend
/// Diseño moderno con glassmorphism y animaciones
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuProvider);
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header del drawer con información del usuario
            _buildDrawerHeader(context, authState),

            const SizedBox(height: 16),

            // Menú dinámico desde Backend
            Expanded(
              child: menuState.when(
                data: (menu) {
                  console('📋 Menú del backend cargado: ${menu.length} items');
                  for (var vista in menu) {
                    console('  - ${vista.titulo} -> ${vista.direccion}');
                  }

                  if (menu.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_open_rounded,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay opciones disponibles',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('MENÚ PRINCIPAL'),
                        const SizedBox(height: 8),
                        ...menu.asMap().entries.map((entry) => 
                          FadeSlideAnimation(
                            delay: Duration(milliseconds: 50 * entry.key),
                            child: _buildMenuItem(context, entry.value, screenWidth),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cargando menú...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stack) {
                  console('❌ Error al cargar menú: $error');
                  console('Stack: $stack');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_off_rounded,
                              size: 28,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se pudo cargar el menú',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              console('🔄 Recargando menú...');
                              ref.read(menuProvider.notifier).refreshMenu();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Reintentar'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer con opciones adicionales
            _buildFooterOptions(context, ref, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// Construye el header del drawer con la información del usuario
  Widget _buildDrawerHeader(BuildContext context, AsyncValue authState) {
    return authState.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final userEntity = user as UserEntity;
        final initials = userEntity.nombreCompleto
            .split(' ')
            .where((word) => word.isNotEmpty)
            .take(2)
            .map((word) => word[0].toUpperCase())
            .join();

        return FadeSlideAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentCyan.withValues(alpha: 0.8),
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 14),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEntity.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          userEntity.tipoUsuario.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Construye un item individual del menú
  Widget _buildMenuItem(BuildContext context, VistaEntity vista, double screenWidth) {
    final icon = _getIconForVista(vista);
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            console('🚀 Navegando desde menú backend: ${vista.direccion}');
            
            if (isMobile && Scaffold.of(context).hasDrawer) {
              Navigator.of(context).pop();
            }
            
            final path = vista.direccion.startsWith('/') 
                ? vista.direccion 
                : '/${vista.direccion}';
            
            console('   Ruta final: $path');
            context.go(path);
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    vista.titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Footer con opciones de perfil y logout
  Widget _buildFooterOptions(BuildContext context, WidgetRef ref, double screenWidth) {
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Perfil
          _buildFooterItem(
            icon: Icons.account_circle_outlined,
            label: 'Mi Perfil',
            onTap: () {
              if (isMobile && Scaffold.of(context).hasDrawer) {
                Navigator.of(context).pop();
              }
              context.go('/perfil');
            },
          ),
          
          Divider(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
          ),
          
          // Cerrar sesión
          _buildFooterItem(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesión',
            isLogout: true,
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isLogout 
                    ? AppTheme.accentOrange.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isLogout 
                      ? AppTheme.accentOrange.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el ícono apropiado según la vista
  IconData _getIconForVista(VistaEntity vista) {
    final direccion = vista.direccion.toLowerCase();
    final titulo = vista.titulo.toLowerCase();

    if (direccion.contains('dashboard') || titulo.contains('dashboard')) {
      return Icons.dashboard_rounded;
    } else if (direccion.contains('items') || 
               direccion.contains('articulos') || 
               titulo.contains('articulos')) {
      return Icons.inventory_2_rounded;
    } else if (direccion.contains('linea') || titulo.contains('linea') || titulo.contains('línea')) {
      return Icons.category_rounded;
    } else if (direccion.contains('familia') || titulo.contains('familia')) {
      return Icons.folder_special_rounded;
    } else if (direccion.contains('cliente') || titulo.contains('cliente')) {
      return Icons.people_rounded;
    } else if (direccion.contains('zona') || titulo.contains('zona')) {
      return Icons.map_rounded;
    } else if (direccion.contains('ciudad') || titulo.contains('ciudad')) {
      return Icons.location_city_rounded;
    } else if (direccion.contains('pais') || titulo.contains('pais') || titulo.contains('país')) {
      return Icons.public_rounded;
    } else if (direccion.contains('user') || titulo.contains('usuario')) {
      return Icons.person_rounded;
    } else if (direccion.contains('config') || titulo.contains('config')) {
      return Icons.settings_rounded;
    } else if (direccion.contains('report') || titulo.contains('reporte')) {
      return Icons.assessment_rounded;
    } else if (direccion.contains('venta') || titulo.contains('venta')) {
      return Icons.shopping_cart_rounded;
    } else if (direccion.contains('compra') || titulo.contains('compra')) {
      return Icons.shopping_bag_rounded;
    } else if (direccion.contains('producto') || titulo.contains('producto')) {
      return Icons.inventory_rounded;
    } else if (direccion.contains('delivery-notes') || 
               direccion.contains('nota') || 
               titulo.contains('nota') ||
               titulo.contains('entrega')) {
      return Icons.description_rounded;
    } else if (direccion.contains('persona-empleado') || 
               direccion.contains('empleado') || 
               titulo.contains('empleado')) {
      return Icons.badge_rounded;
    }

    return Icons.circle_outlined;
  }

  /// Muestra el diálogo de confirmación de cierre de sesión
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
              // Icono
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: AppTheme.accentOrange,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Título
              const Text(
                '¿Cerrar Sesión?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Mensaje
              Text(
                'Tu sesión actual será cerrada y tendrás que volver a iniciar sesión.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
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
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
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
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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
}
