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

/// Código de lote tal como se muestra en la app: el backend guarda
/// "T{id_tipo}-LT001" porque codigo_lote es la clave primaria de la tabla y
/// debe ser único en toda ella; aquí se le quita el prefijo interno para que
/// el lote se vea como LT001 en cada producto.
String _loteVisible(String codigo) {
  final i = codigo.indexOf('-LT');
  return i >= 0 ? codigo.substring(i + 1) : codigo;
}

/// Un lote de producto del inventario. El nombre viene de su tipo, la fecha
/// de ingreso es el día en que se registró el lote y la de vencimiento la
/// calcula el backend (ingreso + días del tipo).
class Producto {
  final Object id;
  final String nombre;
  final String lote;
  final DateTime? ingreso;
  final DateTime? vencimiento;

  Producto({required this.id, required this.nombre, required this.lote, this.ingreso, this.vencimiento});

  factory Producto.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipos_producto'];
    return Producto(
      id: json['id_producto'] ?? '',
      nombre: ((tipo is Map ? tipo['nombre'] : null) ?? 'Producto').toString(),
      lote: _loteVisible((json['codigo_lote'] ?? '').toString()),
      ingreso: DateTime.tryParse((json['fecha_ingreso'] ?? '').toString()),
      vencimiento: DateTime.tryParse((json['fecha_vencimiento'] ?? '').toString()),
    );
  }

  bool get vencido => vencimiento != null && vencimiento!.isBefore(_hoy());

  bool get porVencer => !vencido && vencimiento != null && vencimiento!.difference(_hoy()).inDays <= 3;
}