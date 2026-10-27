import 'dart:convert';
import 'package:frontend/services/api_response.dart';
import 'package:frontend/services/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class ChatService {
  // POST /api/chat  { mensaje, sesionId, usuarioId }
  Future<RespuestaChat> enviarMensaje({
    required String mensaje,
    String? sesionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getString('user_id');
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat');

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

      final Map<String, dynamic> data = decodeApiResponse(response);

      if (response.statusCode == 200) {
        return RespuestaChat.fromJson(data);
      }
      throw Exception(data['message'] ?? 'No se pudo enviar el mensaje');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}