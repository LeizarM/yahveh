import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/linea_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/linea_provider.dart';
import '../providers/familia_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Pantalla de gestión de Líneas con diseño glassmorphism
class LineasScreen extends ConsumerStatefulWidget {
  const LineasScreen({super.key});

  @override
  ConsumerState<LineasScreen> createState() => _LineasScreenState();
}

class _LineasScreenState extends ConsumerState<LineasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lineaController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isEditing = false;
  int? _editingCodLinea;
  int? _selectedFamiliaId;
  String _searchQuery = '';

  @override
  void dispose() {
    _lineaController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) {
      if (mounted) {
        context.showSnackBar('Error: Usuario no autenticado', isError: true);
      }
      return;
    }

    try {
      String message;
      
      if (_isEditing && _editingCodLinea != null) {
        // Actualizar línea existente
        message = await ref.read(lineaProvider.notifier).updateLinea(
              codLinea: _editingCodLinea!,
              codFamilia: _selectedFamiliaId!,
              linea: _lineaController.text.trim(),
              audUsuario: user.codUsuario,
            );
      } else {
        // Crear nueva línea
        message = await ref.read(lineaProvider.notifier).createLinea(
              codFamilia: _selectedFamiliaId!,
              linea: _lineaController.text.trim(),
              audUsuario: user.codUsuario,
            );
      }

      if (mounted) {
        context.showSnackBar(message);
      }

      _resetForm();
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          ErrorMessages.getFriendlyMessage(e),
          isError: true,
        );
      }
    }
  }

  void _handleEdit(LineaEntity linea) {
    setState(() {
      _isEditing = true;
      _editingCodLinea = linea.codLinea;
      _selectedFamiliaId = linea.codFamilia;
      _lineaController.text = linea.linea;
    });
  }

  void _handleDelete(int codLinea) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(),
    );

    if (confirmed == true) {
      try {
        final message = await ref.read(lineaProvider.notifier).deleteLinea(codLinea);

        if (mounted) {
          context.showSnackBar(message);
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(
            ErrorMessages.getFriendlyMessage(e),
            isError: true,
          );
        }
      }
    }
  }

  Widget _buildDeleteDialog() {
    return Dialog(
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirmar eliminación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Está seguro de eliminar esta línea?',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.white),
                      ),
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

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingCodLinea = null;
      _selectedFamiliaId = null;
      _lineaController.clear();
    });
    _formKey.currentState?.reset();
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

  @override
  Widget build(BuildContext context) {
    final lineasState = ref.watch(lineaProvider);
    final deviceType = context.deviceType;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: deviceType != DeviceType.desktop
          ? AppBar(
              title: const Text('Gestión de Líneas'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      drawer: deviceType != DeviceType.desktop ? _buildBlurredDrawer() : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _resetForm();
          // Scroll al formulario si es necesario
        },
        backgroundColor: AppTheme.accentCyan,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: ResponsiveLayout(
          mobile: _buildContent(lineasState, isMobile: true),
          tablet: _buildContent(lineasState, isMobile: false),
          desktop: Row(
            children: [
              _buildPermanentDrawer(),
              Expanded(
                child: _buildContent(lineasState, isMobile: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncValue<List<LineaEntity>> lineasState, {required bool isMobile}) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título en desktop
            if (!isMobile) ...[
              FadeSlideAnimation(
                child: Text(
                  'Gestión de Líneas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Formulario con glassmorphism
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 100),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentCyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _isEditing ? Icons.edit : Icons.add_circle_outline,
                                color: AppTheme.accentCyan,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isEditing ? 'Editar Línea' : 'Nueva Línea',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Dropdown de Familia con estilo glassmorphism
                        _buildFamiliaDropdown(),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _lineaController,
                          label: 'Nombre de la Línea',
                          prefixIcon: Icons.category_outlined,
                          validator: (value) => Validators.required(
                            value,
                            fieldName: 'Línea',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: _isEditing ? 'Actualizar' : 'Guardar',
                                onPressed: _handleSubmit,
                                icon: _isEditing ? Icons.edit : Icons.save,
                              ),
                            ),
                            if (_isEditing) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomButton(
                                  text: 'Cancelar',
                                  onPressed: _resetForm,
                                  icon: Icons.cancel_outlined,
                                  isOutlined: true,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Título y buscador
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Icon(
                    Icons.list_alt,
                    color: AppTheme.accentCyan,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Líneas Registradas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Campo de búsqueda con estilo glassmorphism
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  cursorColor: AppTheme.accentCyan,
                  decoration: InputDecoration(
                    hintText: 'Buscar línea...',
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
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de líneas
            SizedBox(
              height: 400,
              child: lineasState.when(
                data: (lineas) {
                  // Filtrar líneas según la búsqueda
                  final filteredLineas = _searchQuery.isEmpty
                      ? lineas
                      : lineas.where((linea) {
                          return linea.linea.toLowerCase().contains(_searchQuery) ||
                                 (linea.codLinea?.toString() ?? '').contains(_searchQuery);
                        }).toList();

                  if (lineas.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.category_outlined,
                      title: 'No hay líneas registradas',
                      subtitle: 'Crea tu primera línea usando el formulario',
                    );
                  }

                  if (filteredLineas.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.search_off,
                      title: 'No se encontraron líneas',
                      subtitle: 'Intenta con otro término de búsqueda',
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        itemCount: filteredLineas.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        itemBuilder: (context, index) {
                          final linea = filteredLineas[index];
                          return FadeSlideAnimation(
                            delay: Duration(milliseconds: 50 * index),
                            child: _buildLineaTile(linea),
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentCyan,
                  ),
                ),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineaTile(LineaEntity linea) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.accentCyan.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.category,
          color: AppTheme.accentCyan,
        ),
      ),
      title: Text(
        linea.linea,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (linea.codLinea != null)
            Text(
              'Código: ${linea.codLinea}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          if (linea.totalArticulos != null)
            Text(
              'Artículos: ${linea.totalArticulos} (${linea.articulosActivos ?? 0} activos)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _handleEdit(linea),
            tooltip: 'Editar',
            color: AppTheme.accentCyan,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: linea.codLinea != null
                ? () => _handleDelete(linea.codLinea!)
                : null,
            tooltip: 'Eliminar',
            color: Colors.red.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar las líneas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              ErrorMessages.getFriendlyMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(lineaProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget del dropdown de Familia con estilo glassmorphism
  Widget _buildFamiliaDropdown() {
    final familiasAsync = ref.watch(familiaProvider);

    return familiasAsync.when(
      data: (familias) {
        if (familias.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade300),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay familias registradas.\nPrimero debes crear una familia.',
                    style: TextStyle(color: Colors.orange.shade200),
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
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedFamiliaId,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A1D2E),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Familia *',
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              floatingLabelStyle: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              helperText: 'Selecciona una familia',
              helperStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              prefixIcon: Icon(
                Icons.family_restroom,
                color: AppTheme.accentCyan,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            items: familias.map((familia) {
              return DropdownMenuItem(
                value: familia.codFamilia,
                child: Text(
                  familia.familia,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedFamiliaId = value),
            validator: (value) => value == null ? 'Selecciona una familia' : null,
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentCyan,
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade300),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error al cargar familias',
                style: TextStyle(color: Colors.red.shade200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
