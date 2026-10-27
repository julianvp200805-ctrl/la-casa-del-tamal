import 'package:flutter/material.dart';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/core/colores.dart';

/// Fila de un producto: nombre + fecha de vencimiento a la izquierda y un
/// widget a la derecha (el lote en Productos, "Descartar" en Vencidos).
class ProductoFila extends StatelessWidget {
  final Producto producto;
  final Widget trailing;
  final bool fechaEnChip; // true = fecha roja (vencidos)

  const ProductoFila({super.key, required this.producto, required this.trailing, this.fechaEnChip = false});

  @override
  Widget build(BuildContext context) {
    final fecha = fechaCorta(producto.vencimiento);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
      decoration: BoxDecoration(color: AppEstilos.filaInventario, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre, style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'serif')),
                const SizedBox(height: 2),
                fechaEnChip
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: AppEstilos.rojoChip, borderRadius: BorderRadius.circular(4)),
                        child: Text(fecha, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    : Text(fecha, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}