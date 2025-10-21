import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modelo para representar una ruta de la aplicación
class AppRoute {
  final String path;
  final String name;
  final String title;
  final String icon;

  const AppRoute({
    required this.path,
    required this.name,
    required this.title,
    required this.icon,
  });
}

/// Provider que proporciona las rutas disponibles en la aplicación
final appRoutesProvider = Provider<List<AppRoute>>((ref) {
  return [
    const AppRoute(
      path: '/dashboard',
      name: 'dashboard',
      title: 'Dashboard',
      icon: 'dashboard',
    ),
    const AppRoute(
      path: '/items',
      name: 'items',
      title: 'Artículos',
      icon: 'items',
    ),
    const AppRoute(
      path: '/lineas',
      name: 'lineas',
      title: 'Líneas',
      icon: 'lineas',
    ),
  ];
});
