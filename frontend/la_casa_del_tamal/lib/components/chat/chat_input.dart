import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Barra de escribir del chat: campo redondeado y botón verde de enviar.
class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;

  const ChatInput({
    super.key,
    required this.controller,
    required this.enviando,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      color: Colors.transparent, // Deja que el fondo oscuro principal se mantenga limpio
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppEstilos.inputOscuro, // Fondo gris oscuro minimalista
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onEnviar(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppEstilos.verdeAccion, // El botón verde resalta como acción principal
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black87, size: 20),
              onPressed: enviando ? null : onEnviar,
            ),
          ),
        ],
      ),
    );
  }
}