import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../../domain/entities/regla_descuento_entity.dart';
import 'providers.dart';

class ReglaDescuentoNotifier extends Notifier<AsyncValue<List<ReglaDescuentoEntity>>> {
  @override
  AsyncValue<List<ReglaDescuentoEntity>> build() => const AsyncValue.data([]);

  Future<void> cargar() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(reglaDescuentoRepositoryProvider);
      final reglas = await repo.listarTodas();
      state = AsyncValue.data(reglas);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar reglas', st);
    }
  }

  Future<OperationResult<ReglaDescuentoEntity>?> crear(ReglaDescuentoEntity regla) async {
    try {
      final repo = ref.read(reglaDescuentoRepositoryProvider);
      final result = await repo.crear(regla);
      await cargar();
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al crear regla', statusCode: 500);
    }
  }

  Future<OperationResult<ReglaDescuentoEntity>?> actualizar(
      int codReglaDescuento, ReglaDescuentoEntity regla) async {
    try {
      final repo = ref.read(reglaDescuentoRepositoryProvider);
      final result = await repo.actualizar(codReglaDescuento, regla);
      await cargar();
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al actualizar regla', statusCode: 500);
    }
  }

  Future<void> eliminar(int codReglaDescuento) async {
    try {
      final repo = ref.read(reglaDescuentoRepositoryProvider);
      await repo.eliminar(codReglaDescuento);
      await cargar();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al eliminar regla', statusCode: 500);
    }
  }
}
