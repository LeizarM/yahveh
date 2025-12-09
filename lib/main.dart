import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/widgets/connectivity_wrapper.dart';
// import 'presentation/routes/simple_router.dart'; // Descomentar para testing

void main() {


  runApp(const ProviderScope(child: MyApp()));
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
