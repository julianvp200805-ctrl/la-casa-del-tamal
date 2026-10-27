import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Burbuja de un mensaje del chat (usuario o bot).
class ChatBubble extends StatelessWidget {
  final String texto;
  final bool esUsuario;

  const ChatBubble({super.key, required this.texto, required this.esUsuario});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: esUsuario ? AppEstilos.botonVerde : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppEstilos.sombraSuave,
        ),
        child: Text(
          texto,
          style: TextStyle(color: esUsuario ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}