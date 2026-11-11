import 'package:frontend/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MenuItem {
  final String id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int? stock;
  final String? imagenUrl;
  final String? categoria;
  final String? ingredientes;
  final bool disponible;

  MenuItem({required this.id, required this.nombre, this.descripcion, required this.precio, this.stock, this.imagenUrl, this.categoria, this.ingredientes, this.disponible = true});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'],
      imagenUrl: json['imagen_url'],
      categoria: json['categoria'],
      ingredientes: json['ingredientes'] is String ? json['ingredientes'] as String : null,
      // Mientras la columna no exista en la base, el campo llega ausente y
      // el plato se toma como disponible.
      disponible: json['disponible'] != false,
    );
  }
}

class MenuService {
  final ApiClient _api = ApiClient.I;

  // GET /menu/menu (público, no requiere token)
  // soloDisponibles oculta los platos que el admin marcó como agotados.
  Future<List<MenuItem>> obtenerMenu({bool soloDisponibles = false}) async {
    final data = await _api.getJson(
      '/menu/menu${soloDisponibles ? '?disponibles=true' : ''}',
      defecto: 'No se pudo cargar el menú',
    );
    return (data as List).map((e) => MenuItem.fromJson(e)).toList();
  }

  // GET /menu/version (público): huella que cambia cuando el admin edita el
  // menú. Se sondea para refrescar la pantalla sin bajar todo el menú.
  // Sin reintentos: es un sondeo silencioso, si falla se prueba al siguiente.
  Future<String?> obtenerVersion() async {
    try {
      final data = await _api.getJson('/menu/version', reintentar: false);
      return data['version']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _enviar(String metodo, String ruta, Map<String, String> campos, XFile? foto, String falla) async {
    await _api.multipart(
      metodo,
      ruta,
      campos: campos,
      archivos: [
        if (foto != null) http.MultipartFile.fromBytes('imagen', await foto.readAsBytes(), filename: foto.name),
      ],
      defecto: falla,
    );
  }

  // POST /menu/crear_menu (admin) con parámetro de categoría incluido
  Future<void> crearPlato({
    required String nombre,
    required String descripcion,
    required int precio,
    required String categoria,
    required XFile foto,
    String? ingredientes,
  }) {
    return _enviar(
      'POST',
      '/menu/crear_menu',
      _camposPlato(nombre: nombre, descripcion: descripcion, precio: precio, categoria: categoria, ingredientes: ingredientes),
      foto,
      'No se pudo crear el plato'
    );
  }

  // PUT /menu/menu/:id (admin) con parámetro de categoría incluido
  Future<void> actualizarPlato({
    required String id,
    required String nombre,
    required String descripcion,
    required int precio,
    required String categoria,
    XFile? foto,
    String? ingredientes,
  }) {
    return _enviar(
      'PUT',
      '/menu/menu/$id',
      _camposPlato(nombre: nombre, descripcion: descripcion, precio: precio, categoria: categoria, ingredientes: ingredientes),
      foto,
      'No se pudo actualizar el plato'
    );
  }

  Map<String, String> _camposPlato({
    required String nombre,
    required String descripcion,
    required int precio,
    required String categoria,
    String? ingredientes,
  }) {
    final campos = {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': '$precio',
      'categoria': categoria.toLowerCase().trim(),
    };
    final ings = (ingredientes ?? '').trim();
    if (ings.isNotEmpty) campos['ingredientes'] = ings;
    return campos;
  }

  // DELETE /menu/menu/:id (admin): borrado permanente. El backend retira las
  // líneas de detalle de pedido que referencian al plato antes de borrarlo, así
  // un plato que ya tiene pedidos registrados sí se puede eliminar del menú.
  Future<String> eliminarPlato(String id) async {
    final data = await _api.deleteJson('/menu/menu/$id', conToken: true, defecto: 'No se pudo eliminar el plato');
    return (data is Map ? data['message']?.toString() : null) ?? 'Plato eliminado';
  }

  // PATCH /menu/menu/:id/disponible (admin): agota o reactiva un plato sin
  // borrarlo del menú.
  Future<String> marcarDisponibilidad(String id, bool disponible) async {
    final data = await _api.patchJson(
      '/menu/menu/$id/disponible',
      cuerpo: {'disponible': disponible},
      conToken: true,
      defecto: 'No se pudo cambiar la disponibilidad',
    );
    return (data is Map ? data['message']?.toString() : null) ?? (disponible ? 'Plato habilitado' : 'Plato agotado');
  }
}
