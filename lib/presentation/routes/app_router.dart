import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yahveh/core/utils/error_messages.dart';
import '../providers/auth_provider.dart';
import '../screens/screens.dart';

/// Notifier que solo emite cuando el estado de autenticación cambia
/// de forma relevante para la navegación (no para errores de login)
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      // Solo notificar si:
      // 1. Cambió de loading a data (con usuario)
      // 2. Cambió de data (con usuario) a data (sin usuario) - logout
      // NO notificar si hay error (para que se quede en login y muestre el error)

      final prevUser = previous?.hasValue == true ? previous?.value : null;
      final nextUser = next.hasValue ? next.value : null;
      final wasLoading = previous?.isLoading ?? true;
      final isLoading = next.isLoading;
      final hasError = next.hasError;

      // Si hay error, no notificar (quedarse en login)
      if (hasError) return;

      // Si cambió el estado de loading o el usuario
      if (wasLoading != isLoading ||
          prevUser?.codUsuario != nextUser?.codUsuario) {
        console('🔄 AuthChangeNotifier: notificando cambio de auth');
        notifyListeners();
      }
    });
  }

  final Ref _ref;
}

final _authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

/// GoRouter con redirección basada en autenticación
final appRouterProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = ref.watch(_authChangeNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuthenticated = authState.hasValue && authState.value != null;
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';

      console(
        '🧭 Router redirect - loading: $isLoading, error: $hasError, auth: $isAuthenticated, path: ${state.matchedLocation}',
      );

      // Si hay error y está en login, quedarse en login (para mostrar el error)
      if (hasError && isLoggingIn) {
        console('🧭 → Quedarse en login (hay error)');
        return null;
      }

      // Si está cargando y no está en splash ni login, ir a splash
      if (isLoading && !isSplash && !isLoggingIn) {
        console('🧭 → Ir a splash (cargando)');
        return '/splash';
      }

      // Si terminó de cargar y está en splash, redirigir según autenticación
      if (!isLoading && !hasError && isSplash) {
        console(
          '🧭 → Desde splash ir a ${isAuthenticated ? "dashboard" : "login"}',
        );
        return isAuthenticated ? '/dashboard' : '/login';
      }

      // Si no está autenticado y no está en login ni splash, ir a login
      if (!isAuthenticated &&
          !isLoggingIn &&
          !isSplash &&
          !isLoading &&
          !hasError) {
        console('🧭 → Ir a login (no autenticado)');
        return '/login';
      }

      // Si está autenticado y está en login, ir a dashboard
      if (isAuthenticated && isLoggingIn) {
        console('🧭 → Ir a dashboard (autenticado)');
        return '/dashboard';
      }

      console('🧭 → Sin redirección');
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          console('🏗️ Construyendo SplashScreen');
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) {
          console('🏗️ Construyendo LoginScreen');
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) {
          console('🏠 Redirigiendo / a /dashboard');
          return '/dashboard';
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) {
          console('🏗️ Construyendo DashboardScreen');
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '/items',
        name: 'items',
        builder: (context, state) {
          console('🏗️ Construyendo ItemsScreen');
          return const ItemsScreen();
        },
      ),
      GoRoute(
        path: '/linea',
        name: 'linea',
        builder: (context, state) {
          console('🏗️ Construyendo LineasScreen');
          return const LineasScreen();
        },
      ),
      GoRoute(
        path: '/familia',
        name: 'familia',
        builder: (context, state) {
          console('🏗️ Construyendo FamiliasScreen');
          return const FamiliasScreen();
        },
      ),
      GoRoute(
        path: '/clientes',
        name: 'clientes',
        builder: (context, state) {
          console('🏗️ Construyendo ClientesScreen');
          return const ClientesScreen();
        },
      ),
      GoRoute(
        path: '/zona',
        name: 'zona',
        builder: (context, state) {
          console('🏗️ Construyendo ZonasScreen');
          return const ZonasScreen();
        },
      ),
      GoRoute(
        path: '/ciudad',
        name: 'ciudad',
        builder: (context, state) {
          console('🏗️ Construyendo CiudadesScreen');
          return const CiudadesScreen();
        },
      ),
      GoRoute(
        path: '/pais',
        name: 'pais',
        builder: (context, state) {
          console('🏗️ Construyendo PaisesScreen');
          return const PaisesScreen();
        },
      ),
      GoRoute(
        path: '/nota_entrega',
        name: 'delivery-notes',
        builder: (context, state) {
          console('🏗️ Construyendo DeliveryNotesScreen');
          return const DeliveryNotesScreen();
        },
      ),
      GoRoute(
        path: '/usuarios',
        name: 'usuarios',
        builder: (context, state) {
          console('🏗️ Construyendo UsuariosScreen');
          return const UsuariosScreen();
        },
      ),
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        builder: (context, state) {
          console('🏗️ Construyendo ProfileScreen');
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: '/persona-empleado',
        name: 'persona-empleado',
        builder: (context, state) {
          console('🏗️ Construyendo PersonaEmpleadoScreen');
          return const PersonaEmpleadoScreen();
        },
      ),
      GoRoute(
        path: '/reportes',
        name: 'reportes',
        builder: (context, state) {
          console('🏗️ Construyendo ReportesScreen');
          return const ReportesScreen();
        },
      ),
    ],
    errorBuilder: (context, state) {
      console('❌ Error de ruta: ${state.error}');
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
