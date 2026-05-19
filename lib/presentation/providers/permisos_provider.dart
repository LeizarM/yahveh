import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vista_entity.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// Estado del panel de permisos
// ---------------------------------------------------------------------------

class PermisosState {
  final List<VistaEntity> todasLasVistas;  // Catálogo completo del sistema
  final Set<int> vistasAsignadas;          // IDs actualmente asignados al usuario
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const PermisosState({
    this.todasLasVistas = const [],
    this.vistasAsignadas = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  PermisosState copyWith({
    List<VistaEntity>? todasLasVistas,
    Set<int>? vistasAsignadas,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return PermisosState(
      todasLasVistas: todasLasVistas ?? this.todasLasVistas,
      vistasAsignadas: vistasAsignadas ?? this.vistasAsignadas,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PermisosNotifier extends Notifier<PermisosState> {
  @override
  PermisosState build() => const PermisosState();

  /// Carga todas las vistas del sistema + las asignadas al usuario dado.
  Future<void> cargarPermisos(int codUsuario) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(vistaRepositoryProvider);

      // Ejecutar ambas llamadas en paralelo
      final results = await Future.wait([
        repo.getAllVistas(),
        repo.getVistasDeUsuario(codUsuario),
      ]);

      final todas = results[0];
      final asignadas = results[1].map((v) => v.codVista).toSet();

      state = state.copyWith(
        todasLasVistas: todas,
        vistasAsignadas: asignadas,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Alterna el permiso de una vista (check/uncheck).
  void toggleVista(int codVista) {
    final actuales = Set<int>.from(state.vistasAsignadas);
    if (actuales.contains(codVista)) {
      actuales.remove(codVista);
    } else {
      actuales.add(codVista);
    }
    state = state.copyWith(vistasAsignadas: actuales);
  }

  /// Guarda los cambios en el servidor.
  Future<void> guardarPermisos(int codUsuario) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final repo = ref.read(vistaRepositoryProvider);
      await repo.setVistasDeUsuario(
        codUsuario,
        state.vistasAsignadas.toList(),
      );
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Limpia el estado (al cerrar el diálogo).
  void limpiar() {
    state = const PermisosState();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final permisosProvider = NotifierProvider<PermisosNotifier, PermisosState>(
  () => PermisosNotifier(),
);
