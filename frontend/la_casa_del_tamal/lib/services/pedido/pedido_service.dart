import 'dart:convert';
import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/services/api_response.dart';
import 'package:frontend/services/config/api_config.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReporteVentas {
  final double totalVentas;
  final int cantidadPedidos;
  final List<ItemVenta> itemsAgrupados;

  ReporteVentas({required this.totalVentas, required this.cantidadPedidos, required this.itemsAgrupados});

  factory ReporteVentas.fromJson(Map<String, dynamic> json) {
    final itemsRaw = (json['itemsAgrupados'] as List?) ?? [];
    return ReporteVentas(
      totalVentas: (json['totalVentas'] as num?)?.toDouble() ?? 0.0,
      cantidadPedidos: json['cantidadPedidos'] ?? 0,
      itemsAgrupados: itemsRaw.map((e) => ItemVenta.fromJson(e)).toList(),
    );
  }
}

class PedidoService {
  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isEmpty) throw Exception('No hay sesión activa, inicia sesión de nuevo');
    return token;
  }

  // GET /pedido/reporte-rango?desde=&hasta= — única fuente de los reportes.
  // El rango lo calcula el teléfono: si lo calculara el servidor, el día se
  // cortaría a las 19:00 de Colombia (medianoche UTC en Render).
  Future<ReporteVentas> obtenerReporteHoy() {
    final hoy = DateTime.now();
    return obtenerReporteRango(
      DateTime(hoy.year, hoy.month, hoy.day),
      DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59),
    );
  }

  Future<ReporteVentas> obtenerReporteRango(DateTime desde, DateTime hasta) async {
    final token = await _token();
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pedido/reporte-rango?desde=${desde.toUtc().toIso8601String()}&hasta=${hasta.toUtc().toIso8601String()}',
    );
    return _pedir(url, token);
  }

  // GET /pedido/en-proceso -> pedidos abiertos con sus productos
  Future<List<PedidoProceso>> obtenerPedidosEnProceso() async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/pedido/en-proceso');
    try {
      final response = await http.get(url, headers: ApiConfig.headersConToken(token));
      final Map<String, dynamic> data = decodeApiResponse(response);
      if (response.statusCode == 200) {
        return ((data['pedidos'] as List?) ?? []).map((e) => PedidoProceso.fromJson(e)).toList();
      }
      throw Exception(data['error'] ?? 'No se pudieron cargar los pedidos');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // PATCH /pedido/:id/estado  { estado }
  Future<void> cambiarEstado(String id, String estado) async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/pedido/$id/estado');
    try {
      final response = await http.patch(url, headers: ApiConfig.headersConToken(token), body: jsonEncode({'estado': estado}));
      if (response.statusCode == 200) return;
      final Map<String, dynamic> data = decodeApiResponse(response);
      throw Exception(data['error'] ?? 'No se pudo cambiar el estado');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<ReporteVentas> _pedir(Uri url, String token) async {
    try {
      final response = await http.get(url, headers: ApiConfig.headersConToken(token));
      final Map<String, dynamic> data = decodeApiResponse(response);
      if (response.statusCode == 200) return ReporteVentas.fromJson(data);
      throw Exception(data['error'] ?? 'No se pudo obtener el reporte');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}