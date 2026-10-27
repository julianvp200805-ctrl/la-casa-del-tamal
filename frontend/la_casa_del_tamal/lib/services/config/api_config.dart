import 'dart:io' show Platform;

class ApiConfig {
  static const bool useRemote = true;

  // Base para endpoints de usuario (login, forgot-password, verify-code...)
  static const String _remoteUrl = "https://la-casa-del-tamal.onrender.com";
  // Base sin "/user", para /pedido, /menu, /producto, /tipoProducto
  static String get baseUrl {
    if (useRemote) {
      return _remoteUrl;
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
