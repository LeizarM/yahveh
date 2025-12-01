import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/animations.dart';
import '../../domain/entities/nota_entrega_entity.dart';
import '../../domain/entities/detalle_nota_entrega_entity.dart';
import '../../domain/entities/cliente_entity.dart';
import '../../domain/entities/articulo_entity.dart';
import '../providers/providers.dart';
import '../providers/cliente_provider.dart';
import '../providers/articulo_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla de Notas de Entrega
class DeliveryNotesScreen extends ConsumerStatefulWidget {
  const DeliveryNotesScreen({super.key});

  @override
  ConsumerState<DeliveryNotesScreen> createState() => _DeliveryNotesScreenState();
}

class _DeliveryNotesScreenState extends ConsumerState<DeliveryNotesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar notas al iniciar
    Future.microtask(() {
      ref.read(notaEntregaProvider.notifier).cargarNotas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notasAsync = ref.watch(notaEntregaProvider);
    final isMobile = context.isMobile;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Notas de Entrega', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(notaEntregaProvider.notifier).cargarNotas();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: isMobile
          ? ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: const AppDrawer(),
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
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Drawer permanente en desktop/tablet con blur
              if (!isMobile)
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: const AppDrawer(),
                    ),
                  ),
                ),

              // Contenido principal
              Expanded(
                child: notasAsync.when(
                  data: (notas) => _buildNotasList(context, notas),
                  loading: () => Center(child: CircularProgressIndicator(color: AppTheme.accentCyan)),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No se pudieron cargar las notas',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(notaEntregaProvider.notifier).cargarNotas();
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
      ),
    );
  }

  Widget _buildNotasList(BuildContext context, List<NotaEntregaEntity> notas) {
    if (notas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 120, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No hay notas de entrega',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera nota usando el botón (+)',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.numbers,
                          size: 16,
                          color: AppTheme.accentCyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#${nota.codNotaEntrega}',
                          style: TextStyle(
                            color: AppTheme.accentCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Botón de PDF
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red.shade300,
                      ),
                      onPressed: () => _generarPDF(context, nota.codNotaEntrega, nota.nombreCliente),
                      tooltip: 'Generar PDF',
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dateFormat.format(nota.fecha),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 20, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nota.nombreCliente,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (nota.direccion.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nota.direccion,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
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
                    Icon(Icons.map, size: 18, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Text(
                      nota.zona,
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Método para generar y abrir el PDF de una nota de entrega
  Future<void> _generarPDF(BuildContext context, int codNotaEntrega, String nombreCliente) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
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
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentCyan),
                  const SizedBox(height: 16),
                  const Text('Generando PDF...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final pdfBytes = await ref.read(notaEntregaProvider.notifier).generarPDF(codNotaEntrega);
      
      // Cerrar dialog de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (pdfBytes != null) {
        await _mostrarOpcionesPDF(context, pdfBytes, codNotaEntrega, nombreCliente, scaffoldMessenger);
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
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    final nombreArchivo = _generarNombreArchivo(nombreCliente, codNotaEntrega);
    
    final opcion = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.picture_as_pdf,
          size: 48,
          color: Colors.red[700],
        ),
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
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$nombreArchivo.pdf',
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al compartir PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNotaDetails(BuildContext context, NotaEntregaEntity nota) {
    // Load detalles for this nota
    ref.read(detalleNotaEntregaProvider.notifier).cargarDetallesPorNota(nota.codNotaEntrega);
    
    showDialog(
      context: context,
      builder: (context) => _NotaDetailsDialog(nota: nota),
    );
  }

  void _showCreateNotaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateNotaDialog(),
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
                  colors: [
                    context.colorScheme.primaryContainer,
                    context.colorScheme.primaryContainer.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nota de Entrega #${nota.codNotaEntrega}',
                          style: context.theme.textTheme.titleLarge?.copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateFormat.format(nota.fecha),
                          style: TextStyle(
                            color: context.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón para generar PDF
                  IconButton(
                    icon: Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red[700],
                    ),
                    onPressed: () => _generarPDF(context, ref, nota.codNotaEntrega, nota.nombreCliente),
                    tooltip: 'Generar PDF',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
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
                  if (nota.direccion.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Dirección'),
                      subtitle: Text(nota.direccion),
                    ),
                  if (nota.zona.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.map),
                      title: const Text('Zona'),
                      subtitle: Text(nota.zona),
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
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(detalle.descripcionArticulo),
                                subtitle: Text(
                                  '${detalle.codArticulo} • ${detalle.lineaArticulo}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
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
                            top: BorderSide(color: context.colorScheme.outline.withValues(alpha: 0.2)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL:',
                              style: context.theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bs. ${total.toStringAsFixed(2)}',
                              style: context.theme.textTheme.titleLarge?.copyWith(
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
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método para generar y abrir el PDF de una nota de entrega
  Future<void> _generarPDF(BuildContext context, WidgetRef ref, int codNotaEntrega, String nombreCliente) async {
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
      final pdfBytes = await ref.read(notaEntregaProvider.notifier).generarPDF(codNotaEntrega);
      
      // Cerrar dialog de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (pdfBytes != null) {
        await _mostrarOpcionesPDF(context, pdfBytes, codNotaEntrega, nombreCliente, scaffoldMessenger);
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
        icon: Icon(
          Icons.picture_as_pdf,
          size: 48,
          color: Colors.red[700],
        ),
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
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$nombreArchivo.pdf',
      );
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
  DateTime _selectedDate = DateTime.now();
  final _direccionController = TextEditingController();
  final List<_DetalleItem> _detalles = [];
  bool _isLoading = false;

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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    icon: Icon(Icons.close, color: context.colorScheme.onPrimary),
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
                                  errorText: _selectedCliente == null && _formKey.currentState?.validate() == false
                                      ? 'Selecciona un cliente'
                                      : null,
                                ),
                                child: Text(
                                  _selectedCliente?.nombreCliente ?? 'Buscar cliente...',
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
                        error: (_, __) => const Text('Error al cargar clientes'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Fecha
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
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
                      
                      // Dirección
                      TextFormField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección de Entrega *',
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
                            style: context.theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL:',
                                    style: context.theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    'Bs. ${_calculateTotal().toStringAsFixed(2)}',
                                    style: context.theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colorScheme.onPrimaryContainer,
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
                  top: BorderSide(color: context.colorScheme.outline.withValues(alpha: 0.2)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(detalle.articulo.descripcion),
        subtitle: Text(
          '${detalle.articulo.codArticulo} • Precio: Bs. ${detalle.precioUnitario.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit quantity button
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editCantidad(index, detalle),
              tooltip: 'Editar cantidad',
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Cant: ${detalle.cantidad}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Bs. ${(detalle.cantidad * detalle.precioUnitario).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ],
            ),
            const SizedBox(width: 8),
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

  void _editCantidad(int index, _DetalleItem detalle) {
    final controller = TextEditingController(text: detalle.cantidad.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cantidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              detalle.articulo.descripcion,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
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
              final newCantidad = int.tryParse(controller.text) ?? 0;
              if (newCantidad > 0) {
                setState(() {
                  _detalles[index] = _DetalleItem(
                    articulo: detalle.articulo,
                    cantidad: newCantidad,
                    precioUnitario: detalle.precioUnitario,
                  );
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La cantidad debe ser mayor a 0'),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    return _detalles.fold(0, (sum, item) => sum + (item.cantidad * item.precioUnitario));
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
                          .where((c) => c.nombreCliente
                              .toLowerCase()
                              .contains(value.toLowerCase()))
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
                                setState(() {
                                  _selectedCliente = cliente;
                                  _direccionController.text = cliente.direccion;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay artículos con precios válidos'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final searchController = TextEditingController();
      List<ArticuloEntity> filteredArticulos = articulosConPrecio;
      ArticuloEntity? selectedArticulo;
      final cantidadController = TextEditingController(text: '1');
      
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
                                    .where((a) =>
                                        a.descripcion
                                            .toLowerCase()
                                            .contains(value.toLowerCase()) ||
                                        (a.codArticulo ?? '')
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
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
                                      child: Text('No se encontraron artículos'),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredArticulos.length,
                                      itemBuilder: (context, index) {
                                        final articulo = filteredArticulos[index];
                                        final isSelected =
                                            selectedArticulo == articulo;
                                        return ListTile(
                                          selected: isSelected,
                                          selectedTileColor: context
                                              .colorScheme.primaryContainer
                                              .withValues(alpha: 0.3),
                                          title: Text(
                                            articulo.descripcion,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${articulo.codArticulo} • Precio: Bs. ${articulo.precioActual!.toStringAsFixed(2)}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          trailing: isSelected
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: context
                                                      .colorScheme.primary,
                                                )
                                              : null,
                                          onTap: () {
                                            setDialogState(() {
                                              selectedArticulo = articulo;
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
                            decoration: const InputDecoration(
                              labelText: 'Cantidad *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
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
                          color: context.colorScheme.outline.withValues(alpha: 0.2),
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
                                  final cantidad = int.tryParse(
                                          cantidadController.text) ??
                                      1;
                                  if (cantidad <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'La cantidad debe ser mayor a 0'),
                                      ),
                                    );
                                    return;
                                  }

                                  // Verificar si el artículo ya existe
                                  final existingIndex = _detalles.indexWhere(
                                    (d) =>
                                        d.articulo.codArticulo ==
                                        selectedArticulo!.codArticulo,
                                  );

                                  setState(() {
                                    if (existingIndex >= 0) {
                                      // Si existe, sumar la cantidad
                                      _detalles[existingIndex] = _DetalleItem(
                                        articulo: _detalles[existingIndex].articulo,
                                        cantidad: _detalles[existingIndex].cantidad + cantidad,
                                        precioUnitario: _detalles[existingIndex].precioUnitario,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Cantidad actualizada: ${_detalles[existingIndex].cantidad}',
                                          ),
                                          backgroundColor: Colors.blue,
                                        ),
                                      );
                                    } else {
                                      // Si no existe, agregar nuevo
                                      _detalles.add(_DetalleItem(
                                        articulo: selectedArticulo!,
                                        cantidad: cantidad,
                                        precioUnitario:
                                            selectedArticulo!.precioActual!,
                                      ));
                                    }
                                  });
                                  Navigator.pop(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un artículo')),
      );
      return;
    }

    // Mostrar vista previa antes de guardar
    final confirmed = await _showPreviewDialog();
    if (confirmed != true) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Crear nota de entrega
      final nota = NotaEntregaEntity(
        codNotaEntrega: 0,
        codCliente: _selectedCliente!.codCliente,
        nombreCliente: _selectedCliente!.nombreCliente,
        fecha: _selectedDate,
        direccion: _direccionController.text,
        zona: '', // Zona se puede obtener desde el backend
        audUsuario: 0,
      );

      final resultNota = await ref.read(notaEntregaProvider.notifier).crear(nota);

      if (resultNota != null) {
        // Crear detalles
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
            precioTotal: detalle.cantidad * detalle.precioUnitario,
            precioSinFactura: 0,
            audUsuario: 0,
          );

          await ref.read(detalleNotaEntregaProvider.notifier).crear(
                resultNota.data.codNotaEntrega,
                detalleEntity,
              );
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nota de entrega creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Preguntar si desea generar el PDF
          await _preguntarGenerarPDF(resultNota.data.codNotaEntrega, _selectedCliente!.nombreCliente);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Preguntar al usuario si desea generar el PDF de la nota de entrega
  Future<void> _preguntarGenerarPDF(int codNotaEntrega, String nombreCliente) async {
    final scaffoldContext = context;
    
    final generarPDF = await showDialog<bool>(
      context: scaffoldContext,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.picture_as_pdf,
          size: 48,
          color: Colors.red[700],
        ),
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
  Future<void> _generarPDF(BuildContext context, int codNotaEntrega, String nombreCliente) async {
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
      final pdfBytes = await ref.read(notaEntregaProvider.notifier).generarPDF(codNotaEntrega);
      
      // Cerrar dialog de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (pdfBytes != null) {
        await _mostrarOpcionesPDF(context, pdfBytes, codNotaEntrega, nombreCliente, scaffoldMessenger);
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
        icon: Icon(
          Icons.picture_as_pdf,
          size: 48,
          color: Colors.red[700],
        ),
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
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$nombreArchivo.pdf',
      );
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
            maxWidth: context.screenWidth > 600 ? 600 : context.screenWidth - 32,
            maxHeight: context.screenHeight - 100,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[500]!,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.preview,
                      color: Colors.white,
                      size: 24,
                    ),
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
                                  Icon(Icons.person, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'CLIENTE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 12),
                              Text(
                                _selectedCliente!.nombreCliente,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      dateFormat.format(_selectedDate),
                                      style: TextStyle(
                                        color: Colors.grey[700],
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
                                  Icon(Icons.location_on,
                                      size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _direccionController.text,
                                      style: TextStyle(
                                        color: Colors.grey[700],
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
                          Icon(Icons.shopping_cart, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'ARTÍCULOS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.0,
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
                                  backgroundColor: context.colorScheme.primaryContainer,
                                  radius: 16,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: context.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'Bs. ${detalle.precioUnitario.toStringAsFixed(2)} × ${detalle.cantidad}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
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
                                      style: TextStyle(
                                        color: Colors.green[700],
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
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.monetization_on, color: Colors.green, size: 22),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'TOTAL',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Text(
                                  'Bs. ${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
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
                  color: Colors.grey[100],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
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

  _DetalleItem({
    required this.articulo,
    required this.cantidad,
    required this.precioUnitario,
  });
}
