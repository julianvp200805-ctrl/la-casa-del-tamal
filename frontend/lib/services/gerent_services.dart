import 'dart:convert';
import 'package:frontend/models/gerent.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class UserService {
  Future<UserModel> login(String email, String contrasena) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email, 'contrasena': contrasena}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String token = data['token'] ?? '';
        final usuario = UserModel.fromJson(data['usuario'] ?? {});

        // Guardamos la sesión localmente para que AdminHomePage y las
        // demás pantallas puedan leerla sin volver a pedir login.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_id', usuario.id ?? '');
        await prefs.setString('user_name', usuario.nombre ?? '');
        await prefs.setString('user_email', usuario.email ?? '');
        await prefs.setString('user_rol', usuario.rol ?? 'usuario');

        return usuario;
      } else {
        throw Exception(data['error'] ?? 'Credenciales inválidas');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // RECUPERAR CONTRASEÑA - paso 1: enviar código de 6 dígitos al correo
  // POST /user/forgot-password  { email }
  
  Future<String> enviarCodigoRecuperacion(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Código enviado';
      } else {
        throw Exception(data['error'] ?? 'No se pudo enviar el código');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

 
  // RECUPERAR CONTRASEÑA - único paso real del backend: verifica el
  // código Y cambia la contraseña en la misma petición.
  // POST /user/verify-code  { email, codigo, newPassword }
  Future<String> confirmarRecuperacion({
    required String email,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/verify-code');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'codigo': codigo,
          'newPassword': nuevaContrasena,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Contraseña actualizada';
      } else {
        throw Exception(data['error'] ?? 'Código inválido o expirado');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}