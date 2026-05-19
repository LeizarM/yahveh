import '../../core/error/exceptions.dart';
import '../../domain/entities/vista_entity.dart';
import '../../domain/repositories/vista_repository.dart';
import '../datasources/vista_remote_datasource.dart';

/// Implementación del repositorio de vistas
class VistaRepositoryImpl implements VistaRepository {
  final VistaRemoteDataSource remoteDataSource;

  VistaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VistaEntity>> getMenu() async {
    try {
      return await remoteDataSource.getMenu();
    } on ServerException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<VistaEntity>> getAllVistas() async {
    try {
      return await remoteDataSource.getAllVistas();
    } on ServerException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<VistaEntity>> getVistasDeUsuario(int codUsuario) async {
    try {
      return await remoteDataSource.getVistasDeUsuario(codUsuario);
    } on ServerException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> setVistasDeUsuario(int codUsuario, List<int> codVistas) async {
    try {
      await remoteDataSource.setVistasDeUsuario(codUsuario, codVistas);
    } on ServerException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
