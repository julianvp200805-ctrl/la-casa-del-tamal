class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final String tipo;
  final double precio;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.tipo,
    required this.precio,
  });

  factory Producto.fromJson(Map<String, dynamic> j) => Producto(
        id: '${j['id']}',
        nombre: (j['nombre'] ?? '').toString(),
        descripcion: (j['descripcion'] ?? '').toString(),
        imagenUrl: (j['imagen_url'] ?? j['imagen'] ?? '').toString(),
        tipo: (j['tipo'] ?? '').toString(),
        precio: double.tryParse('${j['precio'] ?? 0}') ?? 0,
      );
}