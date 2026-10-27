/// Tipo de producto (carne, papas...) y cuántos días dura antes de vencer.
class TipoProducto {
  final Object id;
  final String nombre;
  final int dias;

  TipoProducto({required this.id, required this.nombre, required this.dias});

  factory TipoProducto.fromJson(Map<String, dynamic> json) {
    return TipoProducto(
      id: json['id_tipo'] ?? '',
      nombre: (json['nombre'] ?? '').toString(),
      dias: (json['dias_vencimiento'] as num?)?.toInt() ?? 0,
    );
  }
}

DateTime _hoy() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// 3-05-2026 (día sin cero a la izquierda, mes con dos dígitos).
String fechaCorta(DateTime? d) => d == null ? '—' : '${d.day}-${d.month.toString().padLeft(2, '0')}-${d.year}';

/// Un lote de producto del inventario. El nombre viene de su tipo y la fecha
/// de vencimiento la calcula el backend (ingreso + días del tipo).
class Producto {
  final Object id;
  final String nombre;
  final String lote;
  final DateTime? vencimiento;

  Producto({required this.id, required this.nombre, required this.lote, this.vencimiento});

  factory Producto.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipos_producto'];
    return Producto(
      id: json['id_producto'] ?? '',
      nombre: ((tipo is Map ? tipo['nombre'] : null) ?? 'Producto').toString(),
      lote: (json['codigo_lote'] ?? '').toString(),
      vencimiento: DateTime.tryParse((json['fecha_vencimiento'] ?? '').toString()),
    );
  }

  bool get vencido => vencimiento != null && vencimiento!.isBefore(_hoy());

  bool get porVencer => !vencido && vencimiento != null && vencimiento!.difference(_hoy()).inDays <= 3;
}