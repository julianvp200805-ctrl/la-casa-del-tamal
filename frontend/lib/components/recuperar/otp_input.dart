import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fila de casillas para el código de 6 dígitos (diseño oscuro optimizado).
class OtpInput extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool oscuro;

  const OtpInput({
    super.key, 
    required this.controllers, 
    required this.focusNodes, 
    this.oscuro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 44, // Ajustado ligeramente para mejorar la visualización numérica
            height: 48,
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              // Filtro estricto para aceptar únicamente números individuales
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              // CORRECCIÓN DE COLOR: Forzamos text color blanco puro cuando oscuro sea true
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: oscuro ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                // Fondo personalizado para que haga contraste con las fuentes claras
                fillColor: oscuro ? const Color(0xFF1E2722) : const Color(0xFFD9D9D9),
                contentPadding: EdgeInsets.zero, // Centrado simétrico vertical interno
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                // Resalte dinámico cuando el usuario está editando la casilla activa
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: oscuro ? Colors.green.shade400 : Colors.black45, 
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (valor) {
                if (valor.isNotEmpty && index < controllers.length - 1) {
                  focusNodes[index + 1].requestFocus();
                }
                if (valor.isEmpty && index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }
}