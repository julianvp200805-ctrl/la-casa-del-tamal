import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Aviso verde: "Tienes N pedidos listos para recoger".
class AvisoListos extends StatelessWidget {
  final int listos;

  const AvisoListos({super.key, required this.listos});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF4A9849),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        listos == 1
            ? 'Tienes 1 pedido listo para recoger'
            : 'Tienes $listos pedidos listos para recoger',
        style: const TextStyle(
          color: AppEstilos.fondoOscuro,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}