import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

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
  final ApiClient _api = ApiClient.I;

  // GET /pedido/reporte-rango?desde=&hasta= — única fuente de los reportes.
  // El rango lo calcula el teléfono: si lo calculara el servidor, el día se
  // cortaría a las 19:00 de Colombia (medianoche UTC en Render).
  // Solo entran los pedidos ENTREGADOS: la venta cuenta al entregar.
  Future<ReporteVentas> obtenerReporteHoy() {
    final hoy = DateTime.now();
    return obtenerReporteRango(
      DateTime(hoy.year, hoy.month, hoy.day),
      DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59),
    );
  }

  Future<ReporteVentas> obtenerReporteRango(DateTime desde, DateTime hasta) async {
    final data = await _api.getJson(
      '/pedido/reporte-rango?desde=${desde.toUtc().toIso8601String()}&hasta=${hasta.toUtc().toIso8601String()}',
      conToken: true,
      defecto: 'No se pudo obtener el reporte',
    );
    return ReporteVentas.fromJson(data);
  }

  // GET /pedido/en-proceso -> pedidos abiertos con sus productos
  Future<List<PedidoProceso>> obtenerPedidosEnProceso() async {
    final data = await _api.getJson('/pedido/en-proceso', conToken: true, defecto: 'No se pudieron cargar los pedidos');
    return ((data['pedidos'] as List?) ?? []).map((e) => PedidoProceso.fromJson(e)).toList();
  }

  // PATCH /pedido/:id/estado  { estado }
  Future<void> cambiarEstado(String id, String estado) {
    return _api.patchJson('/pedido/$id/estado', cuerpo: {'estado': estado}, conToken: true, defecto: 'No se pudo cambiar el estado');
  }
}