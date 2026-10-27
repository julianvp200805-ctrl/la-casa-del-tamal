import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Parte de arriba del login: flecha de volver, logo y los dos títulos.
class EncabezadoInicio extends StatelessWidget {
  const EncabezadoInicio({super.key});

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
        Center(
          child: Image.asset(
            'assets/image/logo.png',
            height: 120,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.house,
              size: 90,
              color: AppEstilos.verdeBoton,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Hola de nuevo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ingresa para continuar',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}