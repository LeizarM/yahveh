import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/pais_entity.dart';
import '../providers/pais_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Países con CRUD completo y diseño glassmorphism
class PaisesScreen extends ConsumerStatefulWidget {
  const PaisesScreen({super.key});

  @override
  ConsumerState<PaisesScreen> createState() => _PaisesScreenState();
}

class _PaisesScreenState extends ConsumerState<PaisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paisesAsync = ref.watch(paisProvider);
    ref.watch(isAdminProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Países',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.refresh(paisProvider),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: context.isMobile ? _buildBlurredDrawer() : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPaisDialog(context),
        backgroundColor: AppTheme.accentCyan,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Drawer permanente en desktop/tablet con blur
              if (!context.isMobile) _buildPermanentDrawer(),

              // Contenido principal
              Expanded(
                child: Column(
                  children: [
                    // Barra de búsqueda
                    _buildSearchBar(),

                    // Lista de países
                    Expanded(
                      child: paisesAsync.when(
                        data: (paises) {
                          final filteredPaises = _filterPaises(paises);
                          if (filteredPaises.isEmpty) {
                            return _buildEmptyState();
                          }
                          return _buildPaisesList(filteredPaises);
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        error: (error, stack) => _buildErrorState(error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Drawer con efecto blur para móvil
  Widget _buildBlurredDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.cardSurface.withValues(alpha: 0.95),
                  AppTheme.cardSurfaceLight.withValues(alpha: 0.92),
                ],
              ),
            ),
            child: const AppDrawer(),
          ),
        ),
      ),
    );
  }

  /// Drawer permanente para desktop con blur
  Widget _buildPermanentDrawer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cardSurface.withValues(alpha: 0.95),
                AppTheme.cardSurfaceLight.withValues(alpha: 0.92),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
    );
  }

  /// Barra de búsqueda con estilo glassmorphism
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FadeSlideAnimation(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            cursorColor: AppTheme.accentCyan,
            decoration: InputDecoration(
              hintText: 'Buscar país...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.accentCyan,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Filtra la lista de países según la búsqueda
  List<PaisEntity> _filterPaises(List<PaisEntity> paises) {
    if (_searchQuery.isEmpty) return paises;
    return paises
        .where((pais) =>
            pais.pais.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  /// Estado vacío con estilo glassmorphism
  Widget _buildEmptyState() {
    return Center(
      child: FadeSlideAnimation(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.public_off,
                size: 80,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No hay países registrados'
                    : 'No se encontraron resultados',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty
                    ? 'Agrega el primer país usando el botón +'
                    : 'Intenta con otra búsqueda',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Estado de error con estilo glassmorphism
  Widget _buildErrorState(Object error) {
    return Center(
      child: FadeSlideAnimation(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppTheme.accentOrange,
              ),
              const SizedBox(height: 16),
              const Text(
                'No se pudieron cargar los países',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                ErrorMessages.getFriendlyMessage(error),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(paisProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lista de países con estilo glassmorphism
  Widget _buildPaisesList(List<PaisEntity> paises) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: paises.length,
      itemBuilder: (context, index) {
        final pais = paises[index];
        // Colores de acento rotativos
        final accentColors = [
          AppTheme.accentCyan,
          AppTheme.accentGreen,
          AppTheme.accentOrange,
          AppTheme.accentPink,
        ];
        final accentColor = accentColors[index % accentColors.length];

        return FadeSlideAnimation(
          delay: Duration(milliseconds: 50 * index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.public,
                  color: accentColor,
                ),
              ),
              title: Text(
                pais.pais,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'ID: ${pais.codPais}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppTheme.accentCyan,
                    ),
                    onPressed: () => _showEditPaisDialog(context, pais),
                    tooltip: 'Editar',
                  ),
                  if (ref.read(isAdminProvider))
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppTheme.accentOrange,
                      ),
                      onPressed: () => _showDeleteConfirmation(context, pais),
                      tooltip: 'Eliminar',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddPaisDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaisFormDialog(
        onSubmit: (pais) async {
          final userAsync = ref.read(authProvider);
          final user = userAsync.value;
          return await ref.read(paisProvider.notifier).createPais(
                pais: pais,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showEditPaisDialog(BuildContext context, PaisEntity pais) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaisFormDialog(
        pais: pais,
        onSubmit: (paisNombre) async {
          final userAsync = ref.read(authProvider);
          final user = userAsync.value;
          return await ref.read(paisProvider.notifier).updatePais(
                codPais: pais.codPais,
                pais: paisNombre,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PaisEntity pais) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.cardSurface.withValues(alpha: 0.95),
                  AppTheme.cardSurfaceLight.withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.accentOrange,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Confirmar eliminación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Estás seguro de eliminar "${pais.pais}"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          try {
                            final message = await ref
                                .read(paisProvider.notifier)
                                .deletePais(pais.codPais);
                            if (mounted) AppOverlay.showMessage(context, message, isSuccess: true);
                          } catch (e) {
                            if (mounted) AppOverlay.showMessage(context, ErrorMessages.getFriendlyMessage(e), isError: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Formulario de país (crear/editar) con estilo glassmorphism
class _PaisFormDialog extends ConsumerStatefulWidget {
  final PaisEntity? pais;
  final Future<String> Function(String pais) onSubmit;

  const _PaisFormDialog({
    this.pais,
    required this.onSubmit,
  });

  @override
  ConsumerState<_PaisFormDialog> createState() => _PaisFormDialogState();
}

class _PaisFormDialogState extends ConsumerState<_PaisFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _paisController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paisController = TextEditingController(text: widget.pais?.pais ?? '');
  }

  @override
  void dispose() {
    _paisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cardSurface.withValues(alpha: 0.95),
                AppTheme.cardSurfaceLight.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.pais == null ? Icons.add_location : Icons.edit_location,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.pais == null ? 'Agregar País' : 'Editar País',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Campo de texto
                TextFormField(
                  controller: _paisController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  cursorColor: AppTheme.accentCyan,
                  decoration: InputDecoration(
                    labelText: 'Nombre del País',
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    floatingLabelStyle: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w600),
                    hintText: 'Ingresa el nombre del país',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    prefixIcon: Icon(
                      Icons.public,
                      color: AppTheme.accentCyan,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.accentCyan,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.errorColor,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.errorColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre del país es requerido';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(widget.pais == null ? 'Crear' : 'Actualizar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Guardar referencia antes de operaciones async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final message = await widget.onSubmit(_paisController.text.trim());

      if (mounted) {
        navigator.pop();
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(ErrorMessages.getFriendlyMessage(e)),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
