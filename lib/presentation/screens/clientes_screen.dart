import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/cliente_entity.dart';
import '../../domain/entities/telefono_cliente_entity.dart';
import '../../data/models/cliente_model.dart';
import '../providers/cliente_provider.dart';
import '../providers/zona_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Clientes con CRUD completo - Diseño Glassmorphism
class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clienteProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Clientes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.refresh(clienteProvider),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: context.isMobile ? _buildBlurredDrawer() : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClienteDialog(context),
        backgroundColor: AppTheme.accentGreen,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Nuevo Cliente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Row(
            children: [
              if (!context.isMobile) _buildPermanentDrawer(),
              Expanded(
                child: Column(
                  children: [
                    // Barra de búsqueda con estilo glassmorphism
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSearchBar(),
                    ),
                    // Lista de clientes
                    Expanded(
                      child: clientesAsync.when(
                        data: (clientes) => _buildClientesList(clientes),
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        error: (error, stack) => _buildErrorWidget(error),
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
    return Container(
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppTheme.accentCyan,
        decoration: InputDecoration(
          hintText: 'Buscar cliente por nombre, NIT o razón social...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          prefixIcon: Icon(Icons.search, color: AppTheme.accentCyan),
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
        onChanged: (value) =>
            setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildClientesList(List<ClienteEntity> clientes) {
    final filteredClientes = _searchQuery.isEmpty
        ? clientes
        : clientes.where((c) {
            return c.nombreCliente.toLowerCase().contains(_searchQuery) ||
                c.nit.toLowerCase().contains(_searchQuery) ||
                c.razonSocial.toLowerCase().contains(_searchQuery);
          }).toList();

    if (filteredClientes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredClientes.length,
      itemBuilder: (context, index) {
        final cliente = filteredClientes[index];
        return FadeSlideAnimation(
          delay: Duration(milliseconds: 50 * index),
          child: _buildClienteCard(cliente),
        );
      },
    );
  }

  Widget _buildClienteCard(ClienteEntity cliente) {
    final clienteModel = cliente is ClienteModel ? cliente : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGreen,
                  AppTheme.accentGreen.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                cliente.nombreCliente[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          title: Text(
            cliente.nombreCliente,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'NIT: ${cliente.nit}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              if (clienteModel?.zonaNombre != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppTheme.accentOrange,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${clienteModel!.zonaNombre}'
                          '${clienteModel.ciudadNombre != null ? " - ${clienteModel.ciudadNombre}" : ""}'
                          '${clienteModel.paisNombre != null ? " - ${clienteModel.paisNombre}" : ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconButton(
                icon: Icons.phone,
                color: AppTheme.accentCyan,
                tooltip: 'Teléfonos',
                onPressed: () => _showTelefonosDialog(context, cliente),
              ),
              _buildIconButton(
                icon: Icons.edit,
                color: AppTheme.accentOrange,
                tooltip: 'Editar',
                onPressed: () => _showEditClienteDialog(context, cliente),
              ),
              _buildIconButton(
                icon: Icons.delete,
                color: AppTheme.errorColor,
                tooltip: 'Eliminar',
                onPressed: () => _showDeleteConfirmation(context, cliente),
              ),
            ],
          ),
          iconColor: Colors.white.withValues(alpha: 0.7),
          collapsedIconColor: Colors.white.withValues(alpha: 0.7),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Razón Social', cliente.razonSocial),
                  _buildDetailRow('Dirección', cliente.direccion),
                  _buildDetailRow('Referencia', cliente.referencia),
                  if (cliente.obs.isNotEmpty)
                    _buildDetailRow('Observaciones', cliente.obs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
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
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay clientes registrados'
                  : 'No se encontraron clientes',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Agrega el primer cliente usando el botón +'
                  : 'Intenta con otra búsqueda',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
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
                  color: AppTheme.errorColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No se pudieron cargar los clientes',
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
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(clienteProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddClienteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ClienteFormDialog(
        onSubmit:
            (
              codZona,
              nit,
              razonSocial,
              nombreCliente,
              direccion,
              referencia,
              obs,
              telefonos,
            ) async {
              final user = ref.read(authProvider).value;

              final nuevoCliente = await ref
                  .read(clienteProvider.notifier)
                  .createCliente(
                    codZona: codZona,
                    nit: nit,
                    razonSocial: razonSocial,
                    nombreCliente: nombreCliente,
                    direccion: direccion,
                    referencia: referencia,
                    obs: obs,
                    audUsuario: user?.codUsuario ?? 0,
                  );

              if (telefonos.isNotEmpty) {
                await ref
                    .read(telefonoClienteProvider.notifier)
                    .crearMultiples(
                      codCliente: nuevoCliente.codCliente,
                      telefonos: telefonos,
                    );
              }

              return 'Cliente creado exitosamente';
            },
      ),
    );
  }

  void _showEditClienteDialog(BuildContext context, ClienteEntity cliente) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ClienteFormDialog(
        cliente: cliente,
        onSubmit:
            (
              codZona,
              nit,
              razonSocial,
              nombreCliente,
              direccion,
              referencia,
              obs,
              telefonos,
            ) async {
              final user = ref.read(authProvider).value;
              return await ref
                  .read(clienteProvider.notifier)
                  .updateCliente(
                    codCliente: cliente.codCliente,
                    codZona: codZona,
                    nit: nit,
                    razonSocial: razonSocial,
                    nombreCliente: nombreCliente,
                    direccion: direccion,
                    referencia: referencia,
                    obs: obs,
                    audUsuario: user?.codUsuario ?? 0,
                  );
            },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClienteEntity cliente) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => _GlassDialog(
        title: 'Confirmar eliminación',
        content: '¿Eliminar al cliente "${cliente.nombreCliente}"?',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final message = await ref
                    .read(clienteProvider.notifier)
                    .deleteCliente(cliente.codCliente);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(ErrorMessages.getFriendlyMessage(e)),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showTelefonosDialog(BuildContext context, ClienteEntity cliente) {
    showDialog(
      context: context,
      builder: (context) => _TelefonosClienteDialog(cliente: cliente),
    );
  }
}

/// Formulario de cliente con estilo glassmorphism
class _ClienteFormDialog extends ConsumerStatefulWidget {
  final ClienteEntity? cliente;
  final Future<String> Function(
    int codZona,
    String nit,
    String razonSocial,
    String nombreCliente,
    String direccion,
    String referencia,
    String obs,
    List<String> telefonos,
  )
  onSubmit;

  const _ClienteFormDialog({this.cliente, required this.onSubmit});

  @override
  ConsumerState<_ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends ConsumerState<_ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late TextEditingController _nitController;
  late TextEditingController _razonSocialController;
  late TextEditingController _nombreClienteController;
  late TextEditingController _direccionController;
  late TextEditingController _referenciaController;
  late TextEditingController _obsController;
  final List<TextEditingController> _telefonoControllers = [];
  int? _selectedZonaId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nitController = TextEditingController(text: widget.cliente?.nit ?? '');
    _razonSocialController = TextEditingController(
      text: widget.cliente?.razonSocial ?? '',
    );
    _nombreClienteController = TextEditingController(
      text: widget.cliente?.nombreCliente ?? '',
    );
    _direccionController = TextEditingController(
      text: widget.cliente?.direccion ?? '',
    );
    _referenciaController = TextEditingController(
      text: widget.cliente?.referencia ?? '',
    );
    _obsController = TextEditingController(text: widget.cliente?.obs ?? '');
    _selectedZonaId = widget.cliente?.codZona;

    if (widget.cliente == null) {
      _telefonoControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nitController.dispose();
    _razonSocialController.dispose();
    _nombreClienteController.dispose();
    _direccionController.dispose();
    _referenciaController.dispose();
    _obsController.dispose();
    for (var controller in _telefonoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTelefonoField() {
    setState(() {
      _telefonoControllers.add(TextEditingController());
    });
  }

  void _removeTelefonoField(int index) {
    setState(() {
      _telefonoControllers[index].dispose();
      _telefonoControllers.removeAt(index);
    });
  }

  InputDecoration _glassInputDecoration(
    String label, {
    String? hint,
    IconData? prefixIcon,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      helperStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      floatingLabelStyle: const TextStyle(
        color: AppTheme.accentGreen,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppTheme.accentGreen)
          : null,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.accentGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
      ),
      errorStyle: const TextStyle(color: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zonasAsync = ref.watch(zonaProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isEditing = widget.cliente != null;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: MediaQuery.of(context).size.width > 500
                    ? 500
                    : MediaQuery.of(context).size.width * 0.95,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1D2E).withValues(alpha: 0.95),
                      const Color(0xFF2D3250).withValues(alpha: 0.92),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.cliente == null
                                  ? Icons.person_add
                                  : Icons.edit,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.cliente == null
                                  ? 'Agregar Cliente'
                                  : 'Editar Cliente',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Dropdown de Zona
                              zonasAsync.when(
                                data: (zonas) {
                                  if (zonas.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningColor.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.warningColor
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.warning,
                                            color: AppTheme.warningColor,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'No hay zonas registradas.\nPrimero debes crear una zona.',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return DropdownButtonFormField<int>(
                                    initialValue: _selectedZonaId,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF2D3250),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _glassInputDecoration(
                                      'Zona *',
                                      helperText: 'Zona - Ciudad - País',
                                    ),
                                    items: zonas.map((zona) {
                                      final zonaModel = zona as dynamic;
                                      final ciudadNombre =
                                          zonaModel.ciudadNombre ?? '';
                                      final paisNombre =
                                          zonaModel.paisNombre ?? '';

                                      String displayText = zona.zona;
                                      if (ciudadNombre.isNotEmpty &&
                                          paisNombre.isNotEmpty) {
                                        displayText =
                                            '${zona.zona} - $ciudadNombre - $paisNombre';
                                      } else if (ciudadNombre.isNotEmpty) {
                                        displayText =
                                            '${zona.zona} - $ciudadNombre';
                                      }

                                      return DropdownMenuItem(
                                        value: zona.codZona,
                                        child: Text(
                                          displayText,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        setState(() => _selectedZonaId = value),
                                    validator: (value) => value == null
                                        ? 'Selecciona una zona'
                                        : null,
                                  );
                                },
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      color: AppTheme.accentGreen,
                                    ),
                                  ),
                                ),
                                error: (e, _) => Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Error al cargar zonas: $e',
                                    style: const TextStyle(
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // NIT - Solo admin puede editar en modo edición
                              TextFormField(
                                controller: _nitController,
                                style: TextStyle(
                                  color: (isEditing && !isAdmin)
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.white,
                                ),
                                readOnly: isEditing && !isAdmin,
                                decoration:
                                    _glassInputDecoration(
                                      isEditing && !isAdmin
                                          ? 'NIT (Solo lectura)'
                                          : 'NIT *',
                                      helperText: isEditing && !isAdmin
                                          ? 'Solo administradores pueden modificar el NIT'
                                          : null,
                                    ).copyWith(
                                      fillColor: (isEditing && !isAdmin)
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                    ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'El NIT es requerido'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              // Razón Social
                              TextFormField(
                                controller: _razonSocialController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration(
                                  'Razón Social *',
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'La razón social es requerida'
                                    : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 16),
                              // Nombre del Cliente
                              TextFormField(
                                controller: _nombreClienteController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration(
                                  'Nombre del Cliente *',
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'El nombre es requerido'
                                    : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 16),
                              // Dirección
                              TextFormField(
                                controller: _direccionController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration(
                                  'Dirección *',
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'La dirección es requerida'
                                    : null,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              // Referencia
                              TextFormField(
                                controller: _referenciaController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration(
                                  'Referencia *',
                                  helperText: 'Punto de referencia para ubicar',
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'La referencia es requerida'
                                    : null,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              // Observaciones
                              TextFormField(
                                controller: _obsController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration(
                                  'Observaciones',
                                  helperText: 'Opcional',
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 3,
                              ),

                              // Sección de Teléfonos (solo al crear)
                              if (widget.cliente == null) ...[
                                const SizedBox(height: 24),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: AppTheme.accentCyan,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Teléfonos',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: _addTelefonoField,
                                      icon: const Icon(
                                        Icons.add,
                                        size: 18,
                                        color: AppTheme.accentGreen,
                                      ),
                                      label: const Text(
                                        'Agregar',
                                        style: TextStyle(
                                          color: AppTheme.accentGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_telefonoControllers.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Opcional: Agrega teléfonos del cliente',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  ..._telefonoControllers.asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final controller = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: controller,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              decoration: _glassInputDecoration(
                                                'Teléfono ${index + 1}',
                                                hint: 'Ej: 70012345',
                                                prefixIcon: Icons.phone,
                                              ),
                                              keyboardType: TextInputType.phone,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () =>
                                                _removeTelefonoField(index),
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: AppTheme.errorColor,
                                            ),
                                            tooltip: 'Quitar',
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
                                : Text(
                                    widget.cliente == null
                                        ? 'Crear'
                                        : 'Actualizar',
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
      final message = await widget.onSubmit(
        _selectedZonaId!,
        _nitController.text.trim(),
        _razonSocialController.text.trim(),
        _nombreClienteController.text.trim(),
        _direccionController.text.trim(),
        _referenciaController.text.trim(),
        _obsController.text.trim(),
        _telefonoControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
      );

      if (mounted) {
        Navigator.pop(context);
        // Usar ScaffoldMessenger del contexto principal para que se muestre sobre todo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Mostrar error en el ScaffoldMessenger local del diálogo
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.getFriendlyMessage(e)),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// Diálogo de confirmación con estilo glassmorphism
class _GlassDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  const _GlassDialog({
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1D2E).withValues(alpha: 0.95),
                  const Color(0xFF2D3250).withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Diálogo para gestionar teléfonos de un cliente con estilo glassmorphism
class _TelefonosClienteDialog extends ConsumerStatefulWidget {
  final ClienteEntity cliente;

  const _TelefonosClienteDialog({required this.cliente});

  @override
  ConsumerState<_TelefonosClienteDialog> createState() =>
      _TelefonosClienteDialogState();
}

class _TelefonosClienteDialogState
    extends ConsumerState<_TelefonosClienteDialog> {
  List<TelefonoClienteEntity> _telefonos = [];
  final List<TextEditingController> _newTelefonoControllers = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTelefonos();
  }

  @override
  void dispose() {
    for (var controller in _newTelefonoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTelefonos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final telefonos = await ref
          .read(telefonoClienteProvider.notifier)
          .cargarPorCliente(widget.cliente.codCliente);
      setState(() {
        _telefonos = telefonos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorMessages.getFriendlyMessage(e);
        _isLoading = false;
      });
    }
  }

  void _addNewTelefonoField() {
    setState(() {
      _newTelefonoControllers.add(TextEditingController());
    });
  }

  void _removeNewTelefonoField(int index) {
    setState(() {
      _newTelefonoControllers[index].dispose();
      _newTelefonoControllers.removeAt(index);
    });
  }

  InputDecoration _glassInputDecoration(
    String label, {
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: AppTheme.accentCyan,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppTheme.accentCyan)
          : null,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.accentCyan, width: 2),
      ),
    );
  }

  Future<void> _saveTelefonos() async {
    final telefonosToAdd = _newTelefonoControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (telefonosToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese al menos un número de teléfono'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(telefonoClienteProvider.notifier)
          .crearMultiples(
            codCliente: widget.cliente.codCliente,
            telefonos: telefonosToAdd,
          );

      if (mounted) {
        for (var controller in _newTelefonoControllers) {
          controller.dispose();
        }
        _newTelefonoControllers.clear();
        await _loadTelefonos();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${telefonosToAdd.length} teléfono(s) agregado(s) exitosamente',
            ),
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteTelefono(TelefonoClienteEntity telefono) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _GlassDialog(
        title: 'Confirmar eliminación',
        content: '¿Eliminar el teléfono "${telefono.telefono}"?',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref
          .read(telefonoClienteProvider.notifier)
          .eliminar(telefono.codTlfCliente);
      await _loadTelefonos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teléfono eliminado exitosamente'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 500,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1D2E).withValues(alpha: 0.95),
                  const Color(0xFF2D3250).withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: AppTheme.accentCyan,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Teléfonos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.cliente.nombreCliente,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: AppTheme.accentCyan,
                            ),
                          ),
                        )
                      : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.error_outline,
                                    size: 40,
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadTelefonos,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Teléfonos existentes
                              if (_telefonos.isNotEmpty) ...[
                                Text(
                                  'Teléfonos registrados (${_telefonos.length})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._telefonos.map(
                                  (telefono) => FadeSlideAnimation(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentCyan
                                                .withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.phone,
                                            color: AppTheme.accentCyan,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          telefono.telefono,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: AppTheme.errorColor,
                                          ),
                                          onPressed: () =>
                                              _deleteTelefono(telefono),
                                          tooltip: 'Eliminar',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Sección para agregar nuevos teléfonos
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Agregar teléfonos',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _addNewTelefonoField,
                                    icon: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: AppTheme.accentGreen,
                                    ),
                                    label: const Text(
                                      'Agregar',
                                      style: TextStyle(
                                        color: AppTheme.accentGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (_newTelefonoControllers.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Presiona "Agregar" para añadir números de teléfono',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ..._newTelefonoControllers.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final controller = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: controller,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: _glassInputDecoration(
                                              'Teléfono ${index + 1}',
                                              hint: 'Ej: 70012345',
                                              prefixIcon: Icons.phone,
                                            ),
                                            keyboardType: TextInputType.phone,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () =>
                                              _removeNewTelefonoField(index),
                                          icon: const Icon(
                                            Icons.remove_circle,
                                            color: AppTheme.errorColor,
                                          ),
                                          tooltip: 'Quitar campo',
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                              if (_newTelefonoControllers.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveTelefonos,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(
                                    _isSaving
                                        ? 'Guardando...'
                                        : 'Guardar teléfonos',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
