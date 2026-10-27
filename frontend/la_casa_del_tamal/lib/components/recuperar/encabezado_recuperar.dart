import 'package:flutter/material.dart';

/// Parte de arriba de "Recupera tu contraseña": flecha, título e indicación.
class EncabezadoRecuperar extends StatelessWidget {
  const EncabezadoRecuperar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(
            Icons.subdirectory_arrow_left,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 8),
        const Text(
          'Recupera tu contraseña',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Te enviaremos un codigo ingresalo para\nque puedas tener una contraseña nueva',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}