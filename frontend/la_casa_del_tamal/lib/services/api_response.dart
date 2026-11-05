import 'dart:convert';
import 'package:http/http.dart' as http;

dynamic decodeApiResponse(http.Response response) {
  final body = response.body.trim();

  if (body.isEmpty) {
    throw Exception(
      'El servidor respondió vacío. Código HTTP: ${response.statusCode}',
    );
  }

  // Detectar HTML antes de intentar interpretar JSON.
  if (body.startsWith('<!DOCTYPE html') ||
      body.startsWith('<html') ||
      body.startsWith('<')) {
    throw Exception(
      'El servidor devolvió HTML en vez de JSON. '
      'Código HTTP: ${response.statusCode}. '
      'Revisa la URL, la ruta del backend y los logs de Render.',
    );
  }

  dynamic data;

  try {
    data = jsonDecode(body);
  } on FormatException {
    throw Exception(
      'La respuesta del servidor no es JSON válido. '
      'Código HTTP: ${response.statusCode}',
    );
  }

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      'Error HTTP ${response.statusCode}: $data',
    );
  }

  return data;
}

/// Texto legible que el backend puso en el cuerpo (`error` o `message`), o null
/// si el cuerpo no es el JSON esperado. [decodeApiResponse] lanza volcando el
/// cuerpo crudo (`Error HTTP 500: {error: ...}`), así que para mostrarle al
/// usuario el motivo real hay que leer el campo sin pasar por ese lanzamiento.
String? mensajeDeRespuesta(http.Response response) {
  try {
    final data = jsonDecode(response.body.trim());
    if (data is Map) {
      final texto = (data['error'] ?? data['message'])?.toString().trim();
      if (texto != null && texto.isNotEmpty) return texto;
    }
  } catch (_) {}
  return null;
}