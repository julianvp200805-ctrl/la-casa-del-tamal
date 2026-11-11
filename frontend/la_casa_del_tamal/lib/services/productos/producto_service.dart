import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/services/api_client.dart';

/// Inventario: productos y tipos de producto (rutas solo para admin).
class ProductoService {
  final ApiClient _api = ApiClient.I;

  // GET /producto/obtener
  Future<List<Producto>> obtenerProductos() async {
    final data = await _api.getJson('/producto/obtener', conToken: true, defecto: 'No se pudieron cargar los productos');
    return (data as List).map((e) => Producto.fromJson(e)).toList();
  }

  // GET /tipoProducto/obtener_tipos
  Future<List<TipoProducto>> obtenerTipos() async {
    final data = await _api.getJson('/tipoProducto/obtener_tipos', conToken: true, defecto: 'No se pudieron cargar los tipos de producto');
    return (data as List).map((e) => TipoProducto.fromJson(e)).toList();
  }

  // POST /producto/crearProducto (el backend calcula el vencimiento)
  Future<void> crearProducto({required Object idTipo, required String fechaIngreso, required String lote}) {
    return _api.postJson(
      '/producto/crearProducto',
      {'id_tipo': idTipo, 'fecha_ingreso': fechaIngreso, 'codigo_lote': lote},
      conToken: true,
      defecto: 'No se pudo guardar el producto',
    );
  }

  // POST /tipoProducto/crear_tipo
  Future<TipoProducto> crearTipo({required String nombre, required int dias}) async {
    final data = await _api.postJson(
      '/tipoProducto/crear_tipo',
      {'nombre': nombre, 'dias_vencimiento': dias},
      conToken: true,
      defecto: 'No se pudo crear el tipo de producto',
    );
    return TipoProducto.fromJson(data['data']);
  }

  // DELETE /producto/eliminar/:id (descartar un producto vencido)
  Future<void> eliminarProducto(Object id) {
    return _api.deleteJson('/producto/eliminar/$id', conToken: true, defecto: 'No se pudo descartar el producto');
  }
}