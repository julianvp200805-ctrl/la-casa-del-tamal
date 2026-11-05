import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Barra de escribir del chat: campo verde y botón circular de enviar, como
/// la maqueta 18 (el texto del campo es oscuro sobre verde, no al revés).
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
                color: AppEstilos.verdeAccion,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onEnviar(),
                cursorColor: Colors.black87,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Escribe tu pregunta..',
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                  // Sin borde de foco: el tema pinta un contorno azul por dentro
                  // de la pastilla verde apenas se selecciona el campo.
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: enviando ? null : onEnviar,
            ),
          ),
        ],
      ),
    );
  }
}