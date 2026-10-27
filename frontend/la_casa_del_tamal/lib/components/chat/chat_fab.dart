import 'package:flutter/material.dart';
import 'package:frontend/components/chat/chat_page.dart';
import 'package:frontend/core/colores.dart';


/// Botón flotante de "Tamalín" (el chatbot). Se agrega a CUALQUIER
/// Scaffold del admin así:
///
///   floatingActionButton: const ChatFab(),
///
/// y desde ahí siempre abre el mismo asistente, sin importar en qué
/// pantalla estés.
class ChatFab extends StatelessWidget {
  const ChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'chat_fab',
      backgroundColor: AppEstilos.headerInicio,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatBotPage()),
        );
      },
      child: const Icon(Icons.eco, color: Colors.white),
    );
  }
}