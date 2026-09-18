import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class RespuestaChat {
  final String respuesta;
  final String sesionId;

  RespuestaChat({required this.respuesta, required this.sesionId});

  factory RespuestaChat.fromJson(Map<String, dynamic> json) {
    return RespuestaChat(
      respuesta: json['respuesta'] ?? '',
      sesionId: json['sesionId'] ?? '',
    );
  }
}

class MensajeChat {
  final String emisor; // 'admin' o 'bot'
  final String mensaje;

  MensajeChat({required this.emisor, required this.mensaje});

  factory MensajeChat.fromJson(Map<String, dynamic> json) {
    return MensajeChat(
      emisor: json['emisor'] ?? 'bot',
      mensaje: json['mensaje'] ?? '',
    );
  }
}

class ChatService {
  // POST /api/chat  { mensaje, sesionId, usuarioId }
  Future<RespuestaChat> enviarMensaje({
    required String mensaje,
    String? sesionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getString('user_id');

    final url = Uri.parse('${ApiConfig.rootUrl}/api/chat');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'mensaje': mensaje,
          'sesionId': sesionId,
          'usuarioId': (usuarioId != null && usuarioId.isNotEmpty)
              ? usuarioId
              : null,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return RespuestaChat.fromJson(data);
      }
      throw Exception(data['message'] ?? 'No se pudo enviar el mensaje');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // GET /api/chat/historial/:sesionId
  Future<List<MensajeChat>> obtenerHistorial(String sesionId) async {
    final url = Uri.parse('${ApiConfig.rootUrl}/api/chat/historial/$sesionId');

    try {
      final response = await http.get(url, headers: ApiConfig.headers);
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> lista = data['historial'] ?? [];
        return lista.map((m) => MensajeChat.fromJson(m)).toList();
      }
      throw Exception(data['message'] ?? 'No se pudo cargar el historial');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}