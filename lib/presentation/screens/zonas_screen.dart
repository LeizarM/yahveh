import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/zona_entity.dart';
import '../../data/models/zona_model.dart';
import '../providers/zona_provider.dart';
import '../providers/ciudad_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Zonas con CRUD completo y diseño glassmorphism
class ZonasScreen extends ConsumerStatefulWidget {
  const ZonasScreen({super.key});

  @override
  ConsumerState<ZonasScreen> createState() => _ZonasScreenState();
}

class _ZonasScreenState extends ConsumerState<ZonasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zonasAsync = ref.watch(zonaProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Zonas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.refresh(zonaProvider),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: context.isMobile ? _buildBlurredDrawer() : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddZonaDialog(context),
        backgroundColor: AppTheme.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Row(
          children: [
            if (!context.isMobile) _buildPermanentDrawer(),
            Expanded(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: zonasAsync.when(
                        data: (zonas) {
                          final filteredZonas = zonas.where((zona) {
                            if (_searchQuery.isEmpty) return true;
                            return zona.zona.toLowerCase().contains(_searchQuery.toLowerCase());
                          }).toList();

                          if (filteredZonas.isEmpty) {
                            return _buildEmptyState();
                          }
                          return _buildZonasList(filteredZonas);
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        error: (error, stack) => _buildErrorState(error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  const Color(0xFF1A1D2E).withValues(alpha: 0.95),
                  const Color(0xFF2D3250).withValues(alpha: 0.92),
                ],
              ),
            ),
            child: const AppDrawer(),
          ),
        ),
      ),
    );
  }

  Widget _buildPermanentDrawer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E).withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          cursorColor: AppTheme.accentGreen,
          decoration: InputDecoration(
            hintText: 'Buscar zonas...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            prefixIcon: Icon(Icons.search, color: AppTheme.accentGreen),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.7)),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeSlideAnimation(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 64,
                color: AppTheme.accentGreen.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron zonas'
                  : 'No hay zonas registradas',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otro término de búsqueda'
                  : 'Agrega la primera zona usando el botón +',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FadeSlideAnimation(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No se pudieron cargar las zonas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                ErrorMessages.getFriendlyMessage(error),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(zonaProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildZonasList(List<ZonaEntity> zonas) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: zonas.length,
      itemBuilder: (context, index) {
        final zona = zonas[index];
        final zonaModel = zona is ZonaModel ? zona : null;

        return FadeSlideAnimation(
          delay: Duration(milliseconds: 50 * index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map,
                    color: AppTheme.accentGreen,
                    size: 24,
                  ),
                ),
                title: Text(
                  zona.zona,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    zonaModel?.ciudadNombre != null && zonaModel?.paisNombre != null
                        ? '${zonaModel!.ciudadNombre} - ${zonaModel.paisNombre}'
                        : 'Ciudad ID: ${zona.codCiudad}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      onPressed: () => _showEditZonaDialog(context, zona),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorColor.withValues(alpha: 0.8),
                      ),
                      onPressed: () => _showDeleteConfirmation(context, zona),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddZonaDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ZonaFormDialog(
        onSubmit: (codCiudad, zona) async {
          final user = ref.read(authProvider).value;
          return await ref.read(zonaProvider.notifier).createZona(
                codCiudad: codCiudad,
                zona: zona,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showEditZonaDialog(BuildContext context, ZonaEntity zona) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ZonaFormDialog(
        zona: zona,
        onSubmit: (codCiudad, zonaNombre) async {
          final user = ref.read(authProvider).value;
          return await ref.read(zonaProvider.notifier).updateZona(
                codZona: zona.codZona,
                codCiudad: codCiudad,
                zona: zonaNombre,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ZonaEntity zona) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1D2E).withValues(alpha: 0.95),
                const Color(0xFF2D3250).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 40,
                  color: AppTheme.errorColor.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirmar eliminación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '¿Eliminar la zona "${zona.zona}"?',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          final message = await ref.read(zonaProvider.notifier).deleteZona(zona.codZona);
                          if (mounted) {
                            AppOverlay.showMessage(context, message, isSuccess: true);
                          }
                        } catch (e) {
                          if (mounted) {
                            AppOverlay.showMessage(context, ErrorMessages.getFriendlyMessage(e), isError: true);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
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
    );
  }
}

/// Formulario de zona con estilo glassmorphism
class _ZonaFormDialog extends ConsumerStatefulWidget {
  final ZonaEntity? zona;
  final Future<String> Function(int codCiudad, String zona) onSubmit;

  const _ZonaFormDialog({this.zona, required this.onSubmit});

  @override
  ConsumerState<_ZonaFormDialog> createState() => _ZonaFormDialogState();
}

class _ZonaFormDialogState extends ConsumerState<_ZonaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _zonaController;
  int? _selectedCiudadId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _zonaController = TextEditingController(text: widget.zona?.zona ?? '');
    _selectedCiudadId = widget.zona?.codCiudad;
  }

  @override
  void dispose() {
    _zonaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ciudadesAsync = ref.watch(ciudadProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1D2E).withValues(alpha: 0.95),
              const Color(0xFF2D3250).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.map,
                        color: AppTheme.accentGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.zona == null ? 'Agregar Zona' : 'Editar Zona',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Dropdown de Ciudad con estilo glassmorphism
                Text(
                  'Ciudad',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ciudadesAsync.when(
                  data: (ciudades) {
                    if (ciudades.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.warningColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: AppTheme.warningColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No hay ciudades registradas.\nPrimero debes crear una ciudad.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedCiudadId,
                        dropdownColor: const Color(0xFF2D3250),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.8)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                          hintText: 'Selecciona una ciudad',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        items: ciudades.map((ciudad) {
                          final ciudadModel = ciudad as dynamic;
                          final paisNombre = ciudadModel.paisNombre ?? '';
                          final displayText = paisNombre.isNotEmpty
                              ? '${ciudad.ciudad} - $paisNombre'
                              : ciudad.ciudad;

                          return DropdownMenuItem(
                            value: ciudad.codCiudad,
                            child: Text(
                              displayText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCiudadId = value),
                        validator: (value) => value == null ? 'Selecciona una ciudad' : null,
                      ),
                    );
                  },
                  loading: () => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  error: (e, _) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Error al cargar ciudades: $e',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de Zona
                Text(
                  'Nombre de la Zona',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextFormField(
                    controller: _zonaController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    cursorColor: AppTheme.accentGreen,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                      hintText: 'Ej: Zona Norte, Zona Centro...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'El nombre es requerido' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
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
                            : Text(widget.zona == null ? 'Crear' : 'Actualizar'),
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

    setState(() => _isLoading = true);

    try {
      final message = await widget.onSubmit(_selectedCiudadId!, _zonaController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        AppOverlay.showMessage(context, message, isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        AppOverlay.showMessage(context, ErrorMessages.getFriendlyMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
