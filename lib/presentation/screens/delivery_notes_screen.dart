import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/animations.dart';
import '../../domain/entities/nota_entrega_entity.dart';
import '../../domain/entities/detalle_nota_entrega_entity.dart';
import '../../domain/entities/cliente_entity.dart';
import '../../domain/entities/articulo_entity.dart';
import '../../domain/entities/zona_entity.dart';
import '../../domain/entities/regla_descuento_entity.dart';
import '../../data/models/zona_model.dart';
import '../providers/providers.dart';
import '../providers/auth_provider.dart';
import '../providers/cliente_provider.dart';
import '../providers/articulo_provider.dart';
import '../providers/nota_entrega_provider.dart';
import '../providers/zona_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Notas de Entrega
class DeliveryNotesScreen extends ConsumerStatefulWidget {
  const DeliveryNotesScreen({super.key});

  @override
  ConsumerState<DeliveryNotesScreen> createState() =>
      _DeliveryNotesScreenState();
}

class _DeliveryNotesScreenState extends ConsumerState<DeliveryNotesScreen> {
  // Clave global para el ScaffoldMessenger - permite mostrar SnackBars sobre diálogos
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Controladores para filtros de búsqueda
  final TextEditingController _searchController = TextEditingController();
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  String _searchQuery = '';

