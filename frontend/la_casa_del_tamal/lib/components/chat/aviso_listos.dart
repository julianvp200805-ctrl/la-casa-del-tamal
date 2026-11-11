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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: const Color(0xFF4A9849).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: AppEstilos.fondoOscuro, size: 20),
          const SizedBox(width: 10),
          Expanded(
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
          ),
        ],
      ),
    );
  }
}