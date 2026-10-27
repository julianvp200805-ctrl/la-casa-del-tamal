import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class ItemVenta {
  final String nombre;
  final int cantidad;
  final double subtotal;

  ItemVenta({required this.nombre, required this.cantidad, required this.subtotal});

  factory ItemVenta.fromJson(Map<String, dynamic> json) {
    return ItemVenta(
      nombre: json['nombre'] ?? 'Producto',
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

String formatoMoneda(double valor) {
  final texto = valor.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < texto.length; i++) {
    final restante = texto.length - i;
    buffer.write(texto[i]);
    if (restante > 1 && restante % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

/// Lista de filas "10 chorizo ........ $30.000" (una tarjeta oscura por producto).
class VentaItemsList extends StatelessWidget {
  final List<ItemVenta> items;
  const VentaItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Sin ventas registradas', style: TextStyle(color: Colors.white54))),
      );
    }
    return Column(
      children: [
        for (final item in items)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppEstilos.inputOscuro,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppEstilos.bordeOscuro),
            ),
            child: Row(
              children: [
                Expanded(child: Text('${item.cantidad} ${item.nombre}', style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'serif'))),
                Text('\$${formatoMoneda(item.subtotal)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'serif')),
              ],
            ),
          ),
      ],
    );
  }
}