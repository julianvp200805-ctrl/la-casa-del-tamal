import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // 1. Evaluar WEB primero para evitar que Platform.isX genere un error
    if (kIsWeb) {
      return "http://localhost:3000/user";
    }

    // 2. Evaluación para dispositivos móviles
    if (Platform.isAndroid) {
      // Emulador de Android
      return "http://10.0.2.2:3000/user";
    } else if (Platform.isIOS) {
      // Emulador de iOS
      return "http://localhost:3000/user";
    }

    // Fallback para otros entornos
    return "http://localhost:3000/user";
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

}