import 'dart:convert';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/services/api_response.dart';
import 'package:frontend/services/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


/// Inventario: productos y tipos de producto (rutas solo para admin).
class ProductoService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isEmpty) throw Exception('No hay sesión activa, inicia sesión de nuevo');
    return ApiConfig.headersConToken(token);
  }

  // Devuelve el JSON si la respuesta fue exitosa; si no, lanza el error del backend.
  dynamic _resolver(http.Response r, String defecto) {
    dynamic data;
    try {
      data = decodeApiResponse(r);
    } catch (_) {
      data = null;
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return data;
    final msg = data is Map ? (data['error'] ?? data['message']) : null;
    throw Exception(msg?.toString() ?? defecto);
  }

  Future<T> _seguro<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // GET /producto/obtener
  Future<List<Producto>> obtenerProductos() => _seguro(() async {
        final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/producto/obtener'), headers: await _headers());
        final data = _resolver(r, 'No se pudieron cargar los productos');
        return (data as List).map((e) => Producto.fromJson(e)).toList();
      });

  // GET /tipoProducto/obtener_tipos
  Future<List<TipoProducto>> obtenerTipos() => _seguro(() async {
        final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/tipoProducto/obtener_tipos'), headers: await _headers());
        final data = _resolver(r, 'No se pudieron cargar los tipos de producto');
        return (data as List).map((e) => TipoProducto.fromJson(e)).toList();
      });

  // POST /producto/crearProducto (el backend calcula el vencimiento)
  Future<void> crearProducto({required Object idTipo, required String fechaIngreso, required String lote}) => _seguro(() async {
        final r = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/producto/crearProducto'),
          headers: await _headers(),
          body: jsonEncode({'id_tipo': idTipo, 'fecha_ingreso': fechaIngreso, 'codigo_lote': lote}),
        );
        _resolver(r, 'No se pudo guardar el producto');
      });

  // POST /tipoProducto/crear_tipo
  Future<TipoProducto> crearTipo({required String nombre, required int dias}) => _seguro(() async {
        final r = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/tipoProducto/crear_tipo'),
          headers: await _headers(),
          body: jsonEncode({'nombre': nombre, 'dias_vencimiento': dias}),
        );
        final data = _resolver(r, 'No se pudo crear el tipo de producto');
        return TipoProducto.fromJson(data['data']);
      });

  // DELETE /producto/eliminar/:id (descartar un producto vencido)
  Future<void> eliminarProducto(Object id) => _seguro(() async {
        final r = await http.delete(Uri.parse('${ApiConfig.baseUrl}/producto/eliminar/$id'), headers: await _headers());
        _resolver(r, 'No se pudo descartar el producto');
      });
}