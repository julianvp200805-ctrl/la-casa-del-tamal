import 'package:flutter/material.dart';
import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/core/colores.dart';

/// Tarjeta del total. `verde: true` = "ventas de hoy" (verde sólido);
/// `verde: false` = "Total ventas" (oscura con número verde).
class VentaTotalCard extends StatelessWidget {
  final String etiqueta;
  final double? total; // null = cargando / sin dato (muestra "—")
  final bool verde;

  const VentaTotalCard({super.key, required this.etiqueta, this.total, this.verde = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: verde ? AppEstilos.verdeBoton : AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(verde ? 6 : 18),
        border: verde ? null : Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: TextStyle(color: verde ? Colors.black87 : Colors.white70, fontSize: 12, fontFamily: 'serif')),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              total == null ? '—' : '\$${formatoMoneda(total!)}',
              style: TextStyle(color: verde ? Colors.black : AppEstilos.verdeBoton, fontSize: 32, fontFamily: 'serif', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}