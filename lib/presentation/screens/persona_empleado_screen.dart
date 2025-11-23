import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/persona_entity.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

class PersonaEmpleadoScreen extends ConsumerStatefulWidget {
  const PersonaEmpleadoScreen({super.key});

  @override
  ConsumerState<PersonaEmpleadoScreen> createState() =>
      _PersonaEmpleadoScreenState();
}

class _PersonaEmpleadoScreenState extends ConsumerState<PersonaEmpleadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apPaternoController = TextEditingController();
  final _apMaternoController = TextEditingController();
  final _ciNumeroController = TextEditingController();
  final _ciExpedidoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _lugarNacimientoController = TextEditingController();
  
  DateTime? _ciFechaVencimiento;
  DateTime? _fechaNacimiento;
  String _estadoCivil = 'S'; // Soltero
  String _sexo = 'M'; // Masculino
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargar empleados al iniciar
    Future.microtask(() => ref.read(empleadoProvider.notifier).cargarEmpleados());
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apPaternoController.dispose();
    _apMaternoController.dispose();
    _ciNumeroController.dispose();
    _ciExpedidoController.dispose();
    _direccionController.dispose();
    _lugarNacimientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Empleado'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      drawer: context.screenWidth < 600 ? const AppDrawer() : null,
      body: Row(
        children: [
          // Drawer permanente en desktop/tablet
          if (context.screenWidth >= 600)
            Container(
              width: 280,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: context.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: const AppDrawer(),
            ),

          // Contenido principal
          Expanded(
            child: context.screenWidth < 900
                ? _buildMobileLayout()
                : _buildDesktopLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: context.colorScheme.surface,
            elevation: 1,
            child: TabBar(
              labelColor: context.colorScheme.primary,
              unselectedLabelColor: context.colorScheme.onSurfaceVariant,
              indicatorColor: context.colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.person_add), text: 'Registrar'),
                Tab(icon: Icon(Icons.badge), text: 'Empleados'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFormulario(),
                _buildEmpleadosList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
              children: [
                // Formulario de registro
                Expanded(
                  flex: 3,
                  child: _buildFormulario(),
                ),

                // Listado de empleados
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: context.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.badge, color: context.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Empleados Registrados',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: _buildEmpleadosList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: context.colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.person_add,
                                          color: context.colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Datos Personales',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                
                                // Nombres
                                TextFormField(
                                  controller: _nombresController,
                                  decoration: InputDecoration(
                                    labelText: 'Nombres *',
                                    hintText: 'Ingrese los nombres',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.person),
                                    filled: true,
                                    fillColor: context.colorScheme.surface,
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(height: 16),

                                // Apellidos
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _apPaternoController,
                                        decoration: InputDecoration(
                                          labelText: 'Apellido Paterno *',
                                          hintText: 'Paterno',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: context.colorScheme.surface,
                                        ),
                                        validator: (value) =>
                                            value?.isEmpty ?? true ? 'Requerido' : null,
                                        textCapitalization: TextCapitalization.words,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _apMaternoController,
                                        decoration: InputDecoration(
                                          labelText: 'Apellido Materno *',
                                          hintText: 'Materno',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: context.colorScheme.surface,
                                        ),
                                        validator: (value) =>
                                            value?.isEmpty ?? true ? 'Requerido' : null,
                                        textCapitalization: TextCapitalization.words,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // CI
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _ciNumeroController,
                                        decoration: InputDecoration(
                                          labelText: 'CI Número *',
                                          hintText: '12345678',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          prefixIcon: const Icon(Icons.badge),
                                          filled: true,
                                          fillColor: context.colorScheme.surface,
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) =>
                                            value?.isEmpty ?? true ? 'Requerido' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _ciExpedidoController.text.isEmpty
                                            ? 'LP'
                                            : _ciExpedidoController.text,
                                        decoration: InputDecoration(
                                          labelText: 'Expedido *',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: context.colorScheme.surface,
                                        ),
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(value: 'LP', child: Text('LP')),
                                          DropdownMenuItem(value: 'SC', child: Text('SC')),
                                          DropdownMenuItem(value: 'CB', child: Text('CB')),
                                          DropdownMenuItem(value: 'OR', child: Text('OR')),
                                          DropdownMenuItem(value: 'PT', child: Text('PT')),
                                          DropdownMenuItem(value: 'TJ', child: Text('TJ')),
                                          DropdownMenuItem(value: 'CH', child: Text('CH')),
                                          DropdownMenuItem(value: 'BE', child: Text('BE')),
                                          DropdownMenuItem(value: 'PD', child: Text('PD')),
                                        ],
                                        onChanged: (value) {
                                          _ciExpedidoController.text = value!;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // CI Fecha Vencimiento
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _ciFechaVencimiento ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _ciFechaVencimiento = date;
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'CI Fecha Vencimiento',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: const Icon(Icons.calendar_today),
                                      filled: true,
                                      fillColor: context.colorScheme.surface,
                                    ),
                                    child: Text(
                                      _ciFechaVencimiento != null
                                          ? DateFormat('dd/MM/yyyy').format(_ciFechaVencimiento!)
                                          : 'Seleccione fecha',
                                      style: TextStyle(
                                        color: _ciFechaVencimiento != null
                                            ? context.colorScheme.onSurface
                                            : context.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Dirección
                                TextFormField(
                                  controller: _direccionController,
                                  decoration: InputDecoration(
                                    labelText: 'Dirección *',
                                    hintText: 'Calle, número, zona',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.home),
                                    filled: true,
                                    fillColor: context.colorScheme.surface,
                                  ),
                                  maxLines: 2,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                                  textCapitalization: TextCapitalization.sentences,
                                ),
                                const SizedBox(height: 16),

                                // Estado Civil y Sexo
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _estadoCivil,
                                        decoration: InputDecoration(
                                          labelText: 'Estado Civil *',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          prefixIcon: const Icon(Icons.favorite),
                                          filled: true,
                                          fillColor: context.colorScheme.surface,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                        ),
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'S',
                                            child: Text('Soltero/a', overflow: TextOverflow.ellipsis),
                                          ),
                                          DropdownMenuItem(
                                            value: 'C',
                                            child: Text('Casado/a', overflow: TextOverflow.ellipsis),
                                          ),
                                          DropdownMenuItem(
                                            value: 'D',
                                            child: Text('Divorciado/a', overflow: TextOverflow.ellipsis),
                                          ),
                                          DropdownMenuItem(
                                            value: 'V',
                                            child: Text('Viudo/a', overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _estadoCivil = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _sexo,
                                        decoration: InputDecoration(
                                          labelText: 'Sexo *',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          prefixIcon: Icon(
                                            _sexo == 'M' ? Icons.male : Icons.female,
                                          ),
                                          filled: true,
                                          fillColor: context.colorScheme.surface,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                        ),
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'M',
                                            child: Text('Masculino', overflow: TextOverflow.ellipsis),
                                          ),
                                          DropdownMenuItem(
                                            value: 'F',
                                            child: Text('Femenino', overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _sexo = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Fecha Nacimiento
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _fechaNacimiento ?? DateTime(2000),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _fechaNacimiento = date;
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Fecha de Nacimiento',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: const Icon(Icons.calendar_today),
                                      filled: true,
                                      fillColor: context.colorScheme.surface,
                                    ),
                                    child: Text(
                                      _fechaNacimiento != null
                                          ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                                          : 'Seleccione fecha',
                                      style: TextStyle(
                                        color: _fechaNacimiento != null
                                            ? context.colorScheme.onSurface
                                            : context.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Lugar Nacimiento
                                TextFormField(
                                  controller: _lugarNacimientoController,
                                  decoration: InputDecoration(
                                    labelText: 'Lugar de Nacimiento *',
                                    hintText: 'Ciudad, país',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.place),
                                    filled: true,
                                    fillColor: context.colorScheme.surface,
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                                  textCapitalization: TextCapitalization.words,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                          // Botón de guardar
                          FilledButton.icon(
                            onPressed: _isLoading ? null : _handleSave,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _isLoading ? 'Guardando...' : 'Registrar Empleado',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Asignar valor por defecto a ciExpedido si está vacío
    if (_ciExpedidoController.text.isEmpty) {
      _ciExpedidoController.text = 'LP';
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Crear persona
      final persona = await ref.read(personaProvider.notifier).crear(
            nombres: _nombresController.text,
            apPaterno: _apPaternoController.text,
            apMaterno: _apMaternoController.text,
            ciNumero: _ciNumeroController.text,
            ciExpedido: _ciExpedidoController.text,
            ciFechaVencimiento: _ciFechaVencimiento,
            direccion: _direccionController.text,
            estadoCivil: _estadoCivil,
            fechaNacimiento: _fechaNacimiento,
            lugarNacimiento: _lugarNacimientoController.text,
            sexo: _sexo,
          );

      if (persona == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo crear la persona'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. Crear empleado con el codPersona recién creado
      final empleado = await ref.read(empleadoProvider.notifier).crear(
            codPersona: persona.codPersona,
          );

      if (!mounted) return;

      if (empleado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Persona creada pero no se pudo registrar como empleado'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Limpiar formulario
      _formKey.currentState!.reset();
      _nombresController.clear();
      _apPaternoController.clear();
      _apMaternoController.clear();
      _ciNumeroController.clear();
      _ciExpedidoController.clear();
      _direccionController.clear();
      _lugarNacimientoController.clear();
      setState(() {
        _ciFechaVencimiento = null;
        _fechaNacimiento = null;
        _estadoCivil = 'S';
        _sexo = 'M';
      });

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empleado registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildEmpleadosList() {
    final empleadosState = ref.watch(empleadoProvider);

    return empleadosState.when(
      data: (empleados) {
        if (empleados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: context.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay empleados registrados',
                  style: TextStyle(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(empleadoProvider.notifier).cargarEmpleados();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: empleados.length,
            itemBuilder: (context, index) {
              final empleado = empleados[index];
              
              return FutureBuilder<PersonaEntity?>(
                future: _getPersona(empleado.codPersona),
                builder: (context, snapshot) {
                  final persona = snapshot.data;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: persona != null ? () => _showEditPersonaDialog(persona) : null,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.colorScheme.primary,
                              context.colorScheme.primaryContainer,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${empleado.codEmpleado}',
                            style: TextStyle(
                              color: context.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        persona?.nombreCompleto ?? 'Cargando...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: persona != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.badge_outlined,
                                        size: 14,
                                        color: context.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'CI: ${persona.ciNumero} ${persona.ciExpedido}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        size: 14,
                                        color: context.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Empleado #${empleado.codEmpleado}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        context.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Obteniendo datos...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar empleados',
              style: TextStyle(color: context.colorScheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(empleadoProvider.notifier).cargarEmpleados();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<PersonaEntity?> _getPersona(int codPersona) async {
    try {
      return await ref.read(personaProvider.notifier).buscarPorCodigo(codPersona);
    } catch (e) {
      return null;
    }
  }

  void _showEditPersonaDialog(PersonaEntity persona) {
    showDialog(
      context: context,
      builder: (context) => _EditPersonaDialog(
        persona: persona,
        onSave: (updatedPersona) async {
          try {
            await ref.read(personaProvider.notifier).actualizar(
                  codPersona: updatedPersona.codPersona,
                  nombres: updatedPersona.nombres,
                  apPaterno: updatedPersona.apPaterno,
                  apMaterno: updatedPersona.apMaterno,
                  ciNumero: updatedPersona.ciNumero,
                  ciExpedido: updatedPersona.ciExpedido,
                  ciFechaVencimiento: updatedPersona.ciFechaVencimiento,
                  direccion: updatedPersona.direccion,
                  estadoCivil: updatedPersona.estadoCivil,
                  fechaNacimiento: updatedPersona.fechaNacimiento,
                  lugarNacimiento: updatedPersona.lugarNacimiento,
                  sexo: updatedPersona.sexo,
                );

            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Datos actualizados exitosamente'),
                backgroundColor: Colors.green,
              ),
            );

            // Recargar lista
            ref.read(empleadoProvider.notifier).cargarEmpleados();
          } on ApiException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}

class _EditPersonaDialog extends StatefulWidget {
  final PersonaEntity persona;
  final Function(PersonaEntity) onSave;

  const _EditPersonaDialog({
    required this.persona,
    required this.onSave,
  });

  @override
  State<_EditPersonaDialog> createState() => _EditPersonaDialogState();
}

class _EditPersonaDialogState extends State<_EditPersonaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _apPaternoController;
  late TextEditingController _apMaternoController;
  late TextEditingController _ciNumeroController;
  late TextEditingController _ciExpedidoController;
  late TextEditingController _direccionController;
  late TextEditingController _lugarNacimientoController;
  late DateTime? _ciFechaVencimiento;
  late DateTime? _fechaNacimiento;
  late String _estadoCivil;
  late String _sexo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.persona.nombres);
    _apPaternoController = TextEditingController(text: widget.persona.apPaterno);
    _apMaternoController = TextEditingController(text: widget.persona.apMaterno);
    _ciNumeroController = TextEditingController(text: widget.persona.ciNumero);
    _ciExpedidoController = TextEditingController(text: widget.persona.ciExpedido);
    _direccionController = TextEditingController(text: widget.persona.direccion);
    _lugarNacimientoController = TextEditingController(text: widget.persona.lugarNacimiento);
    _ciFechaVencimiento = widget.persona.ciFechaVencimiento;
    _fechaNacimiento = widget.persona.fechaNacimiento;
    _estadoCivil = widget.persona.estadoCivil;
    _sexo = widget.persona.sexo;
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apPaternoController.dispose();
    _apMaternoController.dispose();
    _ciNumeroController.dispose();
    _ciExpedidoController.dispose();
    _direccionController.dispose();
    _lugarNacimientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Datos Personales'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombresController,
                  decoration: const InputDecoration(
                    labelText: 'Nombres *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _apPaternoController,
                        decoration: const InputDecoration(
                          labelText: 'Ap. Paterno *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _apMaternoController,
                        decoration: const InputDecoration(
                          labelText: 'Ap. Materno *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _ciNumeroController,
                        decoration: const InputDecoration(
                          labelText: 'CI *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _ciExpedidoController.text,
                        decoration: const InputDecoration(
                          labelText: 'Exp. *',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'LP', child: Text('LP')),
                          DropdownMenuItem(value: 'SC', child: Text('SC')),
                          DropdownMenuItem(value: 'CB', child: Text('CB')),
                          DropdownMenuItem(value: 'OR', child: Text('OR')),
                          DropdownMenuItem(value: 'PT', child: Text('PT')),
                          DropdownMenuItem(value: 'TJ', child: Text('TJ')),
                          DropdownMenuItem(value: 'CH', child: Text('CH')),
                          DropdownMenuItem(value: 'BE', child: Text('BE')),
                          DropdownMenuItem(value: 'PD', child: Text('PD')),
                        ],
                        onChanged: (value) => _ciExpedidoController.text = value!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  maxLines: 2,
                  validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _estadoCivil,
                        decoration: const InputDecoration(
                          labelText: 'Estado Civil *',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'S', child: Text('Soltero/a')),
                          DropdownMenuItem(value: 'C', child: Text('Casado/a')),
                          DropdownMenuItem(value: 'D', child: Text('Divorciado/a')),
                          DropdownMenuItem(value: 'V', child: Text('Viudo/a')),
                        ],
                        onChanged: (value) => setState(() => _estadoCivil = value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sexo,
                        decoration: const InputDecoration(
                          labelText: 'Sexo *',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'M', child: Text('Masculino')),
                          DropdownMenuItem(value: 'F', child: Text('Femenino')),
                        ],
                        onChanged: (value) => setState(() => _sexo = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lugarNacimientoController,
                  decoration: const InputDecoration(
                    labelText: 'Lugar Nacimiento *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedPersona = PersonaEntity(
      codPersona: widget.persona.codPersona,
      nombres: _nombresController.text,
      apPaterno: _apPaternoController.text,
      apMaterno: _apMaternoController.text,
      ciNumero: _ciNumeroController.text,
      ciExpedido: _ciExpedidoController.text,
      ciFechaVencimiento: _ciFechaVencimiento,
      direccion: _direccionController.text,
      estadoCivil: _estadoCivil,
      fechaNacimiento: _fechaNacimiento,
      lugarNacimiento: _lugarNacimientoController.text,
      sexo: _sexo,
      audUsuario: widget.persona.audUsuario,
    );

    widget.onSave(updatedPersona);
  }
}
