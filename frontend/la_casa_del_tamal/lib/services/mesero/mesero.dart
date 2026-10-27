import 'dart:convert';
import 'package:frontend/services/api_response.dart';
import 'package:frontend/services/config/api_config.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


/// Acciones del mesero: tomar pedido, ver el estado de sus pedidos y
/// marcarlos como entregados cuando la cocina los deja "listos".
class MeseroService {
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

  // POST /pedido/mesero  { mesa, items: [{ menu_id, cantidad }] }
  // El precio lo calcula el backend con los datos del menú.
  Future<void> crearPedido({required String mesa, required Map<String, int> cantidades}) => _seguro(() async {
        final items = [
          for (final e in cantidades.entries)
            if (e.value > 0) {'menu_id': e.key, 'cantidad': e.value},
        ];
        final r = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/pedido/mesero'),
          headers: await _headers(),
          body: jsonEncode({'mesa': mesa, 'items': items}),
        );
        _resolver(r, 'No se pudo enviar el pedido');
      });

  // GET /pedido/mesero/abiertos -> mis pedidos que aún no entrego
  Future<List<PedidoProceso>> obtenerAbiertos() => _seguro(() async {
        final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/pedido/mesero/abiertos'), headers: await _headers());
        final data = _resolver(r, 'No se pudieron cargar tus pedidos');
        return ((data['pedidos'] as List?) ?? []).map((e) => PedidoProceso.fromJson(e)).toList();
      });

  // PATCH /pedido/:id/entregar (solo si la cocina lo dejó "listo")
  Future<void> entregar(String id) => _seguro(() async {
        final r = await http.patch(Uri.parse('${ApiConfig.baseUrl}/pedido/$id/entregar'), headers: await _headers());
        _resolver(r, 'No se pudo marcar como entregado');
      });
}