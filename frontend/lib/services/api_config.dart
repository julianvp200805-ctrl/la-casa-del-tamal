import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Base para endpoints de usuario (login, forgot-password, verify-code...)
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/user";
    }
    if (Platform.isAndroid) {
      return "http://192.168.1.147:3000/user";
    } else if (Platform.isIOS) {
      return "http://localhost:3000/user";
    }
    return "http://localhost:3000/user";
  }

  // NUEVO: base sin "/user", para /pedido, /menu, /producto, /tipoProducto
  static String get rootUrl {
    if (kIsWeb) {
      return "http://localhost:3000";
    }
    if (Platform.isAndroid) {
      return "http://192.168.1.147:3000";
    } else if (Platform.isIOS) {
      return "http://localhost:3000";
    }
    return "http://localhost:3000";
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // NUEVO: headers con el token del admin para rutas protegidas
  // (verificarToken + verificarAdmin en el backend)
  static Map<String, String> headersConToken(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}