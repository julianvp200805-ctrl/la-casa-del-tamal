import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notificaciones locales (en la bandeja del celular) que NO requieren Firebase
/// ni servicios externos: se disparan desde la app cuando detecta un pedido
/// nuevo en estado "listo para entregar" (mediante el sondeo cada 15 s).
///
/// Funciona mientras la app está abierta o en segundo plano. Si la app está
/// completamente cerrada no se pueden mostrar (para eso haría falta push/FCM).
class NotificacionesService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _canal = AndroidNotificationChannel(
    'pedidos_listos',
    'Pedidos listos',
    description: 'Avisos cuando un pedido está listo para entregar',
    importance: Importance.high,
  );

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(const InitializationSettings(android: android));
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_canal);
  }

  static Future<void> mostrar({required String titulo, required String cuerpo}) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titulo,
      cuerpo,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _canal.id,
          _canal.name,
          channelDescription: _canal.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}