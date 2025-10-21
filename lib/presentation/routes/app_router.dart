import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/screens.dart';

/// GoRouter con redirección basada en autenticación
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true, // Activar logs para debug
    redirect: (context, state) {
      final isAuthenticated = authState.hasValue && authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      // Debug: imprimir información de navegación
      debugPrint('🔄 GoRouter Redirect - Location: ${state.matchedLocation}');
      debugPrint('🔑 isAuthenticated: $isAuthenticated');
      
      if (!isAuthenticated && !isLoggingIn) {
        debugPrint('➡️ Redirigiendo a /login (no autenticado)');
        return '/login';
      }
      
      if (isAuthenticated && isLoggingIn) {
        debugPrint('➡️ Redirigiendo a /dashboard (ya autenticado)');
        return '/dashboard';
      }
      
      debugPrint('✅ Permitiendo navegación a ${state.matchedLocation}');
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo LoginScreen');
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) {
          debugPrint('🏠 Redirigiendo / a /dashboard');
          return '/dashboard';
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo DashboardScreen');
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '/items',
        name: 'items',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo ItemsScreen');
          return const ItemsScreen();
        },
      ),
      GoRoute(
        path: '/lineas',
        name: 'lineas',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo LineasScreen');
          return const LineasScreen();
        },
      ),
    ],
    errorBuilder: (context, state) {
      debugPrint('❌ Error de ruta: ${state.error}');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: Ruta no encontrada'),
              Text(state.matchedLocation),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Ir al Dashboard'),
              ),
            ],
          ),
        ),
      );
    },
  );
});
