import '../../core/utils/operation_result.dart';
import '../../domain/entities/regla_descuento_entity.dart';
import '../../domain/repositories/regla_descuento_repository.dart';
import '../datasources/regla_descuento_remote_datasource.dart';
import '../models/regla_descuento_model.dart';

class ReglaDescuentoRepositoryImpl implements ReglaDescuentoRepository {
  final ReglaDescuentoRemoteDataSource _remote;
  ReglaDescuentoRepositoryImpl(this._remote);

  @override
  Future<List<ReglaDescuentoEntity>> listarTodas() async {
    final models = await _remote.listarTodas();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ReglaDescuentoEntity?> buscarPorArticulo(String codArticulo) async {
    final model = await _remote.buscarPorArticulo(codArticulo);
    return model?.toEntity();
  }

  @override
  Future<OperationResult<ReglaDescuentoEntity>> crear(ReglaDescuentoEntity regla) async {
    final model = ReglaDescuentoModel(
      codReglaDescuento: regla.codReglaDescuento,
      codArticulo: regla.codArticulo,
      descripcionArticulo: regla.descripcionArticulo,
      cantidadMinima: regla.cantidadMinima,
      descuento: regla.descuento,
      audUsuario: regla.audUsuario,
    );
    final result = await _remote.crear(model);
    return OperationResult(data: result.data.toEntity(), message: result.message);
  }

  @override
  Future<OperationResult<ReglaDescuentoEntity>> actualizar(
      int codReglaDescuento, ReglaDescuentoEntity regla) async {
    final model = ReglaDescuentoModel(
      codReglaDescuento: regla.codReglaDescuento,
      codArticulo: regla.codArticulo,
      descripcionArticulo: regla.descripcionArticulo,
      cantidadMinima: regla.cantidadMinima,
      descuento: regla.descuento,
      audUsuario: regla.audUsuario,
    );
    final result = await _remote.actualizar(codReglaDescuento, model);
    return OperationResult(data: result.data.toEntity(), message: result.message);
  }

  @override
  Future<OperationResult<void>> eliminar(int codReglaDescuento) async {
    return await _remote.eliminar(codReglaDescuento);
  }
}
