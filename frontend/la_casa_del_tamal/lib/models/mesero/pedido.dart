class PedidoItem {
  final String nombre;
  final int cantidad;

  const PedidoItem({required this.nombre, required this.cantidad});

  factory PedidoItem.fromJson(Map<String, dynamic> j) => PedidoItem(
        nombre: (j['nombre'] ?? j['producto']?['nombre'] ?? '').toString(),
        cantidad: int.tryParse('${j['cantidad'] ?? 1}') ?? 1,
      );
}

class Pedido {
  final String id;
  final int mesa;
  final int personas;
  final String estado;
  final List<PedidoItem> items;
  final double total;

  const Pedido({
    required this.id,
    required this.mesa,
    required this.personas,
    required this.estado,
    required this.items,
    required this.total,
  });

  factory Pedido.fromJson(Map<String, dynamic> j) {
    final lista = (j['items'] ?? j['detalles'] ?? []) as List;
    return Pedido(
      id: '${j['id']}',
      mesa: int.tryParse('${j['mesa'] ?? j['mesa_numero'] ?? 0}') ?? 0,
      personas: int.tryParse('${j['personas'] ?? 0}') ?? 0,
      estado: (j['estado'] ?? 'en_proceso').toString(),
      items: lista.map((e) => PedidoItem.fromJson(e)).toList(),
      total: double.tryParse('${j['total'] ?? 0}') ?? 0,
    );
  }
}