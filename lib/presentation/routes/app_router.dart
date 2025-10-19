import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/screens.dart';

/// Provider del router para que pueda acceder al estado de autenticación
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Verificar si hay usuario autenticado
      final isAuthenticated = authState.hasValue && authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';
      
      // Si no está autenticado y no está en login, ir a login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      
      // Si está autenticado y está en login, ir al dashboard
      if (isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }
      
      // En cualquier otro caso, permitir la navegación
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) => '/dashboard',
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/items',
        name: 'items',
        builder: (context, state) => const ItemsScreen(),
      ),
    ],
  );
});
