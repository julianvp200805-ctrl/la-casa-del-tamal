import 'package:frontend/services/api_client.dart';
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
    final data = await ApiClient.I.postJson(
      '/api/chat',
      {
        'mensaje': mensaje,
        'sesionId': sesionId,
        'usuarioId': (usuarioId != null && usuarioId.isNotEmpty) ? usuarioId : null,
      },
      defecto: 'No se pudo enviar el mensaje',
    );
    return RespuestaChat.fromJson(data);
  }
}