import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class MenuItem {
  final String id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int? stock;
  final String? imagenUrl;
  final String? categoria;

  MenuItem({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.stock,
    this.imagenUrl,
    this.categoria,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'],
      imagenUrl: json['imagen_url'],
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagen_url': imagenUrl,
      'categoria': categoria,
    };
  }
}

class MenuService {
  // -------------------------------------------------------------
  // PÚBLICO (no requiere token) - para la pantalla del cliente
  // -------------------------------------------------------------

  // GET /menu/menu
  Future<List<MenuItem>> obtenerMenu() async {
    final url = Uri.parse('${ApiConfig.rootUrl}/menu/menu');
    try {
      final response = await http.get(url, headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);
        return lista.map((item) => MenuItem.fromJson(item)).toList();
      }
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'No se pudo cargar el menú');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // GET /menu/menu/categoria/:categoria
  Future<List<MenuItem>> obtenerMenuPorCategoria(String categoria) async {
    final url = Uri.parse('${ApiConfig.rootUrl}/menu/menu/categoria/$categoria');
    try {
      final response = await http.get(url, headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);
        return lista.map((item) => MenuItem.fromJson(item)).toList();
      }
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'No se pudo cargar el menú');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // -------------------------------------------------------------
  // ADMIN (requiere token + rol 'admin' en el backend)
  // -------------------------------------------------------------

  Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isEmpty) {
      throw Exception('No hay sesión activa, inicia sesión de nuevo');
    }
    return token;
  }

  // POST /menu/crear_menu
  Future<MenuItem> crearPlato({
    required String nombre,
    required String descripcion,
    required double precio,
    required String imagenUrl,
    String? categoria,
    int? stock,
  }) async {
    final token = await _obtenerToken();
    final url = Uri.parse('${ApiConfig.rootUrl}/menu/crear_menu');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headersConToken(token),
        body: jsonEncode({
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'imagen_url': imagenUrl,
          'categoria': categoria,
          'stock': stock,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return MenuItem.fromJson(data['menu']);
      }
      throw Exception(data['error'] ?? 'No se pudo crear el plato');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // PUT /menu/menu/:id
  Future<MenuItem> actualizarPlato({
    required String id,
    required String nombre,
    required String descripcion,
    required double precio,
    required String imagenUrl,
    String? categoria,
    int? stock,
  }) async {
    final token = await _obtenerToken();
    final url = Uri.parse('${ApiConfig.rootUrl}/menu/menu/$id');

    try {
      final response = await http.put(
        url,
        headers: ApiConfig.headersConToken(token),
        body: jsonEncode({
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'imagen_url': imagenUrl,
          'categoria': categoria,
          'stock': stock,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return MenuItem.fromJson(data['menu']);
      }
      throw Exception(data['error'] ?? 'No se pudo actualizar el plato');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // DELETE /menu/menu/:id
  Future<String> eliminarPlato(String id) async {
    final token = await _obtenerToken();
    final url = Uri.parse('${ApiConfig.rootUrl}/menu/menu/$id');

    try {
      final response = await http.delete(
        url,
        headers: ApiConfig.headersConToken(token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['message'] ?? 'Plato eliminado';
      }
      throw Exception(data['error'] ?? 'No se pudo eliminar el plato');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}