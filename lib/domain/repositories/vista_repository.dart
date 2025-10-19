import '../entities/vista_entity.dart';

/// Interface del repositorio de vistas/menú
abstract class VistaRepository {
  /// Obtiene el menú del usuario autenticado
  Future<List<VistaEntity>> getMenu();
}
