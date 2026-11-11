import 'dart:async';
import 'dart:convert';

import 'package:frontend/services/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Error con un mensaje listo para mostrar al usuario (sin "Exception:").
class ApiException implements Exception {
  final String mensaje;
  final int? codigo;

  ApiException(this.mensaje, {this.codigo});

  @override
  String toString() => mensaje;
}

/// Único punto de conexión con el backend.
/// - Timeout de 30 s por petición (Render gratuito despierta lento).
/// - Los GET reintentan hasta 3 veces (1 s y 2 s de espera) ante caídas,
///   timeouts o errores 5xx: cubre el arranque en frío de Render.
/// - POST/PATCH/PUT/DELETE NUNCA se reintentan: repetirlos duplicaría
///   pedidos, registros o entregas.
class ApiClient {
  ApiClient._();

  static final ApiClient I = ApiClient._();

  final http.Client _http = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  Future<Map<String, String>> _headers(bool conToken) async {
    final headers = {...ApiConfig.headers};
    if (conToken) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      if (token.isEmpty) {
        throw ApiException('No hay sesión activa, inicia sesión de nuevo', codigo: 401);
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> getJson(String ruta, {bool conToken = false, bool reintentar = true, String defecto = 'No se pudo completar la solicitud'}) {
    return _enviar('GET', ruta, conToken: conToken, defecto: defecto, reintentar: reintentar);
  }

  Future<dynamic> postJson(String ruta, Object cuerpo, {bool conToken = false, String defecto = 'No se pudo completar la solicitud'}) {
    return _enviar('POST', ruta, cuerpo: cuerpo, conToken: conToken, defecto: defecto);
  }

  Future<dynamic> patchJson(String ruta, {Object? cuerpo, bool conToken = false, String defecto = 'No se pudo completar la solicitud'}) {
    return _enviar('PATCH', ruta, cuerpo: cuerpo, conToken: conToken, defecto: defecto);
  }

  Future<dynamic> putJson(String ruta, Object cuerpo, {bool conToken = false, String defecto = 'No se pudo completar la solicitud'}) {
    return _enviar('PUT', ruta, cuerpo: cuerpo, conToken: conToken, defecto: defecto);
  }

  Future<dynamic> deleteJson(String ruta, {bool conToken = false, String defecto = 'No se pudo completar la solicitud'}) {
    return _enviar('DELETE', ruta, conToken: conToken, defecto: defecto);
  }

  /// Subida con archivos (foto del plato). Sin reintento: es un POST/PUT.
  Future<dynamic> multipart(String metodo, String ruta, {required Map<String, String> campos, List<http.MultipartFile> archivos = const [], String defecto = 'No se pudo completar la solicitud'}) async {
    final headers = await _headers(true);
    headers.remove('Content-Type');
    final req = http.MultipartRequest(metodo, Uri.parse('${ApiConfig.baseUrl}$ruta'))
      ..headers.addAll(headers)
      ..fields.addAll(campos)
      ..files.addAll(archivos);
    try {
      final streamed = await _http.send(req).timeout(_timeout);
      final r = await http.Response.fromStream(streamed).timeout(_timeout);
      return _procesar(r, defecto);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(_mensajeRed(e));
    }
  }

  Future<dynamic> _enviar(String metodo, String ruta, {Object? cuerpo, required bool conToken, required String defecto, bool reintentar = false}) async {
    final headers = await _headers(conToken);
    final url = Uri.parse('${ApiConfig.baseUrl}$ruta');
    final intentos = reintentar ? 3 : 1;
    Object? ultimo;

    for (var i = 0; i < intentos; i++) {
      if (i > 0) await Future.delayed(Duration(seconds: i));
      try {
        final req = http.Request(metodo, url)..headers.addAll(headers);
        if (cuerpo != null) req.body = jsonEncode(cuerpo);
        final streamed = await _http.send(req).timeout(_timeout);
        final r = await http.Response.fromStream(streamed).timeout(_timeout);
        return _procesar(r, defecto);
      } on ApiException catch (e) {
        // 4xx (correo duplicado, plato agotado, sesión vencida...): el
        // mensaje del backend es la respuesta final, no se reintenta.
        if (e.codigo != null && e.codigo! < 500) rethrow;
        ultimo = e;
      } catch (e) {
        ultimo = e;
      }
    }

    if (ultimo is ApiException) throw ultimo;
    throw ApiException(_mensajeRed(ultimo));
  }

  dynamic _procesar(http.Response r, String defecto) {
    final cuerpo = r.body.trim();
    dynamic data;
    if (cuerpo.isNotEmpty && !cuerpo.startsWith('<')) {
      try {
        data = jsonDecode(cuerpo);
      } catch (_) {
        data = null;
      }
    }

    if (r.statusCode >= 200 && r.statusCode < 300) {
      // Render a veces devuelve su página HTML de arranque con estado 200.
      if (cuerpo.startsWith('<')) {
        throw ApiException('El servidor está despertando, intenta de nuevo en unos segundos');
      }
      return data;
    }

    final msg = data is Map ? (data['error'] ?? data['message'])?.toString().trim() : null;
    if (r.statusCode == 401) {
      throw ApiException((msg != null && msg.isNotEmpty) ? msg : 'Tu sesión expiró, inicia sesión de nuevo', codigo: 401);
    }
    throw ApiException(
      (msg != null && msg.isNotEmpty) ? msg : '$defecto (HTTP ${r.statusCode})',
      codigo: r.statusCode,
    );
  }

  String _mensajeRed(Object? e) {
    if (e is TimeoutException) {
      return 'El servidor tardó demasiado en responder. Intenta de nuevo';
    }
    return 'Sin conexión con el servidor. Revisa tu internet e intenta de nuevo';
  }
}