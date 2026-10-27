import 'package:flutter/material.dart';
import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_card.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

/// Hoja inferior con el detalle completo de un pedido (datos ya cargados).
void mostrarDetallePedido(BuildContext context, PedidoProceso p, {VoidCallback? onEntregar}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppEstilos.fondoOscuro,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _Detalle(pedido: p, onEntregar: onEntregar),
  );
}

class _Detalle extends StatelessWidget {
  final PedidoProceso pedido;
  final VoidCallback? onEntregar;
  const _Detalle({required this.pedido, this.onEntregar});

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = coloresEstado(pedido.estado);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('${pedido.cabecera} ${pedido.numero}', style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'serif'))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(20)),
                  child: Text(textoEstado(pedido.estado), style: TextStyle(color: texto, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (pedido.hora.isNotEmpty) Text('Pedido a las ${pedido.hora}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 16),
            for (final i in pedido.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text('${i.cantidad} ${i.nombre}', style: const TextStyle(color: Colors.white70))),
                    Text('\$${formatoMoneda(i.subtotal)}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            const Divider(color: AppEstilos.bordeOscuro, height: 28),
            Row(
              children: [
                const Expanded(child: Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Text('\$${formatoMoneda(pedido.total)}', style: const TextStyle(color: AppEstilos.verdeBoton, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            if ((pedido.notas ?? '').isNotEmpty) _dato('Notas', pedido.notas!),
            if ((pedido.telefono ?? '').isNotEmpty) _dato('Teléfono', pedido.telefono!),
            if ((pedido.direccion ?? '').isNotEmpty && pedido.cabecera == 'Pedido') _dato('Entrega', pedido.direccion!),
            if (onEntregar != null && pedido.estado == 'listo')
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onEntregar!();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.verdeBoton, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Marcar como entregado', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text('$titulo: $valor', style: const TextStyle(color: Colors.white60, fontSize: 13)),
      );
}