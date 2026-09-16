import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ReporteVentas {
  final String tipo;
  final double totalVentas;
  final int cantidadPedidos;
  final List<dynamic> pedidos;

  ReporteVentas({
    required this.tipo,
    required this.totalVentas,
    required this.cantidadPedidos,
    required this.pedidos,
  });

  factory ReporteVentas.fromJson(Map<String, dynamic> json) {
    return ReporteVentas(
      tipo: json['tipo'] ?? '',
      totalVentas: (json['totalVentas'] as num?)?.toDouble() ?? 0.0,
      cantidadPedidos: json['cantidadPedidos'] ?? 0,
      pedidos: json['pedidos'] ?? [],
    );
  }
}

class PedidoService {
  // GET /pedido/reporte?tipo=diaria|semanal|mensual
  // Requiere token de admin (verificarToken + verificarAdmin en el backend)
  Future<ReporteVentas> obtenerReporteVentas(String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    if (token.isEmpty) {
      throw Exception('No hay sesión activa, inicia sesión de nuevo');
    }

    final url = Uri.parse('${ApiConfig.rootUrl}/pedido/reporte?tipo=$tipo');

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.headersConToken(token),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ReporteVentas.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'No se pudo obtener el reporte');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}