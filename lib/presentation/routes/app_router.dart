import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/screens.dart';

/// GoRouter con redirección basada en autenticación
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true, // Activar logs para debug
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.hasValue && authState.value != null;
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';

      // Si está cargando, mantener en splash
      if (isLoading && !isSplash) {
        return '/splash';
      }

      // Si terminó de cargar y está en splash, redirigir según autenticación
      if (!isLoading && isSplash) {
        return isAuthenticated ? '/dashboard' : '/login';
      }

      // Si no está autenticado y no está en login ni splash, ir a login
      if (!isAuthenticated && !isLoggingIn && !isSplash) {
        return '/login';
      }
      
      // Si está autenticado y está en login, ir a dashboard
      if (isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo SplashScreen');
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) {
          debugPrint('🏗️ Construyendo LoginScreen');
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
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
        path: '/linea',
        name: 'linea',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo LineasScreen');
          return const LineasScreen();
        },
      ),
      GoRoute(
        path: '/familia',
        name: 'familia',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo FamiliasScreen');
          return const FamiliasScreen();
        },
      ),
      GoRoute(
        path: '/clientes',
        name: 'clientes',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo ClientesScreen');
          return const ClientesScreen();
        },
      ),
      GoRoute(
        path: '/zona',
        name: 'zona',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo ZonasScreen');
          return const ZonasScreen();
        },
      ),
      GoRoute(
        path: '/ciudad',
        name: 'ciudad',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo CiudadesScreen');
          return const CiudadesScreen();
        },
      ),
      GoRoute(
        path: '/pais',
        name: 'pais',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo PaisesScreen');
          return const PaisesScreen();
        },
      ),
      GoRoute(
        path: '/nota_entrega',
        name: 'delivery-notes',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo DeliveryNotesScreen');
          return const DeliveryNotesScreen();
        },
      ),
      GoRoute(
        path: '/usuarios',
        name: 'usuarios',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo UsuariosScreen');
          return const UsuariosScreen();
        },
      ),
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo ProfileScreen');
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: '/persona-empleado',
        name: 'persona-empleado',
        builder: (context, state) {
          debugPrint('🏗️ Construyendo PersonaEmpleadoScreen');
          return const PersonaEmpleadoScreen();
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
