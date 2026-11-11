import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

/// Acciones del mesero: tomar pedido, ver el estado de sus pedidos y
/// marcarlos como entregados cuando la cocina los deja "listos".
class MeseroService {
  final ApiClient _api = ApiClient.I;

  // POST /pedido/mesero  { mesa, items: [{ menu_id, cantidad, nota }] }
  // El precio lo calcula el backend con los datos del menú. `notas` lleva la
  // indicación por plato que el mesero escribe con el lápiz ("sin cebolla").
  Future<void> crearPedido({required String mesa, required Map<String, int> cantidades, Map<String, String> notas = const {}}) async {
    final items = [
      for (final e in cantidades.entries)
        if (e.value > 0)
          {
            'menu_id': e.key,
            'cantidad': e.value,
            if ((notas[e.key] ?? '').trim().isNotEmpty) 'nota': notas[e.key]!.trim(),
          },
    ];
    await _api.postJson('/pedido/mesero', {'mesa': mesa, 'items': items}, conToken: true, defecto: 'No se pudo enviar el pedido');
  }

  // GET /pedido/mesero/abiertos -> mis pedidos que aún no entrego
  Future<List<PedidoProceso>> obtenerAbiertos() async {
    final data = await _api.getJson('/pedido/mesero/abiertos', conToken: true, defecto: 'No se pudieron cargar tus pedidos');
    return ((data['pedidos'] as List?) ?? []).map((e) => PedidoProceso.fromJson(e)).toList();
  }

  // GET /pedido/cocina/abiertos -> TODOS los pedidos abiertos (bandeja de cocina)
  Future<List<PedidoProceso>> obtenerAbiertosCocina() async {
    final data = await _api.getJson('/pedido/cocina/abiertos', conToken: true, defecto: 'No se pudieron cargar los pedidos de cocina');
    return ((data['pedidos'] as List?) ?? []).map((e) => PedidoProceso.fromJson(e)).toList();
  }

  // PATCH /pedido/:id/estado { estado } -> cocina: pendiente->en_proceso->listo
  Future<void> cambiarEstado(String id, String estado) {
    return _api.patchJson('/pedido/$id/estado', cuerpo: {'estado': estado}, conToken: true, defecto: 'No se pudo actualizar el estado');
  }

  // PATCH /pedido/:id/entregar (solo si la cocina lo dejó "listo").
  // Aquí es cuando la venta queda registrada en el reporte.
  Future<void> entregar(String id) {
    return _api.patchJson('/pedido/$id/entregar', conToken: true, defecto: 'No se pudo marcar como entregado');
  }
}