  /// Muestra un SnackBar que aparece sobre cualquier diálogo o modal
  void _showSnackBar(SnackBar snackBar) {
    _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final esVendedor = ref.read(userTypeProvider) == 'lim';
      if (esVendedor) {
        final hoy = DateTime.now();
        setState(() {
          _fechaDesde = hoy;
          _fechaHasta = hoy;
        });
        ref.read(notaEntregaProvider.notifier).cargarNotasPorFechas(
          fechaInicio: hoy,
          fechaFin: hoy,
        );
      } else {
        ref.read(notaEntregaProvider.notifier).cargarNotas();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notasAsync = ref.watch(notaEntregaProvider);
    final filtroActual = ref.watch(notaEntregaProvider.notifier).filtroActual;
    final isMobile = context.isMobile;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Notas de Entrega',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            // Menú de filtros
            PopupMenuButton<NotaFiltroTipo>(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              tooltip: 'Filtrar por estado',
              onSelected: (filtro) {
                switch (filtro) {
                  case NotaFiltroTipo.validas:
                    ref.read(notaEntregaProvider.notifier).cargarNotas();
                    break;
                  case NotaFiltroTipo.anuladas:
                    ref
                        .read(notaEntregaProvider.notifier)
                        .cargarNotasAnuladas();
                    break;
                  case NotaFiltroTipo.todas:
                    ref
                        .read(notaEntregaProvider.notifier)
                        .cargarTodasLasNotas();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: NotaFiltroTipo.validas,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: filtroActual == NotaFiltroTipo.validas
                            ? AppTheme.accentGreen
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('Solo válidas'),
                      if (filtroActual == NotaFiltroTipo.validas)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 16),
                        ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: NotaFiltroTipo.anuladas,
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        color: filtroActual == NotaFiltroTipo.anuladas
                            ? Colors.red
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('Solo anuladas'),
                      if (filtroActual == NotaFiltroTipo.anuladas)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 16),
                        ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: NotaFiltroTipo.todas,
                  child: Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: filtroActual == NotaFiltroTipo.todas
                            ? AppTheme.accentCyan
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('Ver todas'),
                      if (filtroActual == NotaFiltroTipo.todas)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 16),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Filtro por fechas
            IconButton(
              icon: Icon(
                Icons.date_range,
                color: (_fechaDesde != null || _fechaHasta != null)
                    ? AppTheme.accentCyan
                    : Colors.white,
              ),
              onPressed: () => _showDateFilterDialog(context),
              tooltip: 'Filtrar por fechas',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                final esVendedor = ref.read(userTypeProvider) == 'lim';
                if (esVendedor) {
                  final hoy = DateTime.now();
                  setState(() {
                    _fechaDesde = hoy;
                    _fechaHasta = hoy;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  ref.read(notaEntregaProvider.notifier).cargarNotasPorFechas(
                    fechaInicio: hoy,
                    fechaFin: hoy,
                  );
                } else {
                  _limpiarFiltros();
                  ref.read(notaEntregaProvider.notifier).cargarNotas();
                }
              },
              tooltip: 'Actualizar',
            ),
          ],
        ),
        drawer: isMobile
            ? Drawer(
                backgroundColor: Colors.transparent,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryDark.withValues(alpha: 0.92),
                      ),
                      child: const AppDrawer(),
                    ),
                  ),
                ),
              )
            : null,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateNotaDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Nota'),
          backgroundColor: AppTheme.accentGreen,
        ),
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Row(
              children: [
                // Drawer permanente en desktop/tablet con blur
                if (!isMobile)
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        width: 280,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryDark.withValues(alpha: 0.55),
                          border: Border(
                            right: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        child: const AppDrawer(),
                      ),
                    ),
                  ),

                // Contenido principal
                Expanded(
                  child: Column(
                    children: [
                      // Barra de búsqueda y filtro activo
                      _buildSearchAndFilterBar(context, filtroActual),

                      // Lista de notas
                      Expanded(
                        child: notasAsync.when(
                          data: (notas) =>
                              _buildNotasList(context, _filterNotas(notas)),
                          loading: () => Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.accentCyan,
                            ),
                          ),
                          error: (error, stack) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 80,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se pudieron cargar las notas',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    error.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(notaEntregaProvider.notifier)
                                          .cargarNotas();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reintentar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentCyan,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  /// Construir barra de búsqueda y chips de filtro activo
  Widget _buildSearchAndFilterBar(
    BuildContext context,
    NotaFiltroTipo filtroActual,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, dirección o código...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          const SizedBox(height: 12),

          // Chips de filtros activos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Chip de tipo de filtro
                _buildFilterChip(
                  label: _getFiltroLabel(filtroActual),
                  icon: _getFiltroIcon(filtroActual),
                  color: _getFiltroColor(filtroActual),
                  onDeleted: filtroActual != NotaFiltroTipo.validas
                      ? () =>
                            ref.read(notaEntregaProvider.notifier).cargarNotas()
                      : null,
                ),

                // Chip de fecha desde
                if (_fechaDesde != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildFilterChip(
                      label: 'Desde: ${dateFormat.format(_fechaDesde!)}',
                      icon: Icons.calendar_today,
                      color: AppTheme.accentCyan,
                      onDeleted: () {
                        setState(() => _fechaDesde = null);
                        _aplicarFiltroFechas();
                      },
                    ),
                  ),

                // Chip de fecha hasta
                if (_fechaHasta != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildFilterChip(
                      label: 'Hasta: ${dateFormat.format(_fechaHasta!)}',
                      icon: Icons.calendar_today,
                      color: AppTheme.accentCyan,
                      onDeleted: () {
                        setState(() => _fechaHasta = null);
                        _aplicarFiltroFechas();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onDeleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(Icons.close, size: 16, color: color),
            ),
          ],
        ],
      ),
    );
  }

  String _getFiltroLabel(NotaFiltroTipo filtro) {
    switch (filtro) {
      case NotaFiltroTipo.validas:
        return 'Válidas';
      case NotaFiltroTipo.anuladas:
        return 'Anuladas';
      case NotaFiltroTipo.todas:
        return 'Todas';
    }
  }

  IconData _getFiltroIcon(NotaFiltroTipo filtro) {
    switch (filtro) {
      case NotaFiltroTipo.validas:
        return Icons.check_circle;
      case NotaFiltroTipo.anuladas:
        return Icons.cancel;
      case NotaFiltroTipo.todas:
        return Icons.list_alt;
    }
  }

  Color _getFiltroColor(NotaFiltroTipo filtro) {
    switch (filtro) {
      case NotaFiltroTipo.validas:
        return AppTheme.accentGreen;
      case NotaFiltroTipo.anuladas:
        return Colors.red;
      case NotaFiltroTipo.todas:
        return AppTheme.accentCyan;
    }
  }

  /// Filtrar notas por búsqueda local
  List<NotaEntregaEntity> _filterNotas(List<NotaEntregaEntity> notas) {
    if (_searchQuery.isEmpty) return notas;

    final query = _searchQuery.toLowerCase();
    return notas.where((nota) {
      return nota.nombreCliente.toLowerCase().contains(query) ||
          nota.direccion.toLowerCase().contains(query) ||
          nota.zona.toLowerCase().contains(query) ||
          nota.codNotaEntrega.toString().contains(query);
    }).toList();
  }

  /// Mostrar diálogo de filtro por fechas
  Future<void> _showDateFilterDialog(BuildContext context) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    DateTime? tempDesde = _fechaDesde;
    DateTime? tempHasta = _fechaHasta;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filtrar por Fechas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha desde'),
                subtitle: Text(
                  tempDesde != null
                      ? dateFormat.format(tempDesde!)
                      : 'Sin seleccionar',
                ),
                trailing: tempDesde != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setDialogState(() => tempDesde = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempDesde ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setDialogState(() => tempDesde = date);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha hasta'),
                subtitle: Text(
                  tempHasta != null
                      ? dateFormat.format(tempHasta!)
                      : 'Sin seleccionar',
                ),
                trailing: tempHasta != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setDialogState(() => tempHasta = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempHasta ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setDialogState(() => tempHasta = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setDialogState(() {
                  tempDesde = null;
                  tempHasta = null;
                });
              },
              child: const Text('Limpiar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _fechaDesde = tempDesde;
                  _fechaHasta = tempHasta;
                });
                Navigator.pop(context);
                _aplicarFiltroFechas();
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  void _aplicarFiltroFechas() {
    if (_fechaDesde != null || _fechaHasta != null) {
      ref
          .read(notaEntregaProvider.notifier)
          .cargarNotasPorFechas(
            fechaInicio: _fechaDesde,
            fechaFin: _fechaHasta,
          );
    } else {
      ref.read(notaEntregaProvider.notifier).cargarNotas();
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _fechaDesde = null;
      _fechaHasta = null;
    });
  }

  Widget _buildNotasList(BuildContext context, List<NotaEntregaEntity> notas) {
    if (notas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 120,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notas de entrega',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera nota usando el botón (+)',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notas.length,
      itemBuilder: (context, index) {
        final nota = notas[index];
        return FadeSlideAnimation(
          delay: Duration(milliseconds: 50 * (index % 10)),
          child: _buildNotaCard(context, nota),
        );
      },
    );
  }

  Widget _buildNotaCard(BuildContext context, NotaEntregaEntity nota) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isAnulada = nota.isAnulada;

    return Opacity(
      opacity: isAnulada ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isAnulada
              ? Colors.red.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAnulada
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: InkWell(
          onTap: () => _showNotaDetails(context, nota),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Código de nota
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAnulada
                            ? Colors.red.withValues(alpha: 0.2)
                            : AppTheme.accentCyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.numbers,
                            size: 16,
                            color: isAnulada ? Colors.red : AppTheme.accentCyan,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '#${nota.codNotaEntrega}',
                            style: TextStyle(
                              color: isAnulada
                                  ? Colors.red
                                  : AppTheme.accentCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Badge de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAnulada
                            ? Colors.red.withValues(alpha: 0.2)
                            : AppTheme.accentGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAnulada
                              ? Colors.red.withValues(alpha: 0.3)
                              : AppTheme.accentGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAnulada ? Icons.cancel : Icons.check_circle,
                            size: 14,
                            color: isAnulada
                                ? Colors.red
                                : AppTheme.accentGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            nota.estadoTexto,
                            style: TextStyle(
                              color: isAnulada
                                  ? Colors.red
                                  : AppTheme.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Botón de anular (solo si está válida)
                    if (!isAnulada)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: Colors.orange.shade300,
                            size: 20,
                          ),
                          onPressed: () =>
                              _showAnularConfirmation(context, nota),
                          tooltip: 'Anular nota',
                          visualDensity: VisualDensity.compact,
                        ),
                      ),

                    if (!isAnulada) const SizedBox(width: 8),

                    // Botón de PDF
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red.shade300,
                          size: 20,
                        ),
                        onPressed: () => _generarPDF(
                          context,
                          nota.codNotaEntrega,
                          nota.nombreCliente,
                        ),
                        tooltip: 'Generar PDF',
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateFormat.format(nota.fecha),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nota.nombreCliente,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: isAnulada
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (nota.direccion.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nota.direccion,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (nota.zona.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        size: 18,
                        color: AppTheme.accentCyan.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nota.zona,
                        style: TextStyle(
                          color: AppTheme.accentCyan.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (nota.nit.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 18,
                        color: AppTheme.accentGreen.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NIT: ${nota.nit}',
                        style: TextStyle(
                          color: AppTheme.accentGreen.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                if (nota.nombreEmpleado.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.badge_rounded,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vendedor: ${nota.nombreEmpleado}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mostrar confirmación para anular nota
  Future<void> _showAnularConfirmation(
    BuildContext context,
    NotaEntregaEntity nota,
  ) async {
    final navigator = Navigator.of(context);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          size: 48,
          color: Colors.orange,
        ),
        title: const Text('Anular Nota de Entrega'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de anular la nota #${nota.codNotaEntrega}?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'El stock de los artículos será devuelto automáticamente al inventario.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cliente: ${nota.nombreCliente}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cancel),
            label: const Text('Anular'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentCyan),
                  const SizedBox(height: 16),
                  const Text(
                    'Anulando nota...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      await ref.read(notaEntregaProvider.notifier).anular(nota.codNotaEntrega);

      // Cerrar loading
      navigator.pop();

      _showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nota anulada exitosamente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Stock devuelto al inventario',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      // Cerrar loading si está abierto
      navigator.pop();

      _showSnackBar(
        SnackBar(
          content: Text('Error al anular: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Método para generar y abrir el PDF de una nota de entrega
  Future<void> _generarPDF(
    BuildContext context,
    int codNotaEntrega,
    String nombreCliente,
  ) async {
    final navigator = Navigator.of(context);

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentCyan),
                  const SizedBox(height: 16),
                  const Text(
                    'Generando PDF...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final pdfBytes = await ref
          .read(notaEntregaProvider.notifier)
          .generarPDF(codNotaEntrega);

      // Cerrar dialog de carga
      navigator.pop();

      if (pdfBytes != null) {
        await _mostrarOpcionesPDF(
          context,
          pdfBytes,
          codNotaEntrega,
          nombreCliente,
        );
      } else {
        _showSnackBar(
          const SnackBar(
            content: Text('No se pudo generar el PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Cerrar dialog de carga
      navigator.pop();

      _showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Generar nombre de archivo formateado
  String _generarNombreArchivo(String nombreCliente, int codNotaEntrega) {
    // Reemplazar espacios y caracteres especiales
    final nombreFormateado = nombreCliente
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(' ', '_')
        .trim();
    return '${nombreFormateado}_#$codNotaEntrega';
  }

  /// Mostrar opciones de PDF (vista previa y compartir)
  Future<void> _mostrarOpcionesPDF(
    BuildContext context,
    Uint8List pdfBytes,
    int codNotaEntrega,
    String nombreCliente,
  ) async {
    final nombreArchivo = _generarNombreArchivo(nombreCliente, codNotaEntrega);

    final opcion = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.picture_as_pdf, size: 48, color: Colors.red[700]),
        title: const Text('PDF Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Archivo: $nombreArchivo.pdf',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('¿Qué deseas hacer con el PDF?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancelar'),
            child: const Text('Cancelar'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'compartir'),
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'vista_previa'),
            icon: const Icon(Icons.preview),
            label: const Text('Vista Previa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (opcion == 'vista_previa') {
      await _mostrarVistaPrevia(pdfBytes, nombreArchivo);
    } else if (opcion == 'compartir') {
      await _compartirPDF(pdfBytes, nombreArchivo);
    }
  }

  /// Mostrar vista previa del PDF
  Future<void> _mostrarVistaPrevia(
    Uint8List pdfBytes,
    String nombreArchivo,
  ) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: nombreArchivo,
        format: PdfPageFormat.letter,
      );
    } catch (e) {
      _showSnackBar(
        SnackBar(
          content: Text('Error al mostrar PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Compartir PDF (WhatsApp, correo, etc.)
  Future<void> _compartirPDF(Uint8List pdfBytes, String nombreArchivo) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: '$nombreArchivo.pdf');
    } catch (e) {
      _showSnackBar(
        SnackBar(
          content: Text('Error al compartir PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNotaDetails(BuildContext context, NotaEntregaEntity nota) {
    // Load detalles for this nota
    ref
        .read(detalleNotaEntregaProvider.notifier)
        .cargarDetallesPorNota(nota.codNotaEntrega);

    showDialog(
      context: context,
      builder: (context) => _NotaDetailsDialog(nota: nota),
    );
  }

  void _showCreateNotaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          const _CreateNotaDialog(),
    );
  }
}

/// Dialog para ver detalles de una nota de entrega
class _NotaDetailsDialog extends ConsumerWidget {
  final NotaEntregaEntity nota;

  const _NotaDetailsDialog({required this.nota});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detallesAsync = ref.watch(detalleNotaEntregaProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isAnulada = nota.isAnulada;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAnulada
                      ? [Colors.red.shade400, Colors.red.shade300]
                      : [
                          context.colorScheme.primaryContainer,
                          context.colorScheme.primaryContainer.withValues(
                            alpha: 0.7,
                          ),
                        ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isAnulada ? Icons.cancel : Icons.description,
                    color: isAnulada
                        ? Colors.white
                        : context.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Nota de Entrega #${nota.codNotaEntrega}',
                                style: context.theme.textTheme.titleLarge
                                    ?.copyWith(
                                      color: isAnulada
                                          ? Colors.white
                                          : context
                                                .colorScheme
                                                .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      decoration: isAnulada
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Badge de estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isAnulada
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : (nota.isValida
                                          ? Colors.green.withValues(alpha: 0.2)
                                          : Colors.grey.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                nota.estadoTexto,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isAnulada
                                      ? Colors.white
                                      : (nota.isValida
                                            ? Colors.green.shade700
                                            : Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          dateFormat.format(nota.fecha),
                          style: TextStyle(
                            color: isAnulada
                                ? Colors.white.withValues(alpha: 0.8)
                                : context.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón para generar PDF
                  IconButton(
                    icon: Icon(
                      Icons.picture_as_pdf,
                      color: isAnulada ? Colors.white : Colors.red[700],
                    ),
                    onPressed: () => _generarPDF(
                      context,
                      ref,
                      nota.codNotaEntrega,
                      nota.nombreCliente,
                    ),
                    tooltip: 'Generar PDF',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isAnulada ? Colors.white : null,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Banner de anulado
            if (isAnulada)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Colors.red.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Esta nota de entrega ha sido anulada',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Información del cliente
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Cliente'),
                    subtitle: Text(nota.nombreCliente),
                  ),
                  if (nota.nit.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('NIT'),
                      subtitle: Text(nota.nit),
                    ),
                  if (nota.zona.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: const Text('Zona'),
                      subtitle: Text(nota.zona),
                    ),
                  if (nota.direccion.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Dirección'),
                      subtitle: Text(nota.direccion),
                    ),
                  if (nota.nombreEmpleado.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.badge_rounded),
                      title: const Text('Vendedor'),
                      subtitle: Text(nota.nombreEmpleado),
                    ),
                ],
              ),
            ),

            const Divider(),

            // Detalles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Artículos',
                style: context.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: detallesAsync.when(
                data: (detalles) {
                  if (detalles.isEmpty) {
                    return const Center(
                      child: Text('No hay artículos en esta nota'),
                    );
                  }

                  double total = 0;
                  for (var detalle in detalles) {
                    total += detalle.precioTotal;
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: detalles.length,
                          itemBuilder: (context, index) {
                            final detalle = detalles[index];
                            final tieneDescuento = detalle.descuento > 0;
                            // ⭐ Usar precioConDescuento del histórico si existe, sino calcularlo
                            final precioConDesc = detalle.precioConDescuento > 0
                                ? detalle.precioConDescuento
                                : detalle.precioUnitario * (1 - detalle.descuento / 100);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(detalle.descripcionArticulo),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${detalle.codArticulo} • ${detalle.lineaArticulo}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    if (tieneDescuento) ...[
                                      Text(
                                        'Precio: Bs. ${detalle.precioUnitario.toStringAsFixed(2)} → '
                                        'Bs. ${precioConDesc.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                      ),
                                      Text(
                                        'Descuento: ${detalle.descuento.toStringAsFixed(1)}%',
                                        style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.w500),
                                      ),
                                    ] else
                                      Text(
                                        'Precio: Bs. ${detalle.precioUnitario.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                      ),
                                  ],
                                ),
                                isThreeLine: tieneDescuento,
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Cant: ${detalle.cantidad}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Bs. ${detalle.precioTotal.toStringAsFixed(2)}',
                                      style: TextStyle(color: Colors.green[700]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Total
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHighest,
                          border: Border(
                            top: BorderSide(
                              color: context.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL:',
                              style: context.theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Bs. ${total.toStringAsFixed(2)}',
                              style: context.theme.textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Error: ${error.toString()}')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método para generar y abrir el PDF de una nota de entrega
  Future<void> _generarPDF(
    BuildContext context,
    WidgetRef ref,
    int codNotaEntrega,
    String nombreCliente,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final pdfBytes = await ref
          .read(notaEntregaProvider.notifier)
          .generarPDF(codNotaEntrega);

      // Cerrar dialog de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (pdfBytes != null) {
        await _mostrarOpcionesPDF(
          context,
          pdfBytes,
          codNotaEntrega,
          nombreCliente,
          scaffoldMessenger,
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('No se pudo generar el PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Cerrar dialog de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Generar nombre de archivo formateado
  String _generarNombreArchivo(String nombreCliente, int codNotaEntrega) {
    final nombreFormateado = nombreCliente
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(' ', '_')
        .trim();
    return '${nombreFormateado}_#$codNotaEntrega';
  }

  /// Mostrar opciones de PDF (vista previa y compartir)
  Future<void> _mostrarOpcionesPDF(
    BuildContext context,
    Uint8List pdfBytes,
    int codNotaEntrega,
    String nombreCliente,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    final nombreArchivo = _generarNombreArchivo(nombreCliente, codNotaEntrega);

    final opcion = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.picture_as_pdf, size: 48, color: Colors.red[700]),
        title: const Text('PDF Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Archivo: $nombreArchivo.pdf',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('¿Qué deseas hacer con el PDF?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancelar'),
            child: const Text('Cancelar'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'compartir'),
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'vista_previa'),
            icon: const Icon(Icons.preview),
            label: const Text('Vista Previa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (opcion == 'vista_previa') {
      await _mostrarVistaPrevia(pdfBytes, nombreArchivo, scaffoldMessenger);
    } else if (opcion == 'compartir') {
      await _compartirPDF(pdfBytes, nombreArchivo, scaffoldMessenger);
    }
  }

  /// Mostrar vista previa del PDF
  Future<void> _mostrarVistaPrevia(
    Uint8List pdfBytes,
    String nombreArchivo,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: nombreArchivo,
        format: PdfPageFormat.letter,
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al mostrar PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Compartir PDF (WhatsApp, correo, etc.)
  Future<void> _compartirPDF(
    Uint8List pdfBytes,
    String nombreArchivo,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: '$nombreArchivo.pdf');
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al compartir PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Dialog para crear una nueva nota de entrega
class _CreateNotaDialog extends ConsumerStatefulWidget {
  const _CreateNotaDialog();

  @override
  ConsumerState<_CreateNotaDialog> createState() => _CreateNotaDialogState();
}

class _CreateNotaDialogState extends ConsumerState<_CreateNotaDialog> {
  final _formKey = GlobalKey<FormState>();
  ClienteEntity? _selectedCliente;
  ZonaEntity? _selectedZona;
  DateTime _selectedDate = DateTime.now();
  final _direccionController = TextEditingController();
  final List<_DetalleItem> _detalles = [];
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    AppOverlay.showMessage(context, message, isError: true);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    AppOverlay.showMessage(context, message, isSuccess: true);
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    AppOverlay.showMessage(context, message);
  }

  @override
  void initState() {
    super.initState();
    // Cargar clientes y artículos
    Future.microtask(() {
      ref.read(clienteProvider.notifier).loadClientes();
      ref.read(articuloProvider.notifier).loadArticulos();
    });
  }

  @override
  void dispose() {
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clienteProvider);
    ref.watch(isAdminProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: context.colorScheme.onPrimary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nueva Nota de Entrega',
                      style: context.theme.textTheme.titleLarge?.copyWith(
                        color: context.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: context.colorScheme.onPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cliente selector
                      Text(
                        'Información del Cliente',
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      clientesAsync.when(
                        data: (clientes) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _showClienteSearchDialog(clientes),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Cliente *',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.person),
                                  suffixIcon: const Icon(Icons.search),
                                  errorText:
                                      _selectedCliente == null &&
                                          _formKey.currentState?.validate() ==
                                              false
                                      ? 'Selecciona un cliente'
                                      : null,
                                ),
                                child: Text(
                                  _selectedCliente?.nombreCliente ??
                                      'Buscar cliente...',
                                  style: TextStyle(
                                    color: _selectedCliente == null
                                        ? Colors.grey[600]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) =>
                            const Text('Error al cargar clientes'),
                      ),

                      const SizedBox(height: 16),

                      // Fecha
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          },
                          child: const Text('Cambiar'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Zona (con ciudad)
                      ref.watch(zonaProvider).when(
                        data: (zonas) {
                          if (zonas.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: const Text('No hay zonas registradas. Crea zonas primero.'),
                            );
                          }
                          return DropdownButtonFormField<ZonaEntity>(
                            value: _selectedZona,
                            decoration: const InputDecoration(
                              labelText: 'Zona *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.map),
                            ),
                            items: zonas.map((zona) {
                              final zonaModel = zona is ZonaModel ? zona : null;
                              final ciudadLabel = zonaModel?.ciudadNombre?.isNotEmpty == true
                                  ? '${zonaModel!.ciudadNombre} — '
                                  : '';
                              return DropdownMenuItem<ZonaEntity>(
                                value: zona,
                                child: Text('$ciudadLabel${zona.zona}'),
                              );
                            }).toList(),
                            onChanged: (zona) => setState(() => _selectedZona = zona),
                            validator: (value) =>
                                value == null ? 'Selecciona una zona' : null,
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('Error al cargar zonas'),
                      ),

                      const SizedBox(height: 16),

                      // Dirección
                      TextFormField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa una dirección';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Artículos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Artículos',
                            style: context.theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddArticuloDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar'),
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (_detalles.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No hay artículos agregados',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            ..._detalles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final detalle = entry.value;
                              return _buildDetalleCard(detalle, index);
                            }),

                            const SizedBox(height: 12),

                            // Total
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL:',
                                    style: context.theme.textTheme.titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                  ),
                                  Text(
                                    'Bs. ${_calculateTotal().toStringAsFixed(2)}',
                                    style: context.theme.textTheme.titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: context.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveNota,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Guardando...' : 'Guardar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
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
  }

  Widget _buildDetalleCard(_DetalleItem detalle, int index) {
    final tieneDescuento = detalle.descuento > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(detalle.articulo.descripcion),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${detalle.articulo.codArticulo} • Bs. ${detalle.precioUnitario.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (tieneDescuento)
              Text(
                'Descuento: ${detalle.descuento.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.w500),
              ),
          ],
        ),
        isThreeLine: tieneDescuento,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editDetalle(index, detalle),
              tooltip: 'Editar',
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Cant: ${detalle.cantidad}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (tieneDescuento)
                  Text(
                    'Bs. ${detalle.totalConDescuento.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                  )
                else
                  Text(
                    'Bs. ${(detalle.cantidad * detalle.precioUnitario).toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            if (ref.read(isAdminProvider))
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _detalles.removeAt(index);
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _editDetalle(int index, _DetalleItem detalle) {
    final cantidadCtrl = TextEditingController(text: detalle.cantidad.toString());
    final descuentoCtrl = TextEditingController(text: detalle.descuento.toStringAsFixed(1));
    final stockDisponible = detalle.articulo.stockActual ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Artículo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              detalle.articulo.descripcion,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Stock disponible: $stockDisponible',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: cantidadCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
                helperText: 'Máximo: $stockDisponible',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descuentoCtrl,
              decoration: const InputDecoration(
                labelText: 'Descuento (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.discount),
                suffixText: '%',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCantidad = int.tryParse(cantidadCtrl.text) ?? 0;
              if (newCantidad <= 0) {
                _showErrorSnackBar('La cantidad debe ser mayor a 0');
                return;
              }
              if (newCantidad > stockDisponible) {
                _showErrorSnackBar(
                  'Stock insuficiente. Disponible: $stockDisponible',
                );
                return;
              }
              final newDescuento = double.tryParse(
                    descuentoCtrl.text.replaceAll(',', '.'),
                  )?.clamp(0.0, 100.0) ?? 0.0;
              setState(() {
                _detalles[index] = _DetalleItem(
                  articulo: detalle.articulo,
                  cantidad: newCantidad,
                  precioUnitario: detalle.precioUnitario,
                  descuento: newDescuento,
                );
              });
              Navigator.pop(context);
              _showInfoSnackBar('Cantidad actualizada: $newCantidad');
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    return _detalles.fold(0.0, (sum, item) => sum + item.totalConDescuento);
  }

  void _showClienteSearchDialog(List<ClienteEntity> clientes) {
    final searchController = TextEditingController();
    List<ClienteEntity> filteredClientes = clientes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Buscar Cliente',
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      filteredClientes = clientes
                          .where(
                            (c) => c.nombreCliente.toLowerCase().contains(
                              value.toLowerCase(),
                            ),
                          )
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredClientes.isEmpty
                      ? const Center(child: Text('No se encontraron clientes'))
                      : ListView.builder(
                          itemCount: filteredClientes.length,
                          itemBuilder: (context, index) {
                            final cliente = filteredClientes[index];
                            return ListTile(
                              title: Text(cliente.nombreCliente),
                              subtitle: Text(cliente.direccion),
                              onTap: () {
                                // Auto-fill zone matching the client's zone
                                final allZonas =
                                    ref.read(zonaProvider).value ?? [];
                                ZonaEntity? clienteZona;
                                try {
                                  clienteZona = allZonas.firstWhere(
                                      (z) => z.codZona == cliente.codZona);
                                } catch (_) {
                                  clienteZona = null;
                                }
                                setState(() {
                                  _selectedCliente = cliente;
                                  _direccionController.text = cliente.direccion;
                                  if (clienteZona != null) {
                                    _selectedZona = clienteZona;
                                  }
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddArticuloDialog() {
    final articulosAsync = ref.read(articuloProvider);

    articulosAsync.whenData((articulos) {
      // Filtrar solo artículos con precio válido
      final articulosConPrecio = articulos
          .where((a) => a.precioActual != null && a.precioActual! > 0)
          .toList();

      if (articulosConPrecio.isEmpty) {
        AppOverlay.showMessage(context, 'No hay artículos con precios válidos', isWarning: true);
        return;
      }

      final searchController = TextEditingController();
      List<ArticuloEntity> filteredArticulos = articulosConPrecio;
      ArticuloEntity? selectedArticulo;
      ReglaDescuentoEntity? reglaActual;
      final cantidadController = TextEditingController(text: '1');
      final descuentoController = TextEditingController(text: '0');

      void aplicarRegla(String cantidadStr, StateSetter setDs) {
        final cantidad = int.tryParse(cantidadStr) ?? 0;
        if (reglaActual != null && cantidad >= reglaActual!.cantidadMinima) {
          descuentoController.text = reglaActual!.descuento.toStringAsFixed(1);
        } else {
          descuentoController.text = '0';
        }
        setDs(() {});
      }

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_shopping_cart,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Agregar Artículo',
                            style: context.theme.textTheme.titleLarge?.copyWith(
                              color: context.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search field
                          TextField(
                            controller: searchController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Buscar artículo...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                filteredArticulos = articulosConPrecio
                                    .where(
                                      (a) =>
                                          a.descripcion.toLowerCase().contains(
                                            value.toLowerCase(),
                                          ) ||
                                          (a.codArticulo ?? '')
                                              .toLowerCase()
                                              .contains(value.toLowerCase()),
                                    )
                                    .toList();
                                selectedArticulo = null;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Articles list
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: filteredArticulos.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No se encontraron artículos',
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredArticulos.length,
                                      itemBuilder: (context, index) {
                                        final articulo =
                                            filteredArticulos[index];
                                        final isSelected =
                                            selectedArticulo == articulo;
                                        final stockDisponible =
                                            articulo.stockActual ?? 0;
                                        final sinStock = stockDisponible <= 0;
                                        return ListTile(
                                          selected: isSelected,
                                          selectedTileColor: context
                                              .colorScheme
                                              .primaryContainer
                                              .withValues(alpha: 0.3),
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  articulo.descripcion,
                                                  style: TextStyle(
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: sinStock
                                                        ? Colors.grey
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: sinStock
                                                      ? Colors.red[100]
                                                      : Colors.green[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Stock: $stockDisponible',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: sinStock
                                                        ? Colors.red[700]
                                                        : Colors.green[700],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            '${articulo.codArticulo} • Precio: Bs. ${articulo.precioActual!.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: sinStock
                                                  ? Colors.grey
                                                  : null,
                                            ),
                                          ),
                                          trailing: isSelected
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: context
                                                      .colorScheme
                                                      .primary,
                                                )
                                              : null,
                                          onTap: () async {
                                            setDialogState(() {
                                              selectedArticulo = articulo;
                                              reglaActual = null;
                                              descuentoController.text = '0';
                                            });
                                            final regla = await ref.read(
                                              reglaDescuentoPorArticuloProvider(
                                                      articulo.codArticulo!)
                                                  .future,
                                            );
                                            aplicarRegla(cantidadController.text,
                                                setDialogState);
                                            setDialogState(() {
                                              reglaActual = regla;
                                              aplicarRegla(cantidadController.text,
                                                  setDialogState);
                                            });
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Cantidad field
                          TextFormField(
                            controller: cantidadController,
                            decoration: InputDecoration(
                              labelText: 'Cantidad *',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.numbers),
                              helperText: reglaActual != null
                                  ? 'Mínimo ${reglaActual!.cantidadMinima} unidades para ${reglaActual!.descuento.toStringAsFixed(1)}% desc.'
                                  : null,
                              helperStyle: const TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.w500),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                aplicarRegla(v, setDialogState),
                          ),

                          const SizedBox(height: 12),

                          // Descuento field (read-only, controlado por regla)
                          TextFormField(
                            controller: descuentoController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Descuento (%)',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.discount),
                              suffixText: '%',
                              filled: reglaActual != null,
                              fillColor: Colors.green.withValues(alpha: 0.07),
                              helperText: reglaActual == null
                                  ? 'Sin regla de descuento para este artículo'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: selectedArticulo == null
                              ? null
                              : () {
                                  final cantidad =
                                      int.tryParse(cantidadController.text) ??
                                      1;
                                  if (cantidad <= 0) {
                                    _showErrorSnackBar(
                                      'La cantidad debe ser mayor a 0',
                                    );
                                    return;
                                  }

                                  // Validar stock disponible
                                  final stockDisponible =
                                      selectedArticulo!.stockActual ?? 0;

                                  // Verificar si el artículo ya existe y calcular cantidad total
                                  final existingIndex = _detalles.indexWhere(
                                    (d) =>
                                        d.articulo.codArticulo ==
                                        selectedArticulo!.codArticulo,
                                  );

                                  final cantidadExistente = existingIndex >= 0
                                      ? _detalles[existingIndex].cantidad
                                      : 0;
                                  final cantidadTotal =
                                      cantidadExistente + cantidad;

                                  // Validar que la cantidad total no exceda el stock
                                  if (cantidadTotal > stockDisponible) {
                                    _showErrorSnackBar(
                                      'Stock insuficiente. Disponible: $stockDisponible, Solicitado: $cantidadTotal',
                                    );
                                    return;
                                  }

                                  String? mensajeActualizacion;

                                  final descuento = double.tryParse(
                                        descuentoController.text.replaceAll(',', '.'),
                                      )?.clamp(0.0, 100.0) ?? 0.0;

                                  setState(() {
                                    if (existingIndex >= 0) {
                                      // Si existe, sumar la cantidad
                                      _detalles[existingIndex] = _DetalleItem(
                                        articulo:
                                            _detalles[existingIndex].articulo,
                                        cantidad: cantidadTotal,
                                        precioUnitario: _detalles[existingIndex]
                                            .precioUnitario,
                                        descuento: descuento,
                                      );
                                      mensajeActualizacion =
                                          'Cantidad actualizada: $cantidadTotal';
                                    } else {
                                      // Si no existe, agregar nuevo
                                      _detalles.add(
                                        _DetalleItem(
                                          articulo: selectedArticulo!,
                                          cantidad: cantidad,
                                          precioUnitario:
                                              selectedArticulo!.precioActual!,
                                          descuento: descuento,
                                        ),
                                      );
                                    }
                                  });

                                  Navigator.pop(context);

                                  // Mostrar SnackBar después de cerrar el diálogo
                                  if (mensajeActualizacion != null) {
                                    _showInfoSnackBar(mensajeActualizacion!);
                                  }
                                },
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
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
    });
  }

  Future<void> _saveNota() async {
    if (!_formKey.currentState!.validate() || _selectedCliente == null) {
      return;
    }

    if (_detalles.isEmpty) {
      _showErrorSnackBar('Agrega al menos un artículo');
      return;
    }

    // Validar stock de todos los artículos antes de continuar
    final articulosSinStock = <String>[];
    for (var detalle in _detalles) {
      final stockDisponible = detalle.articulo.stockActual ?? 0;
      if (detalle.cantidad > stockDisponible) {
        articulosSinStock.add(
          '${detalle.articulo.descripcion} (Solicitado: ${detalle.cantidad}, Disponible: $stockDisponible)',
        );
      }
    }

    if (articulosSinStock.isNotEmpty) {
      _showErrorSnackBar('Stock insuficiente: ${articulosSinStock.first}');
      // Mostrar diálogo con todos los artículos sin stock
      await _mostrarArticulosSinStock(articulosSinStock);
      return;
    }

    // Mostrar vista previa antes de guardar
    final confirmed = await _showPreviewDialog();
    if (confirmed != true) {
      return;
    }

    // Guardar referencia al Navigator ANTES de cerrar el diálogo
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      // Crear nota de entrega
      // ⭐ Ahora incluye el NIT del cliente (snapshot histórico)
      final nota = NotaEntregaEntity(
        codNotaEntrega: 0,
        codCliente: _selectedCliente!.codCliente,
        nombreCliente: _selectedCliente!.nombreCliente,
        fecha: _selectedDate,
        direccion: _direccionController.text,
        zona: _selectedZona?.zona ?? '',
        nit: _selectedCliente!.nit,
        audUsuario: 0,
      );

      final resultNota = await ref
          .read(notaEntregaProvider.notifier)
          .crear(nota);

      if (resultNota != null) {
        // Crear todos los detalles
        // ⭐ Ahora se envía precioConDescuento (precio unitario con descuento) como snapshot histórico
        for (var detalle in _detalles) {
          final detalleEntity = DetalleNotaEntregaEntity(
            codDetalle: 0,
            codNotaEntrega: resultNota.data.codNotaEntrega,
            codArticulo: detalle.articulo.codArticulo ?? '',
            descripcionArticulo: detalle.articulo.descripcion,
            descripcion2Articulo: detalle.articulo.descripcion2,
            lineaArticulo: detalle.articulo.linea ?? '',
            codLinea: detalle.articulo.codLinea,
            cantidad: detalle.cantidad,
            precioUnitario: detalle.precioUnitario,
            precioTotal: detalle.totalConDescuento,
            precioSinFactura: detalle.precioSinFacturaConDescuento,
            descuento: detalle.descuento,
            precioConDescuento: detalle.precioConDescuento,
            audUsuario: 0,
          );

          await ref
              .read(detalleNotaEntregaProvider.notifier)
              .crear(resultNota.data.codNotaEntrega, detalleEntity);
        }

        // Cerrar el diálogo primero
        navigator.pop();

        // Mostrar resultado exitoso
        _showSuccessSnackBar('Nota de entrega creada exitosamente');

        // Preguntar si desea generar el PDF
        await _preguntarGenerarPDF(
          resultNota.data.codNotaEntrega,
          _selectedCliente!.nombreCliente,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Mostrar diálogo con artículos sin stock suficiente
  Future<void> _mostrarArticulosSinStock(List<String> articulos) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          size: 48,
          color: Colors.orange[700],
        ),
        title: const Text('Stock Insuficiente'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Los siguientes artículos no tienen stock suficiente:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: articulos.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red[400], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            articulos[index],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Preguntar al usuario si desea generar el PDF de la nota de entrega
  Future<void> _preguntarGenerarPDF(
    int codNotaEntrega,
    String nombreCliente,
  ) async {
    final scaffoldContext = context;

    final generarPDF = await showDialog<bool>(
      context: scaffoldContext,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.picture_as_pdf, size: 48, color: Colors.red[700]),
        title: const Text('Generar PDF'),
        content: const Text(
          '¿Deseas generar el PDF de la nota de entrega ahora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, después'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Sí, generar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (generarPDF == true && scaffoldContext.mounted) {
      await _generarPDF(scaffoldContext, codNotaEntrega, nombreCliente);
    }
  }

  /// Método para generar y abrir el PDF de una nota de entrega
  Future<void> _generarPDF(
    BuildContext context,
    int codNotaEntrega,
    String nombreCliente,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final pdfBytes = await ref
          .read(notaEntregaProvider.notifier)
          .generarPDF(codNotaEntrega);

      // Cerrar dialog de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (pdfBytes != null) {
        await _mostrarOpcionesPDF(
          context,
          pdfBytes,
          codNotaEntrega,
          nombreCliente,
          scaffoldMessenger,
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('No se pudo generar el PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Cerrar dialog de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Generar nombre de archivo formateado
  String _generarNombreArchivo(String nombreCliente, int codNotaEntrega) {
    final nombreFormateado = nombreCliente
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(' ', '_')
        .trim();
    return '${nombreFormateado}_#$codNotaEntrega';
  }

  /// Mostrar opciones de PDF (vista previa y compartir)
  Future<void> _mostrarOpcionesPDF(
    BuildContext context,
    Uint8List pdfBytes,
    int codNotaEntrega,
    String nombreCliente,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    final nombreArchivo = _generarNombreArchivo(nombreCliente, codNotaEntrega);

    final opcion = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.picture_as_pdf, size: 48, color: Colors.red[700]),
        title: const Text('PDF Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Archivo: $nombreArchivo.pdf',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('¿Qué deseas hacer con el PDF?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancelar'),
            child: const Text('Cancelar'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'compartir'),
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'vista_previa'),
            icon: const Icon(Icons.preview),
            label: const Text('Vista Previa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (opcion == 'vista_previa') {
      await _mostrarVistaPrevia(pdfBytes, nombreArchivo, scaffoldMessenger);
    } else if (opcion == 'compartir') {
      await _compartirPDF(pdfBytes, nombreArchivo, scaffoldMessenger);
    }
  }

  /// Mostrar vista previa del PDF
  Future<void> _mostrarVistaPrevia(
    Uint8List pdfBytes,
    String nombreArchivo,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: nombreArchivo,
        format: PdfPageFormat.letter,
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al mostrar PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Compartir PDF (WhatsApp, correo, etc.)
  Future<void> _compartirPDF(
    Uint8List pdfBytes,
    String nombreArchivo,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: '$nombreArchivo.pdf');
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al compartir PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showPreviewDialog() async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final total = _calculateTotal();

    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.screenWidth > 600
                ? 600
                : context.screenWidth - 32,
            maxHeight: context.screenHeight - 100,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[500]!],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.preview, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Vista Previa - Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cliente info
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.blue[300],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'CLIENTE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 1.0,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(height: 12, color: Colors.white.withValues(alpha: 0.15)),
                              Text(
                                _selectedCliente!.nombreCliente,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      dateFormat.format(_selectedDate),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _direccionController.text,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Detalles
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Colors.blue[300],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ARTÍCULOS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.0,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ..._detalles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final detalle = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      context.colorScheme.primaryContainer,
                                  radius: 16,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: context
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detalle.articulo.descripcion,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        detalle.articulo.codArticulo ?? '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.55),
                                        ),
                                      ),
                                      Text(
                                        'Bs. ${detalle.precioUnitario.toStringAsFixed(2)} × ${detalle.cantidad}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Cant: ${detalle.cantidad}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Bs. ${(detalle.cantidad * detalle.precioUnitario).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppTheme.accentGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // Total
                      Card(
                        elevation: 4,
                        color: AppTheme.accentGreen.withValues(alpha: 0.15),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: AppTheme.accentGreen,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'TOTAL',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Text(
                                  'Bs. ${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentGreen,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text(
                          'Confirmar y Guardar',
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
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
    );
  }
}

/// Clase auxiliar para manejar detalles temporales
class _DetalleItem {
  final ArticuloEntity articulo;
  final int cantidad;
  final double precioUnitario;
  final double descuento;

  _DetalleItem({
    required this.articulo,
    required this.cantidad,
    required this.precioUnitario,
    this.descuento = 0,
  });

  double get precioConDescuento => precioUnitario * (1 - descuento / 100);
  double get totalConDescuento => cantidad * precioConDescuento;
  double get precioSinFacturaConDescuento =>
      (articulo.precioSinFactura ?? precioUnitario) * (1 - descuento / 100);
}
