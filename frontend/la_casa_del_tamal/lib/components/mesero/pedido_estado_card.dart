import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/mesas.dart';
import 'package:frontend/services/pedido/pedido_card.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

/// Tarjeta de un pedido del mesero: mesa, estado, hora, platos con su nota,
/// total siempre visible y el botón "Entregar pedido" cuando la cocina lo
/// deja listo. Entregar es lo que registra la venta.
class PedidoEstadoCard extends StatefulWidget {
  final PedidoProceso pedido;
  final VoidCallback onEntregar;
  final bool entregando;
  const PedidoEstadoCard({super.key, required this.pedido, required this.onEntregar, this.entregando = false});

  @override
  State<PedidoEstadoCard> createState() => _PedidoEstadoCardState();
}

class _PedidoEstadoCardState extends State<PedidoEstadoCard> {
  bool _abierto = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    final items = p.items;
    // El cupo no viaja en el pedido: es el fijo de esa mesa del salón.
    final numero = mesaNumero(p.numero);
    final cupo = numero == null ? null : cupoMesa(numero);
    final listo = p.estado == 'listo';
    final (fondoEstado, textoEstadoColor) = coloresEstado(p.estado);
    final visibles = _abierto ? items : items.take(2).toList();
    final extra = items.length - visibles.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppEstilos.tablaInventario,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: listo ? AppEstilos.pillFresco : AppEstilos.bordeOscuro, width: listo ? 1.4 : 1),
        boxShadow: listo
            ? [BoxShadow(color: AppEstilos.pillFresco.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.table_restaurant_outlined, color: listo ? AppEstilos.pillFresco : AppEstilos.meseroOliva, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p.cabecera} ${p.numero}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (p.hora.isNotEmpty) p.hora,
                        if (cupo != null) '$cupo personas',
                      ].join(' · '),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: fondoEstado, borderRadius: BorderRadius.circular(12)),
                child: Text(textoEstado(p.estado),
                    style: TextStyle(color: textoEstadoColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final i in visibles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text('${i.cantidad}×',
                                  style: const TextStyle(color: AppEstilos.meseroOliva, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(child: Text(i.nombre, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                          ],
                        ),
                        if (_abierto && i.nota.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 28, top: 1),
                            child: Text('Nota: ${i.nota}',
                                style: const TextStyle(color: AppEstilos.meseroOliva, fontSize: 11, fontStyle: FontStyle.italic)),
                          ),
                      ],
                    ),
                  ),
                if (extra > 0)
                  Text('+$extra más', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Total: \$${formatoPesos(p.total)}',
                  style: const TextStyle(color: Color(0xFFFFD60A), fontSize: 14, fontFamily: 'serif', fontWeight: FontWeight.bold)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _abierto = !_abierto),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      Text(_abierto ? 'Ocultar' : 'Ver detalle',
                          style: const TextStyle(color: AppEstilos.verdeBoton, fontSize: 13, fontWeight: FontWeight.w600)),
                      Icon(_abierto ? Icons.expand_less : Icons.expand_more, color: AppEstilos.verdeBoton, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (listo) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: widget.entregando ? null : widget.onEntregar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppEstilos.pillFresco,
                  disabledBackgroundColor: AppEstilos.pillFresco.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: widget.entregando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.delivery_dining, size: 20),
                label: Text(widget.entregando ? 'Entregando...' : 'Entregar pedido',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}