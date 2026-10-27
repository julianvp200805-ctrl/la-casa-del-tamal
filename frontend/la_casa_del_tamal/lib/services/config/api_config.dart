import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // 💡 REGLA DE ORO PARA PRUEBAS LOCALES:
  // 1. Si pruebas en un CELULAR FÍSICO: Pon la IP de tu PC aquí (Ej: "192.168.1.147").
  // 2. Si pruebas en EMULADOR ANDROID: Deja "10.0.2.2".
  // 3. Si pruebas en SIMULADOR IOS: Deja "localhost".
  static const String _ipComputador = "10.0.2.2"; 

  // Base para endpoints de usuario (login, forgot-password, verify-code...)
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/auth";
    }
    if (Platform.isAndroid) {
      return "http://$_ipComputador:3000/auth";
    }
    if (Platform.isIOS) {
      // Si es un iPhone físico, cambia 'localhost' por la IP de tu PC (_ipComputador)
      return "http://localhost:3000/auth"; 
    }
    return "http://localhost:3000/auth";
  }

  // Base sin "/user", para /pedido, /menu, /producto, /tipoProducto
  static String get rootUrl {
    if (kIsWeb) {
      return "http://localhost:3000";
    }
    if (Platform.isAndroid) {
      return "http://$_ipComputador:3000";
    }
    if (Platform.isIOS) {
      return "http://localhost:3000";
    }
    return "http://localhost:3000";
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> headersConToken(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}
