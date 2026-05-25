
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:yahveh/core/utils/error_messages.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/entities/venta_reporte_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../providers/reporte_ventas_provider.dart';
import '../widgets/app_drawer.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  DateTime _fechaDesde = DateTime.now().subtract(const Duration(days: 365));
  DateTime _fechaHasta = DateTime.now();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isDownloadingPdf = false;

  DateTime _vendDesde = DateTime.now().subtract(const Duration(days: 365));
  DateTime _vendHasta = DateTime.now();
  bool _isDownloadingVend = false;
  int? _selectedEmpleadoId; // null = todos los empleados

  DateTime _invDesde = DateTime.now().subtract(const Duration(days: 365));
  DateTime _invHasta = DateTime.now();
  bool _isDownloadingInv = false;

  // ⭐ Reporte de movimientos de inventario
  DateTime _movDesde = DateTime.now().subtract(const Duration(days: 30));
  DateTime _movHasta = DateTime.now();
  final TextEditingController _movArticuloCtrl = TextEditingController();
  bool _isDownloadingMov = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarReporte();
      // Precargar empleados (vienen con nombre completo embebido del backend)
      final isAdmin = ref.read(isAdminProvider);
      if (isAdmin) {
        ref.read(empleadoProvider.notifier).cargarEmpleados();
      }
    });
  }

  @override
  void dispose() {
    _movArticuloCtrl.dispose();
    super.dispose();
  }

  void _buscarReporte() {
    ref.read(reporteVentasProvider.notifier)
        .obtenerReporte(fechaDesde: _fechaDesde, fechaHasta: _fechaHasta);
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial,
      {DateTime? firstDate}) async {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accentCyan,
            surface: AppTheme.cardSurfaceLight,
            onSurface: Colors.white,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppTheme.cardSurface),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _selectFechaDesde() async {
    final p = await _pickDate(context, _fechaDesde);
    if (p != null) setState(() => _fechaDesde = p);
  }

  Future<void> _selectFechaHasta() async {
    final p = await _pickDate(context, _fechaHasta, firstDate: _fechaDesde);
    if (p != null) setState(() => _fechaHasta = p);
  }

  void _showPdfResult(dynamic e, {bool isNoData = false}) {
    if (!mounted) return;
    final msg = e?.toString().toLowerCase() ?? '';
    final noData = isNoData ||
        msg.contains('no hay datos') ||
        msg.contains('no hay artículos') ||
        msg.contains('no hay resultados') ||
        msg.contains('no hay información') ||
        msg.contains('período seleccionado');

    AppOverlay.showMessage(
      context,
      noData ? 'No hay resultados para el período seleccionado' : 'Error al generar el PDF',
      isWarning: noData,
      isError: !noData,
    );
  }

  Future<void> _descargarPdf() async {
    setState(() => _isDownloadingPdf = true);
    try {
      final pdfBytes = await ref.read(reporteVentasProvider.notifier).descargarPdf();
      if (pdfBytes != null && mounted) await _mostrarOpcionesPDF(context, pdfBytes);
    } catch (e) {
      console('Error PDF ventas: $e');
      _showPdfResult(e);
    } finally {
      if (mounted) setState(() => _isDownloadingPdf = false);
    }
  }

  Future<void> _descargarVendedoresPdf() async {
    setState(() => _isDownloadingVend = true);
    try {
      final pdfBytes = await ref
          .read(reporteVentasProvider.notifier)
          .descargarVendedoresPdf(
            fechaDesde: _vendDesde,
            fechaHasta: _vendHasta,
            codEmpleado: _selectedEmpleadoId, // null = todos
          );
      if (pdfBytes != null && mounted) {
        final suffix = _selectedEmpleadoId != null
            ? '_emp${_selectedEmpleadoId}'
            : '';
        await _mostrarOpcionesPDF(
          context,
          pdfBytes,
          'reporte_vendedores${suffix}_${DateFormat('yyyyMMdd').format(_vendDesde)}_${DateFormat('yyyyMMdd').format(_vendHasta)}',
        );
      }
    } catch (e) {
      _showPdfResult(e);
    } finally {
      if (mounted) setState(() => _isDownloadingVend = false);
    }
  }

  /// ⭐ Descargar reporte de movimientos de inventario
  Future<void> _descargarMovimientosPdf() async {
    setState(() => _isDownloadingMov = true);
    try {
      final codArt = _movArticuloCtrl.text.trim();
      final pdfBytes = await ref
          .read(reporteVentasProvider.notifier)
          .descargarMovimientosInventarioPdf(
            fechaDesde: _movDesde,
            fechaHasta: _movHasta,
            codArticulo: codArt.isEmpty ? null : codArt,
          );
      if (pdfBytes != null && mounted) {
        final suffix = codArt.isNotEmpty ? '_$codArt' : '';
        await _mostrarOpcionesPDF(
          context,
          pdfBytes,
          'movimientos_inventario${suffix}_${DateFormat('yyyyMMdd').format(_movDesde)}_${DateFormat('yyyyMMdd').format(_movHasta)}',
        );
      }
    } catch (e) {
      _showPdfResult(e);
    } finally {
      if (mounted) setState(() => _isDownloadingMov = false);
    }
  }

  Future<void> _descargarInventarioPdf() async {
    setState(() => _isDownloadingInv = true);
    try {
      final pdfBytes = await ref
          .read(reporteVentasProvider.notifier)
          .descargarInventarioPdf(fechaDesde: _invDesde, fechaHasta: _invHasta);
      if (pdfBytes != null && mounted) {
        await _mostrarOpcionesPDF(
          context,
          pdfBytes,
          'reporte_inventario_${DateFormat('yyyyMMdd').format(_invDesde)}_${DateFormat('yyyyMMdd').format(_invHasta)}',
        );
      }
    } catch (e) {
      _showPdfResult(e);
    } finally {
      if (mounted) setState(() => _isDownloadingInv = false);
    }
  }

  String _generarNombreArchivo() {
    final desde = DateFormat('yyyyMMdd').format(_fechaDesde);
    final hasta = DateFormat('yyyyMMdd').format(_fechaHasta);
    return 'reporte_ventas_${desde}_$hasta';
  }

  Future<void> _mostrarOpcionesPDF(
    BuildContext context,
    Uint8List pdfBytes, [
    String? nombreArchivo,
  ]) async {
    nombreArchivo ??= _generarNombreArchivo();
    final opcion = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[700]!.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.picture_as_pdf_rounded, size: 40, color: Colors.red[400]),
        ),
        title: const Text('PDF generado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$nombreArchivo.pdf',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          const SizedBox(height: 8),
          Text('¿Qué deseas hacer?',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'compartir'),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Compartir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentCyan,
              side: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.5)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'vista_previa'),
            icon: const Icon(Icons.visibility_rounded, size: 16),
            label: const Text('Ver PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
    if (opcion == 'vista_previa') await _mostrarVistaPrevia(pdfBytes, nombreArchivo);
    else if (opcion == 'compartir') await _compartirPDF(pdfBytes, nombreArchivo);
  }

  Future<void> _mostrarVistaPrevia(Uint8List pdfBytes, String nombreArchivo) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: nombreArchivo,
        format: PdfPageFormat.letter,
      );
    } catch (e) {
      _showPdfResult(e);
    }
  }

  Future<void> _compartirPDF(Uint8List pdfBytes, String nombreArchivo) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: '$nombreArchivo.pdf');
    } catch (e) {
      _showPdfResult(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reporteState = ref.watch(reporteVentasProvider);
    final isMobile = context.isMobile;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Reportes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _buscarReporte,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: isMobile ? _buildBlurredDrawer() : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Row(
          children: [
            if (!isMobile) _buildPermanentDrawer(),
            Expanded(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildVentasCard(context, reporteState, isMobile),
                          if (isAdmin) ...[
                            const SizedBox(height: 12),
                            _buildAdminCards(context, isMobile),
                          ],
                          const SizedBox(height: 16),
                          _buildContent(context, reporteState),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── VENTAS SECTION ────────────────────────────────────────────────────────

  Widget _buildVentasCard(BuildContext context, ReporteVentasState reporteState, bool isMobile) {
    return _buildSectionCard(
      color: AppTheme.accentCyan,
      icon: Icons.bar_chart_rounded,
      title: 'Reporte de Ventas',
      subtitle: 'Detalle de ventas por artículo y cliente',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (isMobile) ...[
          _buildDateButton(label: 'Desde', date: _fechaDesde, onTap: _selectFechaDesde),
          const SizedBox(height: 8),
          _buildDateButton(label: 'Hasta', date: _fechaHasta, onTap: _selectFechaHasta),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _buildActionButton(
                label: 'Buscar',
                icon: Icons.search_rounded,
                color: AppTheme.accentCyan,
                onTap: _buscarReporte,
              ),
            ),
            if (reporteState.hasData) ...[
              const SizedBox(width: 8),
              _buildActionButton(
                label: _isDownloadingPdf ? '...' : 'PDF',
                icon: Icons.picture_as_pdf_rounded,
                color: Colors.red[600]!,
                onTap: _isDownloadingPdf ? null : _descargarPdf,
                isLoading: _isDownloadingPdf,
                compact: true,
              ),
            ],
          ]),
        ] else Row(children: [
          Expanded(child: _buildDateButton(label: 'Desde', date: _fechaDesde, onTap: _selectFechaDesde)),
          const SizedBox(width: 10),
          Expanded(child: _buildDateButton(label: 'Hasta', date: _fechaHasta, onTap: _selectFechaHasta)),
          const SizedBox(width: 10),
          _buildActionButton(label: 'Buscar', icon: Icons.search_rounded, color: AppTheme.accentCyan, onTap: _buscarReporte),
          if (reporteState.hasData) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              label: _isDownloadingPdf ? 'Generando...' : 'PDF',
              icon: Icons.picture_as_pdf_rounded,
              color: Colors.red[600]!,
              onTap: _isDownloadingPdf ? null : _descargarPdf,
              isLoading: _isDownloadingPdf,
            ),
          ],
        ]),
      ]),
    );
  }

  // ─── ADMIN CARDS ────────────────────────────────────────────────────────────

  Widget _buildAdminCards(BuildContext context, bool isMobile) {
    final vendCard = _buildSectionCard(
      color: AppTheme.accentCyan,
      icon: Icons.people_alt_rounded,
      title: 'Por Vendedor',
      subtitle: 'General o filtrado por empleado',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: _buildDateButton(label: 'Desde', date: _vendDesde, onTap: () async {
            final p = await _pickDate(context, _vendDesde);
            if (p != null) setState(() => _vendDesde = p);
          })),
          const SizedBox(width: 8),
          Expanded(child: _buildDateButton(label: 'Hasta', date: _vendHasta, onTap: () async {
            final p = await _pickDate(context, _vendHasta, firstDate: _vendDesde);
            if (p != null) setState(() => _vendHasta = p);
          })),
        ]),
        const SizedBox(height: 10),
        // ⭐ Selector de empleado (admin)
        _buildEmpleadoDropdown(),
        const SizedBox(height: 10),
        _buildActionButton(
          label: _isDownloadingVend ? 'Generando...' : 'Descargar PDF',
          icon: Icons.picture_as_pdf_rounded,
          color: AppTheme.accentCyan,
          onTap: _isDownloadingVend ? null : _descargarVendedoresPdf,
          isLoading: _isDownloadingVend,
          fullWidth: true,
        ),
      ]),
    );

    final invCard = _buildSectionCard(
      color: AppTheme.accentGreen,
      icon: Icons.inventory_2_rounded,
      title: 'Inventario (Stock)',
      subtitle: 'Artículos con entradas, salidas y stock',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: _buildDateButton(label: 'Desde', date: _invDesde, onTap: () async {
            final p = await _pickDate(context, _invDesde);
            if (p != null) setState(() => _invDesde = p);
          })),
          const SizedBox(width: 8),
          Expanded(child: _buildDateButton(label: 'Hasta', date: _invHasta, onTap: () async {
            final p = await _pickDate(context, _invHasta, firstDate: _invDesde);
            if (p != null) setState(() => _invHasta = p);
          })),
        ]),
        const SizedBox(height: 10),
        _buildActionButton(
          label: _isDownloadingInv ? 'Generando...' : 'Descargar PDF',
          icon: Icons.picture_as_pdf_rounded,
          color: AppTheme.accentGreen,
          onTap: _isDownloadingInv ? null : _descargarInventarioPdf,
          isLoading: _isDownloadingInv,
          fullWidth: true,
        ),
      ]),
    );

    // ⭐ Card de movimientos de inventario entre fechas
    final movCard = _buildSectionCard(
      color: AppTheme.accentOrange,
      icon: Icons.swap_horiz_rounded,
      title: 'Movimientos de Inventario',
      subtitle: 'Entradas, salidas y ajustes entre fechas',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: _buildDateButton(label: 'Desde', date: _movDesde, onTap: () async {
            final p = await _pickDate(context, _movDesde);
            if (p != null) setState(() => _movDesde = p);
          })),
          const SizedBox(width: 8),
          Expanded(child: _buildDateButton(label: 'Hasta', date: _movHasta, onTap: () async {
            final p = await _pickDate(context, _movHasta, firstDate: _movDesde);
            if (p != null) setState(() => _movHasta = p);
          })),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _movArticuloCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Código de artículo (opcional)',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            prefixIcon: Icon(Icons.qr_code_rounded,
                color: AppTheme.accentOrange.withValues(alpha: 0.7), size: 18),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.accentOrange, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          label: _isDownloadingMov ? 'Generando...' : 'Descargar PDF',
          icon: Icons.picture_as_pdf_rounded,
          color: AppTheme.accentOrange,
          onTap: _isDownloadingMov ? null : _descargarMovimientosPdf,
          isLoading: _isDownloadingMov,
          fullWidth: true,
        ),
      ]),
    );

    if (isMobile) {
      return Column(children: [
        vendCard,
        const SizedBox(height: 12),
        invCard,
        const SizedBox(height: 12),
        movCard,
      ]);
    }
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: vendCard),
        const SizedBox(width: 12),
        Expanded(child: invCard),
      ]),
      const SizedBox(height: 12),
      movCard,
    ]);
  }

  /// ⭐ Dropdown de empleados. "Todos" = null = sin filtro.
  /// Usa el nombre completo embebido en EmpleadoEntity (viene del backend).
  Widget _buildEmpleadoDropdown() {
    final empleadosAsync = ref.watch(empleadoProvider);

    return empleadosAsync.when(
      data: (empleados) {
        // ⭐ Asegurar que el valor seleccionado siga siendo válido.
        // Si no lo es, lo "limpiamos" en el siguiente frame (no en build).
        final valoresValidos = <int?>{null, ...empleados.map((e) => e.codEmpleado)};
        final selectedValue = valoresValidos.contains(_selectedEmpleadoId)
            ? _selectedEmpleadoId
            : null;
        if (selectedValue != _selectedEmpleadoId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedEmpleadoId = selectedValue);
          });
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            Icon(Icons.person_outline_rounded,
                color: AppTheme.accentCyan, size: 18),
            const SizedBox(width: 8),
            Text(
              'Empleado:',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  // Usar el valor saneado para evitar crash si la lista cambia
                  value: selectedValue,
                  isExpanded: true,
                  dropdownColor: AppTheme.cardSurface,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  iconEnabledColor: Colors.white.withValues(alpha: 0.7),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'Todos los vendedores',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...empleados.map(
                      (e) => DropdownMenuItem<int?>(
                        value: e.codEmpleado,
                        child: Text(e.displayName,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedEmpleadoId = v),
                ),
              ),
            ),
          ]),
        );
      },
      loading: () => Container(
        height: 44,
        alignment: Alignment.center,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppTheme.accentCyan.withValues(alpha: 0.7)),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'No se pudo cargar la lista de empleados',
          style: TextStyle(color: Colors.red.shade300, fontSize: 12),
        ),
      ),
    );
  }

  // ─── SHARED UI COMPONENTS ───────────────────────────────────────────────────

  Widget _buildSectionCard({
    required Color color,
    required IconData icon,
    required String title,
    required Widget child,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.15))),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: child,
        ),
      ]),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded, color: AppTheme.accentCyan, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
              Text(_dateFormat.format(date), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
          ),
          Icon(Icons.expand_more_rounded, color: Colors.white.withValues(alpha: 0.4), size: 18),
        ]),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
    bool fullWidth = false,
    bool compact = false,
  }) {
    final btn = ElevatedButton.icon(
      onPressed: onTap,
      icon: isLoading
          ? SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withValues(alpha: 0.8)),
            )
          : Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        backgroundColor: onTap == null ? color.withValues(alpha: 0.4) : color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: 12,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  // ─── DRAWERS ────────────────────────────────────────────────────────────────

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

  Widget _buildPermanentDrawer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
    );
  }

  // ─── CONTENT STATES ─────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, ReporteVentasState state) {
    if (state.isLoading) return _buildLoadingState();
    if (state.error != null) return _buildErrorState(context, state.error!);
    if (!state.hasData) return _buildEmptyState();
    return ResponsiveLayout(
      mobile: _buildMobileList(context, state),
      tablet: _buildDataTable(context, state),
      desktop: _buildDataTable(context, state),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan.withValues(alpha: 0.8)),
          ),
        ),
        const SizedBox(height: 16),
        Text('Cargando reporte...',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(Icons.insert_chart_outlined_rounded,
              size: 36, color: Colors.white.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 20),
        Text('Sin datos para mostrar',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Selecciona un rango de fechas y presiona Buscar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13)),
      ]),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded, size: 36, color: Colors.redAccent),
        ),
        const SizedBox(height: 20),
        const Text('Error al cargar el reporte',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _buscarReporte,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    );
  }

  // ─── DATA DISPLAY ───────────────────────────────────────────────────────────

  Widget _buildMobileList(BuildContext context, ReporteVentasState state) {
    final detalles = state.detalles;
    final total = state.total;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: detalles.length + (total != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == detalles.length && total != null) return _buildTotalCard(total);
        return _buildVentaCard(detalles[index]);
      },
    );
  }

  Widget _buildVentaCard(VentaReporteEntity venta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              venta.nombreCliente ?? 'Sin cliente',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
            ),
            child: Text(venta.fecha ?? '',
                style: TextStyle(color: AppTheme.accentCyan, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(venta.productoCompleto ?? 'Sin producto',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
        const SizedBox(height: 10),
        Row(children: [
          _buildChip(Icons.category_rounded, venta.lineaArticulo ?? '-'),
          const SizedBox(width: 6),
          _buildChip(Icons.shopping_cart_rounded, '${venta.cantidad ?? 0} uds'),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _buildMoneyCol('P. Unit.', venta.formatMoney(venta.precioUnitario), Colors.white),
          _buildMoneyCol('Desc.', venta.descuentoPorcentaje, Colors.orange.shade300),
          _buildMoneyCol('Total Bs.', venta.formatMoney(venta.totalGeneralBs), Colors.green.shade300, bold: true),
        ]),
      ]),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
      ]),
    );
  }

  Widget _buildMoneyCol(String label, String value, Color valueColor, {bool bold = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
    ]);
  }

  Widget _buildTotalCard(VentaReporteEntity total) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.accentCyan.withValues(alpha: 0.2),
          AppTheme.primaryColor.withValues(alpha: 0.2),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.summarize_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('TOTAL GENERAL',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Desc: ${total.formatMoney(total.totalBsDesc)}',
              style: TextStyle(color: Colors.orange.shade300, fontSize: 11)),
          Text(total.formatMoney(total.totalGeneralBs),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }

  // flex weights — sum = 100
  static const _colFlex = [11, 18, 26, 13, 6, 12, 7, 14];

  Widget _buildDataTable(BuildContext context, ReporteVentasState state) {
    final detalles = state.detalles;
    final total = state.total;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(children: [
        // ── Header ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            _hCell('Fecha',     _colFlex[0]),
            _hCell('Cliente',   _colFlex[1]),
            _hCell('Producto',  _colFlex[2]),
            _hCell('Línea',     _colFlex[3]),
            _hCell('Cant.',     _colFlex[4], right: true),
            _hCell('P. Unit.',  _colFlex[5], right: true),
            _hCell('Desc.',     _colFlex[6], right: true),
            _hCell('Total Bs.', _colFlex[7], right: true),
          ]),
        ),

        // ── Rows ──────────────────────────────────────────────
        ...detalles.asMap().entries.map((e) {
          final even = e.key.isEven;
          return _buildFlexRow(e.value, even);
        }),

        // ── Total ─────────────────────────────────────────────
        if (total != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: _buildTotalCard(total),
          ),
      ]),
    );
  }

  Widget _hCell(String text, int flex, {bool right = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.65),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildFlexRow(VentaReporteEntity v, bool even) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: even ? Colors.transparent : Colors.white.withValues(alpha: 0.03),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(children: [
        _dCell(v.fecha ?? '-',                    _colFlex[0]),
        _dCell(v.nombreCliente ?? '-',            _colFlex[1]),
        _dCell(v.productoCompleto ?? '-',         _colFlex[2]),
        _dCell(v.lineaArticulo ?? '-',            _colFlex[3]),
        _dCell('${v.cantidad ?? 0}',              _colFlex[4], right: true),
        _dCell(v.formatMoney(v.precioUnitario),   _colFlex[5], right: true),
        _dCell(v.descuentoPorcentaje,             _colFlex[6], right: true, color: Colors.orange.shade300),
        _dCell(v.formatMoney(v.totalGeneralBs),   _colFlex[7], right: true,
            color: Colors.green.shade300, bold: true),
      ]),
    );
  }

  Widget _dCell(String text, int flex,
      {bool right = false, Color? color, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(left: right ? 4 : 0, right: right ? 0 : 6),
        child: Text(
          text,
          textAlign: right ? TextAlign.right : TextAlign.left,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color ?? Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  static const _headerStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12);
  static const _cellStyle = TextStyle(color: Colors.white, fontSize: 12);
}
