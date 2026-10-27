class UserModel {
  final String? id;
  final String? nombre;
  final String? email;
  final String? contrasena;
  final String? rol;

  UserModel({
    this.id,
    required this.nombre,
    required this.email,
    this.contrasena,
    this.rol = 'usuario', //por defecto el rol es 'usuario'
  });

  // Parsea el objeto "usuario" tal como lo devuelve el backend:
  // { id, nombre, email, rol } (login y registro lo anidan bajo "usuario")
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      contrasena: json['contrasena'],
      rol: json['rol'] ?? 'usuario',
    );
  }

  // Convertir a map para enviar en el POST (login/registro)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'contrasena': contrasena,
      'rol': rol,
    };
  }
}