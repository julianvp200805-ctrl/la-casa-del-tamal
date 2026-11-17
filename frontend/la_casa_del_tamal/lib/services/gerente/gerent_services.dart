import 'package:frontend/models/gerent.dart';
import 'package:frontend/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Trabajador {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  Trabajador({required this.id, required this.nombre, required this.email, required this.rol});
  factory Trabajador.fromJson(Map<String, dynamic> j) => Trabajador(
        id: j['id'].toString(),
        nombre: j['nombre'] ?? '',
        email: j['email'] ?? '',
        rol: j['rol'] ?? '',
      );
}

class RankingMesero {
  final String id;
  final String nombre;
  final String rol;
  final int mesas;
  RankingMesero({required this.id, required this.nombre, required this.rol, required this.mesas});
  factory RankingMesero.fromJson(Map<String, dynamic> j) => RankingMesero(
        id: j['id'].toString(),
        nombre: j['nombre'] ?? '',
        rol: j['rol'] ?? '',
        mesas: (j['mesas'] as num?)?.toInt() ?? 0,
      );
}

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

  // Listar trabajadores registrados (admin).
  Future<List<Trabajador>> obtenerTrabajadores() async {
    final data = await ApiClient.I.getJson('/user/obtener_usuarios', conToken: true, defecto: 'No se pudieron cargar los trabajadores');
    return ((data['usuarios'] as List?) ?? []).map((e) => Trabajador.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Eliminar un trabajador (admin).
  Future<void> eliminarTrabajador(String id) async {
    await ApiClient.I.deleteJson('/user/eliminar_usuario/$id', conToken: true, defecto: 'No se pudo eliminar el trabajador');
  }

  // Ranking de meseros por mesas atendidas este mes (admin).
  Future<List<RankingMesero>> obtenerRankingMes() async {
    final data = await ApiClient.I.getJson('/pedido/ranking-mes', conToken: true, defecto: 'No se pudo cargar el ranking');
    return ((data['ranking'] as List?) ?? []).map((e) => RankingMesero.fromJson(e as Map<String, dynamic>)).toList();
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