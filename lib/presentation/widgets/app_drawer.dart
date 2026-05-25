import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yahveh/core/utils/error_messages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/vista_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';

/// Sidebar moderno con brand header, active-route highlighting y menú dinámico.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuProvider);
    final authState = ref.watch(authProvider);

    // Ruta activa para resaltar el item correspondiente
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.sidebarGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Marca ──────────────────────────────────────────────────────
            _buildBrandHeader(),

            // ── Info del usuario ───────────────────────────────────────────
            _buildDrawerHeader(authState),

            const SizedBox(height: 8),

            // ── Menú dinámico ──────────────────────────────────────────────
            Expanded(
              child: menuState.when(
                data: (menu) => _buildMenu(context, menu, currentPath),
                loading: () => _buildMenuLoading(),
                error: (error, _) => _buildMenuError(context, ref, error),
              ),
            ),

            // ── Footer ────────────────────────────────────────────────────
            _buildFooter(context, ref),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Brand header
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildBrandHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryLight, AppTheme.accentCyan],
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryLight.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.church_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // App name
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFB0C8FF)],
            ).createShader(bounds),
            child: const Text(
              'YAHVEH',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 3.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // User header
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildDrawerHeader(AsyncValue authState) {
    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final userEntity = user as UserEntity;
        final initials = userEntity.nombreCompleto
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();

        return FadeSlideAnimation(
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentCyan.withValues(alpha: 0.9),
                        AppTheme.primaryColor.withValues(alpha: 0.9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEntity.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.accentGreen.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          userEntity.tipoUsuario.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentGreen,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 70,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Menu
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMenu(
    BuildContext context,
    List<VistaEntity> menu,
    String currentPath,
  ) {
    if (menu.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_open_rounded,
                size: 40, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No hay opciones disponibles',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
            ),
          ],
        ),
      );
    }

    // ⭐ Agrupar por jerarquía: top-level (codVistaPadre == 0) y sus hijos
    final topLevel = menu.where((v) => v.codVistaPadre == 0).toList();
    final childrenByParent = <int, List<VistaEntity>>{};
    for (final v in menu) {
      if (v.codVistaPadre != 0) {
        childrenByParent.putIfAbsent(v.codVistaPadre, () => []).add(v);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('NAVEGACIÓN'),
          const SizedBox(height: 6),
          ...topLevel.asMap().entries.map((e) {
            final vista = e.value;
            final children = childrenByParent[vista.codVista] ?? const [];
            return FadeSlideAnimation(
              delay: Duration(milliseconds: 40 * e.key),
              child: children.isEmpty
                  ? _buildMenuItem(context, vista, currentPath)
                  : _buildExpandableMenuItem(
                      context,
                      vista,
                      children,
                      currentPath,
                    ),
            );
          }),
        ],
      ),
    );
  }

  /// Item expandible (con submenús). Se auto-expande si la ruta activa
  /// coincide con el padre o cualquiera de los hijos.
  Widget _buildExpandableMenuItem(
    BuildContext context,
    VistaEntity vista,
    List<VistaEntity> children,
    String currentPath,
  ) {
    final icon = _getIconForVista(vista);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final normalizedParentPath =
        vista.direccion.startsWith('/') ? vista.direccion : '/${vista.direccion}';

    bool isPathMatch(String dir) {
      final p = dir.startsWith('/') ? dir : '/$dir';
      return currentPath == p || (p != '/' && currentPath.startsWith('$p/'));
    }

    final parentActive = isPathMatch(vista.direccion);
    final anyChildActive = children.any((c) => isPathMatch(c.direccion));
    final hasActiveDescendant = parentActive || anyChildActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: hasActiveDescendant
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        // Sacar la línea divisora default del ExpansionTile
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          highlightColor: AppTheme.primaryColor.withValues(alpha: 0.08),
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.only(left: 18, bottom: 4),
          initiallyExpanded: hasActiveDescendant,
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: Colors.white.withValues(alpha: 0.6),
          collapsedIconColor: Colors.white.withValues(alpha: 0.45),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: parentActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: parentActive
                  ? AppTheme.primaryLight
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
          title: GestureDetector(
            // Click en el título navega al padre (Articulos), no expande
            behavior: HitTestBehavior.opaque,
            onTap: () {
              console('🚀 Menú padre → ${vista.direccion}');
              if (isMobile && Scaffold.of(context).hasDrawer) {
                Navigator.of(context).pop();
              }
              context.go(normalizedParentPath);
            },
            child: Text(
              vista.titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    hasActiveDescendant ? FontWeight.w600 : FontWeight.w400,
                color: hasActiveDescendant
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ),
          children: children
              .map((c) => _buildSubMenuItem(context, c, currentPath))
              .toList(),
        ),
      ),
    );
  }

  /// Item hijo (submenú) — diseño más compacto, con guía visual a la izquierda.
  Widget _buildSubMenuItem(
    BuildContext context,
    VistaEntity vista,
    String currentPath,
  ) {
    final icon = _getIconForVista(vista);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final normalizedPath = vista.direccion.startsWith('/')
        ? vista.direccion
        : '/${vista.direccion}';
    final isActive = currentPath == normalizedPath ||
        (normalizedPath != '/' && currentPath.startsWith('$normalizedPath/'));

    return Container(
      margin: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isActive
                ? AppTheme.primaryLight.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.12),
            width: 2,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            console('🚀 Submenú → ${vista.direccion}');
            if (isMobile && Scaffold.of(context).hasDrawer) {
              Navigator.of(context).pop();
            }
            context.go(normalizedPath);
          },
          borderRadius: BorderRadius.circular(10),
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          highlightColor: AppTheme.primaryColor.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.18)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryColor.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: isActive
                        ? AppTheme.primaryLight
                        : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    vista.titulo,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    VistaEntity vista,
    String currentPath,
  ) {
    final icon = _getIconForVista(vista);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final normalizedPath = vista.direccion.startsWith('/')
        ? vista.direccion
        : '/${vista.direccion}';
    final isActive = currentPath == normalizedPath ||
        (normalizedPath != '/' && currentPath.startsWith('$normalizedPath/'));

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            console('🚀 Menú → ${vista.direccion}');
            if (isMobile && Scaffold.of(context).hasDrawer) {
              Navigator.of(context).pop();
            }
            context.go(normalizedPath);
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          highlightColor: AppTheme.primaryColor.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.18)
                  : Colors.transparent,
              border: isActive
                  ? Border.all(
                      color: AppTheme.primaryLight.withValues(alpha: 0.35),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryColor.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 17,
                    color: isActive
                        ? AppTheme.primaryLight
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 12),
                // Label
                Expanded(
                  child: Text(
                    vista.titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                // Active dot
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Cargando menú...',
            style: TextStyle(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuError(BuildContext context, WidgetRef ref, Object error) {
    console('❌ Error al cargar menú: $error');
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off_rounded,
                size: 26, color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 14),
          Text(
            'No se pudo cargar el menú',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => ref.read(menuProvider.notifier).refreshMenu(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reintentar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Footer
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFooterItem(
            icon: Icons.account_circle_outlined,
            label: 'Mi Perfil',
            onTap: () {
              if (isMobile && Scaffold.of(context).hasDrawer) {
                Navigator.of(context).pop();
              }
              context.go('/perfil');
            },
          ),
          Divider(
              color: Colors.white.withValues(alpha: 0.07),
              height: 1,
              indent: 16,
              endIndent: 16),
          _buildFooterItem(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesión',
            iconColor: AppTheme.accentOrange.withValues(alpha: 0.85),
            textColor: AppTheme.accentOrange.withValues(alpha: 0.9),
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor ?? Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Logout dialog
  // ──────────────────────────────────────────────────────────────────────────

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cardSurfaceLight.withValues(alpha: 0.97),
                AppTheme.cardSurface.withValues(alpha: 0.99),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 48,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    size: 30, color: AppTheme.accentOrange),
              ),
              const SizedBox(height: 22),
              const Text(
                '¿Cerrar Sesión?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Tu sesión será cerrada y deberás volver a iniciar sesión.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.5),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                      ),
                      child: Text('Cancelar',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cerrar Sesión',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Icon map
  // ──────────────────────────────────────────────────────────────────────────

  IconData _getIconForVista(VistaEntity vista) {
    final d = vista.direccion.toLowerCase();
    final t = vista.titulo.toLowerCase();

    if (d.contains('dashboard') || t.contains('dashboard')) return Icons.dashboard_rounded;
    if (d.contains('items') || d.contains('articulo') || t.contains('articulo')) return Icons.inventory_2_rounded;
    if (d.contains('linea') || t.contains('linea') || t.contains('línea')) return Icons.category_rounded;
    if (d.contains('familia') || t.contains('familia')) return Icons.folder_special_rounded;
    if (d.contains('catalogo') || t.contains('catálogo') || t.contains('catalogo')) return Icons.storefront_rounded;
    if (d.contains('cliente') || t.contains('cliente')) return Icons.people_rounded;
    if (d.contains('zona') || t.contains('zona')) return Icons.map_rounded;
    if (d.contains('ciudad') || t.contains('ciudad')) return Icons.location_city_rounded;
    if (d.contains('pais') || t.contains('pais') || t.contains('país')) return Icons.public_rounded;
    if (d.contains('user') || t.contains('usuario')) return Icons.manage_accounts_rounded;
    if (d.contains('config') || t.contains('config')) return Icons.settings_rounded;
    if (d.contains('report') || t.contains('reporte')) return Icons.assessment_rounded;
    if (d.contains('venta') || t.contains('venta')) return Icons.shopping_cart_rounded;
    if (d.contains('compra') || t.contains('compra')) return Icons.shopping_bag_rounded;
    if (d.contains('delivery') || d.contains('nota') || t.contains('entrega')) return Icons.local_shipping_rounded;
    if (d.contains('empleado') || d.contains('persona-empleado') || t.contains('empleado')) return Icons.badge_rounded;
    if (d.contains('regla-descuento') || t.contains('descuento') || t.contains('regla')) return Icons.discount_rounded;
    if (d.contains('inventario') || t.contains('inventario')) return Icons.warehouse_rounded;
    if (d.contains('producto') || t.contains('producto')) return Icons.inventory_rounded;

    return Icons.circle_outlined;
  }
}
