import '../../core/utils/operation_result.dart';
import '../entities/regla_descuento_entity.dart';

abstract class ReglaDescuentoRepository {
  Future<List<ReglaDescuentoEntity>> listarTodas();
  Future<ReglaDescuentoEntity?> buscarPorArticulo(String codArticulo);
  Future<OperationResult<ReglaDescuentoEntity>> crear(ReglaDescuentoEntity regla);
  Future<OperationResult<ReglaDescuentoEntity>> actualizar(
      int codReglaDescuento, ReglaDescuentoEntity regla);
  Future<OperationResult<void>> eliminar(int codReglaDescuento);
}
