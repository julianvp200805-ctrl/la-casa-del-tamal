import 'dart:convert';

import 'package:frontend/services/api_response.dart';
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

/// El admin intentó borrar un plato que ya tiene pedidos: la base de datos
/// no lo permite para no romper el historial. La alternativa es descontinuarlo.
class PlatoConPedidosException implements Exception {
  final String mensaje;
  PlatoConPedidosException(this.mensaje);
  @override
  String toString() => mensaje;
}

class MenuService {
  // GET /menu/menu (público, no requiere token)
  // soloDisponibles oculta los platos que el admin marcó como agotados.
  Future<List<MenuItem>> obtenerMenu({bool soloDisponibles = false}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/menu/menu${soloDisponibles ? '?disponibles=true' : ''}');
      final response = await http.get(url, headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        return (decodeApiResponse(response) as List).map((e) => MenuItem.fromJson(e)).toList();
      }
      throw Exception(decodeApiResponse(response)['error'] ?? 'No se pudo cargar el menú');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // GET /menu/version (público): huella que cambia cuando el admin edita el
  // menú. Se sondea para refrescar la pantalla sin bajar todo el menú.
  Future<String?> obtenerVersion() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/menu/version'), headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        return decodeApiResponse(response)['version']?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isEmpty) throw Exception('No hay sesión activa, inicia sesión de nuevo');
    return token;
  }

  Future<void> _enviar(String metodo, String ruta, Map<String, String> campos, XFile? foto, String falla) async {
    try {
      final req = http.MultipartRequest(metodo, Uri.parse('${ApiConfig.baseUrl}$ruta'))
        ..headers['Authorization'] = 'Bearer ${await _token()}'
        ..fields.addAll(campos);
      if (foto != null) {
        req.files.add(http.MultipartFile.fromBytes('imagen', await foto.readAsBytes(), filename: foto.name));
      }
      final response = await http.Response.fromStream(await req.send());
      if (response.statusCode >= 200 && response.statusCode < 300) return;
      throw Exception(mensajeDeRespuesta(response) ?? '$falla (HTTP ${response.statusCode})');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
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

  // DELETE /menu/menu/:id (admin)
  Future<String> eliminarPlato(String id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/menu/menu/$id'), headers: ApiConfig.headersConToken(await _token()));
      final mensaje = mensajeDeRespuesta(response);
      if (response.statusCode == 200) return mensaje ?? 'Plato eliminado';
      if (response.statusCode == 409) throw PlatoConPedidosException(mensaje ?? 'El plato tiene pedidos y no se puede borrar');
      throw Exception(mensaje ?? 'No se pudo eliminar el plato (HTTP ${response.statusCode})');
    } on PlatoConPedidosException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // PATCH /menu/menu/:id/disponible (admin): agota o reactiva un plato sin
  // borrarlo del menú.
  Future<String> marcarDisponibilidad(String id, bool disponible) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/menu/menu/$id/disponible'),
        headers: ApiConfig.headersConToken(await _token()),
        body: jsonEncode({'disponible': disponible}),
      );
      final mensaje = mensajeDeRespuesta(response);
      if (response.statusCode == 200) return mensaje ?? (disponible ? 'Plato habilitado' : 'Plato agotado');
      throw Exception(mensaje ?? 'No se pudo cambiar la disponibilidad (HTTP ${response.statusCode})');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
