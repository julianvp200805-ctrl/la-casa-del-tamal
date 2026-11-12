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

  /// Indicación del mesero para la cocina ("sin mayonesa"), vacía si no hubo.
  final String nota;

  ItemPedido({required this.cantidad, required this.nombre, required this.subtotal, this.nota = ''});

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      nombre: (json['menu'] is Map ? json['menu']['nombre'] : null) ?? 'Producto',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      nota: (json['nota'] ?? '').toString().trim(),
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
    final d = DateTime.tryParse(fecha ?? '');
    if (d == null) return '';
    // El backend corre en Render/Supabase (UTC): la fecha del pedido siempre
    // es un instante UTC, con o sin "Z". Se convierte a Colombia (UTC-5) para
    // mostrarla correctamente con AM/PM.
    final utc = d.isUtc ? d : DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second, d.millisecond);
    final colombia = utc.subtract(const Duration(hours: 5));
    final periodo = colombia.hour < 12 ? 'AM' : 'PM';
    final hora12 = colombia.hour % 12 == 0 ? 12 : colombia.hour % 12;
    return '${hora12.toString()}:${colombia.minute.toString().padLeft(2, '0')} $periodo';
  }
}