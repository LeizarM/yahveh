import '../entities/vista_entity.dart';

/// Interface del repositorio de vistas/menú
abstract class VistaRepository {
  /// Menú del usuario autenticado (solo sus vistas permitidas)
  Future<List<VistaEntity>> getMenu();

  /// Admin: todas las vistas del sistema
  Future<List<VistaEntity>> getAllVistas();

  /// Admin: vistas asignadas a un usuario específico
  Future<List<VistaEntity>> getVistasDeUsuario(int codUsuario);

  /// Admin: reemplaza las vistas de un usuario
  Future<void> setVistasDeUsuario(int codUsuario, List<int> codVistas);
}
