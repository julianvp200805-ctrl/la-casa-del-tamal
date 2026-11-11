import 'package:frontend/models/gerent.dart';
import 'package:frontend/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Future<UserModel> login(String email, String contrasena) async {
    final data = await ApiClient.I.postJson(
      '/auth/login',
      {'email': email, 'contrasena': contrasena},
      defecto: 'Credenciales inválidas',
    );

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
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // RECUPERAR CONTRASEÑA - paso 1: enviar código de 6 dígitos al correo
  // POST /auth/forgot-password  { email }
  Future<String> enviarCodigoRecuperacion(String email) async {
    final data = await ApiClient.I.postJson(
      '/auth/forgot-password',
      {'email': email},
      defecto: 'No se pudo enviar el código',
    );
    return data['message'] ?? 'Código enviado';
  }

  // RECUPERAR CONTRASEÑA - verifica el código Y cambia la contraseña
  // en la misma petición. POST /auth/verify-code  { email, codigo, newPassword }
  Future<String> confirmarRecuperacion({
    required String email,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    final data = await ApiClient.I.postJson(
      '/auth/verify-code',
      {
        'email': email,
        'codigo': codigo,
        'newPassword': nuevaContrasena,
      },
      defecto: 'Código inválido o expirado',
    );
    return data['message'] ?? 'Contraseña actualizada';
  }
}