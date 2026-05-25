import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/vista_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla del Dashboard — saludo, acceso rápido y bienvenida del sistema.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    ));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isMobile),
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Row(
          children: [
            // ── Drawer permanente en desktop/tablet ───────────────────────
            if (!isMobile)
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: AppTheme.drawerSurface.withValues(alpha: 0.6),
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    child: const AppDrawer(),
                  ),
                ),
              ),

            // ── Contenido principal ───────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ref.watch(authProvider).when(
                        data: (user) {
                          if (user == null) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            );
                          }
                          return _buildContent(context, user as UserEntity);
                        },
                        loading: () => const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white),
                        ),
                        error: (err, _) => _buildErrorState(err),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // AppBar
  // ──────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      title: const Text('Dashboard'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildClockChip(),
        ),
      ],
    );
  }

  Widget _buildClockChip() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        '$hour:$minute',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Mobile drawer
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.drawerSurface.withValues(alpha: 0.96),
            ),
            child: const AppDrawer(),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Main content
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, UserEntity user) {
    final isMobile = context.screenWidth < 600;
    final isDesktop = context.screenWidth >= 1024;
    final padding = isDesktop ? 36.0 : (isMobile ? 20.0 : 28.0);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, 20, padding, padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tarjeta de bienvenida ──────────────────────────────────
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 80),
              child: _buildWelcomeHero(user),
            ),

            const SizedBox(height: 24),

            // ── Franja de info ────────────────────────────────────────
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 160),
              child: _buildInfoStrip(user),
            ),

            const SizedBox(height: 28),

            // ── Acceso rápido ─────────────────────────────────────────
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 220),
              child: _buildSectionHeader('Acceso Rápido'),
            ),
            const SizedBox(height: 14),
            _buildQuickAccessSection(context),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Welcome hero
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildWelcomeHero(UserEntity user) {
    final initials = user.nombreCompleto
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    final greeting = _greeting();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.35),
            AppTheme.accentCyan.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryLight, AppTheme.accentCyan],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryLight.withValues(alpha: 0.4),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 22),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildPill(
                      user.tipoUsuario.toUpperCase(),
                      user.tipoUsuario == 'admin'
                          ? AppTheme.accentGreen
                          : AppTheme.accentCyan,
                    ),
                    const SizedBox(width: 8),
                    _buildPill('SISTEMA ACTIVO', AppTheme.primaryLight),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Info strip (date, modules count)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildInfoStrip(UserEntity user) {
    final now = DateTime.now();
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final days = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo'
    ];
    final dayName = days[now.weekday - 1];
    final dateStr = '$dayName, ${now.day} de ${months[now.month - 1]} ${now.year}';

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.calendar_today_rounded,
            label: 'Fecha',
            value: dateStr,
            color: AppTheme.accentBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.verified_user_rounded,
            label: 'Rol',
            value: user.tipoUsuario == 'admin' ? 'Administrador' : 'Limitado',
            color: user.tipoUsuario == 'admin'
                ? AppTheme.accentGreen
                : AppTheme.accentCyan,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Quick-access section
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryLight, AppTheme.accentCyan],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return ref.watch(menuProvider).when(
          data: (menu) => _buildQuickAccessGrid(context, menu),
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
              ),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No se pudieron cargar los módulos',
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ),
        );
  }

  Widget _buildQuickAccessGrid(
      BuildContext context, List<VistaEntity> menu) {
    if (menu.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No hay módulos disponibles',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    final w = context.screenWidth;
    final isDesktop = w >= 1024;
    final isTablet = w >= 600 && w < 1024;
    final columns = isDesktop ? 4 : (isTablet ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isDesktop ? 1.3 : 1.15,
      ),
      itemCount: menu.length,
      itemBuilder: (context, index) {
        return FadeSlideAnimation(
          delay: Duration(milliseconds: 50 * index),
          child: _buildQuickCard(context, menu[index]),
        );
      },
    );
  }

  Widget _buildQuickCard(BuildContext context, VistaEntity vista) {
    final icon = _getIconForVista(vista);
    final accentColor = _colorForVista(vista);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final path = vista.direccion.startsWith('/')
              ? vista.direccion
              : '/${vista.direccion}';
          context.go(path);
        },
        borderRadius: BorderRadius.circular(18),
        splashColor: accentColor.withValues(alpha: 0.15),
        highlightColor: accentColor.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 22, color: accentColor),
              ),
              const SizedBox(height: 14),
              Text(
                vista.titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Ir al módulo',
                    style: TextStyle(
                      fontSize: 11,
                      color: accentColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded,
                      size: 12, color: accentColor.withValues(alpha: 0.8)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Error state
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildErrorState(Object error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 36, color: Colors.white),
            ),
            const SizedBox(height: 22),
            const Text('Algo salió mal',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(authProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Utilities
  // ──────────────────────────────────────────────────────────────────────────

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días!';
    if (hour < 18) return '¡Buenas tardes!';
    return '¡Buenas noches!';
  }

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
    if (d.contains('empleado') || t.contains('empleado')) return Icons.badge_rounded;
    if (d.contains('regla-descuento') || t.contains('descuento') || t.contains('regla')) return Icons.discount_rounded;
    if (d.contains('inventario') || t.contains('inventario')) return Icons.warehouse_rounded;
    if (d.contains('producto') || t.contains('producto')) return Icons.inventory_rounded;
    return Icons.grid_view_rounded;
  }

  /// Asigna un color de acento distinto a cada módulo para variedad visual.
  Color _colorForVista(VistaEntity vista) {
    final d = vista.direccion.toLowerCase();
    final t = vista.titulo.toLowerCase();
    if (d.contains('dashboard')) return AppTheme.accentCyan;
    if (d.contains('articulo') || t.contains('articulo')) return AppTheme.primaryLight;
    if (d.contains('cliente') || t.contains('cliente')) return AppTheme.accentPink;
    if (d.contains('usuario') || t.contains('usuario')) return AppTheme.accentBlue;
    if (d.contains('reporte') || t.contains('reporte')) return AppTheme.accentOrange;
    if (d.contains('venta') || t.contains('venta')) return AppTheme.accentGreen;
    if (d.contains('empleado') || t.contains('empleado')) return AppTheme.accentCyan;
    if (d.contains('delivery') || t.contains('entrega')) return AppTheme.warningColor;
    if (d.contains('linea') || t.contains('línea')) return AppTheme.accentPink;
    if (d.contains('familia') || t.contains('familia')) return AppTheme.primaryLight;
    if (d.contains('catalogo') || t.contains('catálogo')) return AppTheme.accentOrange;
    if (d.contains('ciudad') || t.contains('ciudad')) return AppTheme.accentCyan;
    if (d.contains('descuento') || t.contains('descuento')) return AppTheme.accentGreen;
    // Cycle through accent colors by index for remaining items
    final colors = [
      AppTheme.primaryLight,
      AppTheme.accentPink,
      AppTheme.accentGreen,
      AppTheme.accentOrange,
      AppTheme.accentBlue,
      AppTheme.accentCyan,
    ];
    return colors[vista.codVista % colors.length];
  }
}
