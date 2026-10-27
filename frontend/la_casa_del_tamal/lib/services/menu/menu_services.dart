import 'dart:convert';
import 'package:frontend/services/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MenuItem {
  final String id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int? stock;
  final String? imagenUrl;
  final String? categoria;

  MenuItem({required this.id, required this.nombre, this.descripcion, required this.precio, this.stock, this.imagenUrl, this.categoria});

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
}

class MenuService {
  // GET /menu/menu (público, no requiere token)
  Future<List<MenuItem>> obtenerMenu() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.rootUrl}/menu/menu'), headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List).map((e) => MenuItem.fromJson(e)).toList();
      }
      throw Exception(jsonDecode(response.body)['error'] ?? 'No se pudo cargar el menú');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isEmpty) throw Exception('No hay sesión activa, inicia sesión de nuevo');
    return token;
  }

  // Envía el plato como multipart: el backend (multer + Cloudinary) recibe el
  // archivo en el campo "imagen" y guarda en la BD la URL que devuelve Cloudinary.
  Future<void> _enviar(String metodo, String ruta, Map<String, String> campos, XFile? foto, String falla) async {
    try {
      final req = http.MultipartRequest(metodo, Uri.parse('${ApiConfig.rootUrl}$ruta'))
        ..headers['Authorization'] = 'Bearer ${await _token()}'
        ..fields.addAll(campos);
      if (foto != null) {
        req.files.add(http.MultipartFile.fromBytes('imagen', await foto.readAsBytes(), filename: foto.name));
      }
      final response = await http.Response.fromStream(await req.send());
      if (response.statusCode >= 200 && response.statusCode < 300) return;
      String? msg;
      try {
        msg = jsonDecode(response.body)['error']?.toString();
      } catch (_) {}
      throw Exception(msg ?? falla);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // POST /menu/crear_menu (admin). La foto es obligatoria.
  Future<void> crearPlato({required String nombre, required String descripcion, required int precio, required XFile foto}) {
    return _enviar('POST', '/menu/crear_menu', {'nombre': nombre, 'descripcion': descripcion, 'precio': '$precio'}, foto, 'No se pudo crear el plato');
  }

  // PUT /menu/menu/:id (admin). Sin foto nueva se conserva la anterior.
  Future<void> actualizarPlato({required String id, required String nombre, required String descripcion, required int precio, XFile? foto}) {
    return _enviar('PUT', '/menu/menu/$id', {'nombre': nombre, 'descripcion': descripcion, 'precio': '$precio'}, foto, 'No se pudo actualizar el plato');
  }

  // DELETE /menu/menu/:id (admin)
  Future<String> eliminarPlato(String id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.rootUrl}/menu/menu/$id'), headers: ApiConfig.headersConToken(await _token()));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data['message'] ?? 'Plato eliminado';
      throw Exception(data['error'] ?? 'No se pudo eliminar el plato');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}