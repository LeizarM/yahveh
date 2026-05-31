import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/widgets/connectivity_wrapper.dart';

void main() {
  runZonedGuarded<void>(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      // Captura de errores del framework de Flutter.
      FlutterError.onError = (FlutterErrorDetails details) {
        if (kDebugMode) {
          FlutterError.presentError(details);
        } else {
          // En release no crasheamos silenciosamente.
          // TODO: enviar a un servicio de telemetría (Crashlytics/Sentry).
        }
      };

      runApp(ProviderScope(child: MyApp()));
    },
    (Object error, StackTrace stack) {
      // Captura de errores asíncronos no manejados.
      if (kDebugMode) {
        debugPrint('Uncaught error: $error');
        debugPrintStack(stackTrace: stack);
      } else {
        // TODO: enviar a un servicio de telemetría (Crashlytics/Sentry).
      }
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router con autenticación (por defecto)
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Yahveh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        // Envolver con ConnectivityWrapper para mostrar alertas de conectividad
        return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
