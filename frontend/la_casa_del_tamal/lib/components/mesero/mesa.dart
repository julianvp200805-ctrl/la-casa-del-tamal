class Mesa {
  final int numero;
  final int capacidad;

  const Mesa({required this.numero, required this.capacidad});

  factory Mesa.fromJson(Map<String, dynamic> j) => Mesa(
        numero: int.tryParse('${j['numero'] ?? j['id']}') ?? 0,
        capacidad: int.tryParse('${j['capacidad'] ?? j['personas'] ?? 0}') ?? 0,
      );
}