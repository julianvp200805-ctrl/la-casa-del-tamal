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

  // POST /producto/crearProducto. Solo se elige el tipo: la fecha de ingreso
  // se fija al día en que se registra y el código de lote (LT001, LT002...
  // por tipo) los asigna el backend. Devuelve el aviso con lote y vencimiento.
  Future<String> crearProducto({required Object idTipo}) async {
    final data = await _api.postJson(
      '/producto/crearProducto',
      {'id_tipo': idTipo},
      conToken: true,
      defecto: 'No se pudo guardar el producto',
    );
    return data is Map ? (data['aviso']?.toString() ?? 'Producto guardado') : 'Producto guardado';
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

  // DELETE /producto/eliminar/:id (sacar un lote vencido del inventario; su
  // número de lote queda libre para el próximo ingreso)
  Future<void> eliminarProducto(Object id) {
    return _api.deleteJson('/producto/eliminar/$id', conToken: true, defecto: 'No se pudo sacar el producto');
  }
}