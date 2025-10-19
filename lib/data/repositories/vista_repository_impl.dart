import '../../core/error/exceptions.dart';
import '../../domain/entities/vista_entity.dart';
import '../../domain/repositories/vista_repository.dart';
import '../datasources/vista_remote_datasource.dart';

/// Implementación del repositorio de vistas
class VistaRepositoryImpl implements VistaRepository {
  final VistaRemoteDataSource remoteDataSource;

  VistaRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<VistaEntity>> getMenu() async {
    try {
      final menu = await remoteDataSource.getMenu();
      return menu;
    } on ServerException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
