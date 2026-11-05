/// Mesas del salón: son 13 y cada una tiene un cupo fijo de 4 a 6 personas.
/// Lo comparte el mesero (al tomar el pedido) y la cocina (en la bandeja)
/// para que el número que ve uno sea el mismo que ve el otro.
const int totalMesas = 13;

int cupoMesa(int mesa) => 4 + (mesa % 3);

/// "3" -> 3, "Mesa 3" -> 3, null o texto -> null.
int? mesaNumero(Object? valor) {
  if (valor == null) return null;
  final texto = '$valor';
  final m = RegExp(r'(\d+)').firstMatch(texto);
  return m == null ? null : int.tryParse(m.group(1)!);
}
