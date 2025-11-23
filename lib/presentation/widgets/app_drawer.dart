import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/vista_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';

/// NavigationDrawer personalizado con menú dinámico desde el backend
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuProvider);
    final authState = ref.watch(authProvider);

    return NavigationDrawer(
      children: [
        // Header del drawer con información del usuario
        _buildDrawerHeader(context, authState),

        const SizedBox(height: 8),

        // Menú dinámico desde Backend
        menuState.when(
          data: (menu) {
            debugPrint('📋 Menú del backend cargado: ${menu.length} items');
            for (var vista in menu) {
              debugPrint('  - ${vista.titulo} -> ${vista.direccion}');
            }

            if (menu.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No hay opciones de menú disponibles',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'MENÚ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                ...menu.map((vista) => _buildMenuItem(context, vista)),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    'Cargando menú...',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stack) {
            debugPrint('❌ Error al cargar menú: $error');
            debugPrint('Stack: $stack');
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 40,
                    color: context.colorScheme.error.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No se pudo cargar el menú',
                    style: TextStyle(
                      color: context.colorScheme.error,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      debugPrint('🔄 Recargando menú...');
                      ref.read(menuProvider.notifier).refreshMenu();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reintentar', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          },
        ),

        const Divider(),

        // Opción de cerrar sesión
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              _showLogoutDialog(context, ref);
            },
          ),
        ),
      ],
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
        return UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: context.colorScheme.onPrimary,
            child: Text(
              userEntity.nombreCompleto.isNotEmpty 
                  ? userEntity.nombreCompleto[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),
          ),
          accountName: Text(
            userEntity.nombreCompleto,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          accountEmail: Text(
            userEntity.tipoUsuario.toUpperCase(),
            style: const TextStyle(fontSize: 14),
          ),
        );
      },
      loading: () => const DrawerHeader(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Construye un item individual del menú
  Widget _buildMenuItem(BuildContext context, VistaEntity vista) {
    final icon = _getIconForVista(vista);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(vista.titulo),
        onTap: () {
          debugPrint('🚀 Navegando desde menú backend: ${vista.direccion}');
          
          // Cerrar el drawer solo en móvil (cuando es un diálogo modal)
          // En desktop/tablet el drawer es permanente, no se debe cerrar
          final isMobile = context.screenWidth < 600;
          if (isMobile && Scaffold.of(context).hasDrawer) {
            Navigator.of(context).pop();
          }
          
          // Navegar a la ruta especificada
          final path = vista.direccion.startsWith('/') 
              ? vista.direccion 
              : '/${vista.direccion}';
          
          debugPrint('   Ruta final: $path');
          context.go(path);
        },
      ),
    );
  }

  /// Obtiene el ícono apropiado según la vista
  IconData _getIconForVista(VistaEntity vista) {
    // Puedes personalizar los iconos según el título o dirección
    final direccion = vista.direccion.toLowerCase();
    final titulo = vista.titulo.toLowerCase();

    if (direccion.contains('dashboard') || titulo.contains('dashboard')) {
      return Icons.dashboard;
    } else if (direccion.contains('items') || 
               direccion.contains('articulos') || 
               titulo.contains('articulos')) {
      return Icons.inventory_2;
    } else if (direccion.contains('linea') || titulo.contains('linea') || titulo.contains('línea')) {
      return Icons.category;
    } else if (direccion.contains('familia') || titulo.contains('familia')) {
      return Icons.folder_special;
    } else if (direccion.contains('cliente') || titulo.contains('cliente')) {
      return Icons.people;
    } else if (direccion.contains('zona') || titulo.contains('zona')) {
      return Icons.map;
    } else if (direccion.contains('ciudad') || titulo.contains('ciudad')) {
      return Icons.location_city;
    } else if (direccion.contains('pais') || titulo.contains('pais') || titulo.contains('país')) {
      return Icons.public;
    } else if (direccion.contains('user') || titulo.contains('usuario')) {
      return Icons.person;
    } else if (direccion.contains('config') || titulo.contains('config')) {
      return Icons.settings;
    } else if (direccion.contains('report') || titulo.contains('reporte')) {
      return Icons.assessment;
    } else if (direccion.contains('venta') || titulo.contains('venta')) {
      return Icons.shopping_cart;
    } else if (direccion.contains('compra') || titulo.contains('compra')) {
      return Icons.shopping_bag;
    } else if (direccion.contains('producto') || titulo.contains('producto')) {
      return Icons.inventory;
    } else if (direccion.contains('delivery-notes') || 
               direccion.contains('nota') || 
               titulo.contains('nota') ||
               titulo.contains('entrega')) {
      return Icons.description;
    }

    // Ícono por defecto
    return Icons.chevron_right;
  }

  /// Muestra el diálogo de confirmación de cierre de sesión
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
