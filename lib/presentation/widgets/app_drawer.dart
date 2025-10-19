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

        // Menú dinámico desde el backend
        menuState.when(
          data: (menu) => _buildMenuItems(context, menu),
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar el menú',
                  style: TextStyle(color: context.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    ref.read(menuProvider.notifier).refreshMenu();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
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

  /// Construye los items del menú desde la lista de vistas
  Widget _buildMenuItems(BuildContext context, List<VistaEntity> menu) {
    if (menu.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No hay opciones de menú disponibles',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: menu.map((vista) => _buildMenuItem(context, vista)).toList(),
    );
  }

  /// Construye un item individual del menú
  Widget _buildMenuItem(BuildContext context, VistaEntity vista) {
    // Mapeo de iconos según el título o dirección
    final icon = _getIconForVista(vista);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(vista.titulo),
        onTap: () {
          // Cerrar el drawer
          Navigator.of(context).pop();
          
          // Navegar a la ruta especificada
          if (vista.direccion.startsWith('/')) {
            context.go(vista.direccion);
          } else {
            context.go('/${vista.direccion}');
          }
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
    } else if (direccion.contains('linea') || titulo.contains('linea')) {
      return Icons.category;
    } else if (direccion.contains('user') || titulo.contains('usuario')) {
      return Icons.people;
    } else if (direccion.contains('config') || titulo.contains('config')) {
      return Icons.settings;
    } else if (direccion.contains('report') || titulo.contains('reporte')) {
      return Icons.assessment;
    }

    // Ícono por defecto
    return Icons.arrow_forward_ios;
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
