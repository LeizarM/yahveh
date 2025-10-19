import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla del Dashboard
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: context.isMobile ? const AppDrawer() : null,
      body: Row(
        children: [
          // Drawer permanente en desktop/tablet
          if (!context.isMobile)
            Container(
              width: 280,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: context.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: const AppDrawer(),
            ),

          // Contenido principal
          Expanded(
            child: authState.when(
              data: (user) {
                if (user == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ResponsiveLayout(
                  mobile: _buildMobileLayout(context, user),
                  tablet: _buildTabletLayout(context, user),
                  desktop: _buildDesktopLayout(context, user),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${error.toString()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Layout para móvil
  Widget _buildMobileLayout(BuildContext context, UserEntity user) {
    return Center(
      child: SingleChildScrollView(
        padding: context.screenPadding,
        child: _buildUserCard(context, user),
      ),
    );
  }

  /// Layout para tablet
  Widget _buildTabletLayout(BuildContext context, UserEntity user) {
    return Center(
      child: SingleChildScrollView(
        padding: context.screenPadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildUserCard(context, user),
        ),
      ),
    );
  }

  /// Layout para desktop
  Widget _buildDesktopLayout(BuildContext context, UserEntity user) {
    return Center(
      child: SingleChildScrollView(
        padding: context.screenPadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildUserCard(context, user),
        ),
      ),
    );
  }

  /// Card con información del usuario
  Widget _buildUserCard(BuildContext context, UserEntity user) {
    final initials = user.nombreCompleto
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: context.colorScheme.primary,
              child: Text(
                initials,
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Bienvenido!',
              style: context.theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              user.nombreCompleto,
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
