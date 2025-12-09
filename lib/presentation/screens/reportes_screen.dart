
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:yahveh/core/utils/error_messages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/entities/venta_reporte_entity.dart';
import '../providers/reporte_ventas_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Reportes de Ventas
class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  DateTime _fechaDesde = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaHasta = DateTime.now();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isDownloadingPdf = false;

  @override
  void initState() {
    super.initState();
    // Cargar reporte inicial con el último mes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarReporte();
    });
  }

  void _buscarReporte() {
    ref
        .read(reporteVentasProvider.notifier)
        .obtenerReporte(fechaDesde: _fechaDesde, fechaHasta: _fechaHasta);
  }

  Future<void> _selectFechaDesde() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaDesde,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => _buildDatePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _fechaDesde = picked);
    }
  }

  Future<void> _selectFechaHasta() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaHasta,
      firstDate: _fechaDesde,
      lastDate: DateTime.now(),
      builder: (context, child) => _buildDatePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _fechaHasta = picked);
    }
  }

  Widget _buildDatePickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppTheme.accentCyan,
          surface: Color(0xFF2D3250),
          onSurface: Colors.white,
        ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1A1D2E)),
      ),
      child: child!,
    );
  }

  Future<void> _descargarPdf() async {
    setState(() => _isDownloadingPdf = true);

    try {
      final pdfBytes = await ref
          .read(reporteVentasProvider.notifier)
          .descargarPdf();

      if (pdfBytes != null && mounted) {
        await _mostrarOpcionesPDF(context, pdfBytes);
      }
    } catch (e) {
      console('Error al descargar PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error al descargar: $e')),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  /// Generar nombre de archivo formateado
  String _generarNombreArchivo() {
    final desde = DateFormat('yyyyMMdd').format(_fechaDesde);
    final hasta = DateFormat('yyyyMMdd').format(_fechaHasta);
    return 'reporte_ventas_${desde}_$hasta';
  }

  /// Mostrar opciones de PDF (vista previa y compartir)
  Future<void> _mostrarOpcionesPDF(
    BuildContext context,
    Uint8List pdfBytes,
  ) async {
    final nombreArchivo = _generarNombreArchivo();

    final opcion = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.picture_as_pdf, size: 48, color: Colors.red[700]),
        title: const Text('PDF Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$nombreArchivo.pdf',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Text('¿Qué deseas hacer con el PDF?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'compartir'),
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'vista_previa'),
            icon: const Icon(Icons.visibility),
            label: const Text('Ver PDF'),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al mostrar PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Compartir PDF (WhatsApp, correo, etc.)
  Future<void> _compartirPDF(Uint8List pdfBytes, String nombreArchivo) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: '$nombreArchivo.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reporteState = ref.watch(reporteVentasProvider);
    final isMobile = context.isMobile;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Reporte de Ventas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          if (reporteState.hasData && !_isDownloadingPdf)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: _descargarPdf,
              tooltip: 'Descargar PDF',
            ),
          if (_isDownloadingPdf)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
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
                child: Column(
                  children: [
                    // Filtros de fecha
                    _buildFilters(context),

                    // Contenido del reporte
                    Expanded(child: _buildContent(context, reporteState)),
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
              right: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtrar por Fecha',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveLayout(
            mobile: Column(
              children: [
                _buildDateButton(
                  label: 'Desde',
                  date: _fechaDesde,
                  onTap: _selectFechaDesde,
                ),
                const SizedBox(height: 12),
                _buildDateButton(
                  label: 'Hasta',
                  date: _fechaHasta,
                  onTap: _selectFechaHasta,
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: _buildSearchButton()),
              ],
            ),
            tablet: _buildDesktopFilters(),
            desktop: _buildDesktopFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            label: 'Desde',
            date: _fechaDesde,
            onTap: _selectFechaDesde,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateButton(
            label: 'Hasta',
            date: _fechaHasta,
            onTap: _selectFechaHasta,
          ),
        ),
        const SizedBox(width: 16),
        _buildSearchButton(),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.accentCyan,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _dateFormat.format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      onPressed: _buscarReporte,
      icon: const Icon(Icons.search_rounded),
      label: const Text('Buscar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentCyan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReporteVentasState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (state.error != null) {
      return _buildErrorState(context, state.error!);
    }

    if (!state.hasData) {
      return _buildEmptyState();
    }

    return ResponsiveLayout(
      mobile: _buildMobileList(context, state),
      tablet: _buildDataTable(context, state),
      desktop: _buildDataTable(context, state),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando reporte...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insert_chart_outlined_rounded,
              size: 40,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay datos para mostrar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona un rango de fechas y presiona Buscar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar el reporte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _buscarReporte,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
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
    );
  }

  Widget _buildMobileList(BuildContext context, ReporteVentasState state) {
    final detalles = state.detalles;
    final total = state.total;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: detalles.length + (total != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == detalles.length && total != null) {
          return _buildTotalCard(total);
        }
        return _buildVentaCard(detalles[index]);
      },
    );
  }

  Widget _buildVentaCard(VentaReporteEntity venta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con fecha y cliente
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  venta.nombreCliente ?? 'Sin cliente',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  venta.fecha ?? '',
                  style: TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Producto
          Text(
            venta.productoCompleto ?? 'Sin producto',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          // Detalles en grid
          Row(
            children: [
              _buildDetailChip(
                Icons.category_rounded,
                venta.lineaArticulo ?? '-',
              ),
              const SizedBox(width: 8),
              _buildDetailChip(
                Icons.shopping_cart_rounded,
                'Cant: ${venta.cantidad ?? 0}',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Precios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Precio Unit.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    venta.formatMoney(venta.precioUnitario),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Descuento',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    venta.descuentoPorcentaje,
                    style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    venta.formatMoney(venta.totalGeneralBs),
                    style: TextStyle(
                      color: Colors.green.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.6)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(VentaReporteEntity total) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentCyan.withValues(alpha: 0.3),
            AppTheme.primaryColor.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentCyan.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.summarize_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'TOTAL GENERAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Desc: ${total.formatMoney(total.totalBsDesc)}',
                style: TextStyle(color: Colors.orange.shade200, fontSize: 12),
              ),
              Text(
                total.formatMoney(total.totalGeneralBs),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, ReporteVentasState state) {
    final detalles = state.detalles;
    final total = state.total;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Tabla con scroll horizontal
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Colors.white.withValues(alpha: 0.1),
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.white.withValues(alpha: 0.05);
                    }
                    return Colors.transparent;
                  }),
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  columns: const [
                    DataColumn(label: Text('Fecha', style: _headerStyle)),
                    DataColumn(label: Text('Cliente', style: _headerStyle)),
                    DataColumn(label: Text('Producto', style: _headerStyle)),
                    DataColumn(label: Text('Línea', style: _headerStyle)),
                    DataColumn(
                      label: Text('Cant.', style: _headerStyle),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('P. Unit.', style: _headerStyle),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Desc.', style: _headerStyle),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Total Bs.', style: _headerStyle),
                      numeric: true,
                    ),
                  ],
                  rows: detalles.map((venta) => _buildDataRow(venta)).toList(),
                ),
              ),
            ),
          ),

          // Total fijo en la parte inferior
          if (total != null) _buildTotalCard(total),
        ],
      ),
    );
  }

  DataRow _buildDataRow(VentaReporteEntity venta) {
    return DataRow(
      cells: [
        DataCell(Text(venta.fecha ?? '-', style: _cellStyle)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              venta.nombreCliente ?? '-',
              style: _cellStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              venta.productoCompleto ?? '-',
              style: _cellStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(venta.lineaArticulo ?? '-', style: _cellStyle)),
        DataCell(Text('${venta.cantidad ?? 0}', style: _cellStyle)),
        DataCell(
          Text(venta.formatMoney(venta.precioUnitario), style: _cellStyle),
        ),
        DataCell(
          Text(
            venta.descuentoPorcentaje,
            style: _cellStyle.copyWith(color: Colors.orange.shade300),
          ),
        ),
        DataCell(
          Text(
            venta.formatMoney(venta.totalGeneralBs),
            style: _cellStyle.copyWith(
              color: Colors.green.shade300,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  static const _headerStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  static const _cellStyle = TextStyle(color: Colors.white, fontSize: 13);
}
