/// Estados que el admin puede elegir. Clave = valor guardado en la BD,
/// valor = texto que se ve. Si tu tabla usa otros textos, cámbialos aquí.
const Map<String, String> estadosPedido = {
  'pendiente': 'Pendiente',
  'en_proceso': 'En proceso',
  'listo': 'Listo',
  'entregado': 'Entregado',
  'cancelado': 'Cancelado',
};

/// Estados que sacan al pedido de la lista "en proceso".
const Set<String> estadosFinales = {'entregado', 'cancelado'};

class ItemPedido {
  final int cantidad;
  final String nombre;
  final double subtotal;

  ItemPedido({required this.cantidad, required this.nombre, required this.subtotal});

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      nombre: (json['menu'] is Map ? json['menu']['nombre'] : null) ?? 'Producto',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PedidoProceso {
  final String id;
  final String estado;
  final String? mesa;
  final String? direccion;
  final String? telefono;
  final String? notas;
  final String? fecha;
  final double total;
  final List<ItemPedido> items;

  PedidoProceso({
    required this.id,
    required this.estado,
    required this.total,
    required this.items,
    this.mesa,
    this.direccion,
    this.telefono,
    this.notas,
    this.fecha,
  });

  factory PedidoProceso.fromJson(Map<String, dynamic> json) {
    final detalles = (json['detalles'] as List?) ?? [];
    return PedidoProceso(
      id: json['id'].toString(),
      estado: (json['estado'] ?? 'pendiente').toString(),
      mesa: json['mesa']?.toString(),
      direccion: json['direccion_entrega']?.toString(),
      telefono: json['telefono']?.toString(),
      notas: json['notas']?.toString(),
      fecha: json['fecha_pedido']?.toString(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      items: detalles.map((d) => ItemPedido.fromJson(d)).toList(),
    );
  }

  PedidoProceso copyWith({String? estado}) {
    return PedidoProceso(
      id: id, estado: estado ?? this.estado, total: total, items: items,
      mesa: mesa, direccion: direccion, telefono: telefono, notas: notas, fecha: fecha,
    );
  }

  // Número de mesa: viene de la columna "mesa", o de una dirección tipo "Mesa 6".
  String? get _numeroMesa {
    if (mesa != null && mesa!.trim().isNotEmpty) {
      return mesa!.replaceFirst(RegExp(r'^\s*mesa\s*', caseSensitive: false), '').trim();
    }
    final m = RegExp(r'^\s*mesa\s*(\S+)', caseSensitive: false).firstMatch(direccion ?? '');
    return m?.group(1);
  }

  /// Primera línea de la tarjeta: "Mesa" o "Pedido".
  String get cabecera => _numeroMesa != null ? 'Mesa' : 'Pedido';

  /// Segunda línea: el número de mesa, o "#id" si no es de mesa.
  String get numero => _numeroMesa ?? '#${id.length > 6 ? id.substring(0, 6) : id}';

  String get hora {
    final d = DateTime.tryParse(fecha ?? '')?.toLocal();
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}