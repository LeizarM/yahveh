import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/ciudad_entity.dart';
import '../../data/models/ciudad_model.dart';
import '../providers/ciudad_provider.dart';
import '../providers/pais_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Ciudades con CRUD completo y diseño glassmorphism
class CiudadesScreen extends ConsumerStatefulWidget {
  const CiudadesScreen({super.key});

  @override
  ConsumerState<CiudadesScreen> createState() => _CiudadesScreenState();
}

class _CiudadesScreenState extends ConsumerState<CiudadesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ciudadesAsync = ref.watch(ciudadProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Ciudades',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => ref.refresh(ciudadProvider),
              tooltip: 'Actualizar',
            ),
          ],
        ),
        drawer: context.isMobile ? _buildBlurredDrawer() : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCiudadDialog(context),
          backgroundColor: AppTheme.accentOrange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Row(
          children: [
            if (!context.isMobile) _buildPermanentDrawer(),
            Expanded(
              child: SafeArea(
                child: Column(
                  children: [
                    // Barra de búsqueda moderna
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSearchBar(),
                    ),
                    // Lista de ciudades
                    Expanded(
                      child: ciudadesAsync.when(
                        data: (ciudades) {
                          final filteredCiudades = ciudades.where((ciudad) {
                            return ciudad.ciudad
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase());
                          }).toList();

                          if (filteredCiudades.isEmpty) {
                            return _buildEmptyState();
                          }
                          return _buildCiudadesList(filteredCiudades);
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
                  const Color(0xFF1A1D2E).withOpacity(0.95),
                  const Color(0xFF2D3250).withOpacity(0.92),
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
            color: const Color(0xFF1A1D2E).withOpacity(0.85),
            border: Border(
              right: BorderSide(
                color: Colors.white.withOpacity(0.1),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        cursorColor: AppTheme.accentCyan,
        decoration: InputDecoration(
          hintText: 'Buscar ciudades...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: AppTheme.accentCyan),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
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
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_city_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay ciudades registradas'
                  : 'No se encontraron resultados',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Agrega la primera ciudad usando el botón +'
                  : 'Intenta con otro término de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: FadeSlideAnimation(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No se pudieron cargar las ciudades',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                ErrorMessages.getFriendlyMessage(error),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(ciudadProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
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

  Widget _buildCiudadesList(List<CiudadEntity> ciudades) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ciudades.length,
      itemBuilder: (context, index) {
        final ciudad = ciudades[index];
        final ciudadModel = ciudad is CiudadModel ? ciudad : null;
        return FadeSlideAnimation(
          delay: Duration(milliseconds: 50 * index),
          child: _buildCiudadCard(ciudad, ciudadModel),
        );
      },
    );
  }

  Widget _buildCiudadCard(CiudadEntity ciudad, CiudadModel? ciudadModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.location_city,
            color: AppTheme.accentOrange,
          ),
        ),
        title: Text(
          ciudad.ciudad,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'País: ${ciudadModel?.paisNombre ?? "ID ${ciudad.codPais}"}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () => _showEditCiudadDialog(context, ciudad),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor.withOpacity(0.8),
              ),
              onPressed: () => _showDeleteConfirmation(context, ciudad),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCiudadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CiudadFormDialog(
        onSubmit: (codPais, ciudad) async {
          final user = ref.read(authProvider).value;
          return await ref.read(ciudadProvider.notifier).createCiudad(
                codPais: codPais,
                ciudad: ciudad,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showEditCiudadDialog(BuildContext context, CiudadEntity ciudad) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CiudadFormDialog(
        ciudad: ciudad,
        onSubmit: (codPais, ciudadNombre) async {
          final user = ref.read(authProvider).value;
          return await ref.read(ciudadProvider.notifier).updateCiudad(
                codCiudad: ciudad.codCiudad,
                codPais: codPais,
                ciudad: ciudadNombre,
                audUsuario: user?.codUsuario ?? 0,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CiudadEntity ciudad) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1D2E).withOpacity(0.95),
                  const Color(0xFF2D3250).withOpacity(0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Confirmar eliminación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Eliminar "${ciudad.ciudad}"?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            final message = await ref
                                .read(ciudadProvider.notifier)
                                .deleteCiudad(ciudad.codCiudad);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ErrorMessages.getFriendlyMessage(e)),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

/// Formulario de ciudad con estilo glassmorphism
class _CiudadFormDialog extends ConsumerStatefulWidget {
  final CiudadEntity? ciudad;
  final Future<String> Function(int codPais, String ciudad) onSubmit;

  const _CiudadFormDialog({this.ciudad, required this.onSubmit});

  @override
  ConsumerState<_CiudadFormDialog> createState() => _CiudadFormDialogState();
}

class _CiudadFormDialogState extends ConsumerState<_CiudadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ciudadController;
  int? _selectedPaisId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ciudadController = TextEditingController(text: widget.ciudad?.ciudad ?? '');
    _selectedPaisId = widget.ciudad?.codPais;
  }

  @override
  void dispose() {
    _ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paisesAsync = ref.watch(paisProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1D2E).withOpacity(0.95),
                const Color(0xFF2D3250).withOpacity(0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
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
                        color: AppTheme.accentOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: AppTheme.accentOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.ciudad == null ? 'Agregar Ciudad' : 'Editar Ciudad',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Dropdown de país con estilo glassmorphism
                Text(
                  'País',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                paisesAsync.when(
                  data: (paises) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _selectedPaisId,
                        dropdownColor: const Color(0xFF2D3250),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          hintText: 'Selecciona un país',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        items: paises.map((pais) {
                          return DropdownMenuItem(
                            value: pais.codPais,
                            child: Text(
                              pais.pais,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedPaisId = value),
                        validator: (value) =>
                            value == null ? 'Selecciona un país' : null,
                      ),
                    );
                  },
                  loading: () => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Error al cargar países',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de nombre de ciudad
                Text(
                  'Nombre de la Ciudad',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: TextFormField(
                    controller: _ciudadController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    cursorColor: AppTheme.accentCyan,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      hintText: 'Ingresa el nombre',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'El nombre es requerido'
                        : null,
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
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor:
                              AppTheme.accentOrange.withOpacity(0.5),
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
                            : Text(widget.ciudad == null ? 'Crear' : 'Actualizar'),
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
      final message =
          await widget.onSubmit(_selectedPaisId!, _ciudadController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.getFriendlyMessage(e)),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
