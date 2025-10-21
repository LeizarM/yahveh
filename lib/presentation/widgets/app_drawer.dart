import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/vista_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/routes_provider.dart';

/// NavigationDrawer personalizado con menú dinámico desde el backend
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuProvider);
    final authState = ref.watch(authProvider);
    final localRoutes = ref.watch(appRoutesProvider);

    return NavigationDrawer(
      children: [
        // Header del drawer con información del usuario
        _buildDrawerHeader(context, authState),

        const SizedBox(height: 8),

        // Sección: Menú Local (rutas definidas en la app)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'MENÚ LOCAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
        ),
        
        // Rutas locales definidas en la app
        ...localRoutes.map((route) => _buildLocalMenuItem(context, route)),

        const Divider(),

        // Sección: Menú desde Backend
        menuState.when(
          data: (menu) {
            // Normalizar las rutas locales (sin /, lowercase, singular/plural)
            final localPaths = localRoutes.map((r) {
              var path = r.path.toLowerCase();
              if (path.startsWith('/')) path = path.substring(1);
              return path;
            }).toSet();

            // Filtrar las rutas que ya están en el menú local
            final filteredMenu = menu.where((vista) {
              var vistaPath = vista.direccion.toLowerCase();
              if (vistaPath.startsWith('/')) vistaPath = vistaPath.substring(1);
              
              // Verificar coincidencia exacta o variaciones (singular/plural)
              if (localPaths.contains(vistaPath)) return false;
              
              // Verificar variaciones singular/plural
              // "linea" vs "lineas", "item" vs "items"
              for (var localPath in localPaths) {
                // Si uno es plural del otro (agrega/quita 's')
                if (localPath.endsWith('s') && vistaPath == localPath.substring(0, localPath.length - 1)) {
                  return false;
                }
                if (vistaPath.endsWith('s') && localPath == vistaPath.substring(0, vistaPath.length - 1)) {
                  return false;
                }
              }
              
              return true;
            }).toList();

            // Si no hay rutas únicas del backend, no mostrar la sección
            if (filteredMenu.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'MENÚ BACKEND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                ...filteredMenu.map((vista) => _buildMenuItem(context, vista)),
              ],
            );
          },
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

  /// Construye un item del menú local (rutas definidas en la app)
  Widget _buildLocalMenuItem(BuildContext context, AppRoute route) {
    final icon = _getIconForRoute(route.icon);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(route.title),
        onTap: () {
          // Cerrar el drawer
          Navigator.of(context).pop();
          
          // Navegar a la ruta
          debugPrint('🔘 Navegando desde drawer a: ${route.path}');
          context.go(route.path);
        },
      ),
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

  /// Obtiene el ícono apropiado según el nombre de la ruta local
  IconData _getIconForRoute(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard;
      case 'items':
      case 'articulos':
        return Icons.inventory_2;
      case 'lineas':
        return Icons.category;
      case 'users':
      case 'usuarios':
        return Icons.people;
      case 'config':
      case 'configuracion':
        return Icons.settings;
      case 'reports':
      case 'reportes':
        return Icons.assessment;
      default:
        return Icons.arrow_forward_ios;
    }
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
