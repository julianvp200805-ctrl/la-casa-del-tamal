import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/services/config/privacidad_config.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre la política de privacidad en el navegador del dispositivo.
Future<void> abrirPoliticaPrivacidad(BuildContext context) async {
  final uri = Uri.parse(PrivacidadConfig.url);
  try {
    final abierto = kIsWeb
        ? await launchUrl(uri, webOnlyWindowName: '_blank')
        : await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto) throw Exception('No se pudo abrir $uri');
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No se pudo abrir la política de privacidad. Verifica tu conexión e inténtalo de nuevo.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }
}

/// Opción reutilizable para los menús laterales de los tres roles.
ListTile listaPoliticaPrivacidad(BuildContext context, {required Color color}) {
  return ListTile(
    leading: Icon(Icons.privacy_tip_outlined, color: color),
    title: const Text(
      'Política de privacidad',
      style: TextStyle(color: Colors.white),
    ),
    onTap: () async {
      await abrirPoliticaPrivacidad(context);
      if (context.mounted) Navigator.pop(context);
    },
  );
}
