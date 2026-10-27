import 'package:flutter/material.dart';
import 'package:frontend/components/chat/chat_page.dart';
import 'package:frontend/core/colores.dart';


/// Botón flotante del chat "Tamalín" — EL MISMO en todas las pantallas
/// admin: `floatingActionButton: const ChatFab()`. Una sola clase.
class ChatFab extends StatelessWidget {
  const ChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'chat_fab',
      backgroundColor: AppEstilos.headerAdmin,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatBotPage()),
      ),
      child: const Icon(Icons.back_hand_outlined, color: AppEstilos.fondoOscuro),
    );
  }
}