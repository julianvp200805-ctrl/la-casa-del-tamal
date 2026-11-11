import 'package:flutter/foundation.dart';

class ApiConfig {
  static const bool useRemote = true;

  // Backend desplegado en Render (producción, también para la Play Store).
  static const String _remoteUrl = "https://la-casa-del-tamal.onrender.com";

  static String get baseUrl {
    if (useRemote) return _remoteUrl;
    // Desarrollo local: el emulador de Android llega al host por 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:3000";
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