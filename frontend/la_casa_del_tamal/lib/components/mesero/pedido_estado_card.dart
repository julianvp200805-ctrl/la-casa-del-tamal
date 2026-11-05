import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/mesas.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

const Color _verde = Color(0xFF4ADE60);

/// Tarjeta del diseño: Mesa + chip de estado, cupo de la mesa, platos con su
/// nota y "ver detalle".
class PedidoEstadoCard extends StatefulWidget {
  final PedidoProceso pedido;
  final VoidCallback onEntregar;
  const PedidoEstadoCard({super.key, required this.pedido, required this.onEntregar});

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
    final total = p.total;
    final listo = p.estado == 'listo';
    final etiqueta = {'listo': 'Listo', 'en_proceso': 'En proceso'}[p.estado] ?? 'Pendiente';
    final visibles = _abierto ? items : items.take(2).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppEstilos.tablaInventario,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${p.cabecera} ${p.numero}', style: const TextStyle(color: Colors.white, fontSize: 15)),
              const Spacer(),
              Container(
                width: 118,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: listo ? const Color(0xFF45B458) : const Color(0xFF7D6B35),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(etiqueta, style: TextStyle(color: listo ? Colors.white : const Color(0xFFFFD60A), fontSize: 12)),
              ),
            ],
          ),
          if (cupo != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF1F3A2C), borderRadius: BorderRadius.circular(10)),
              child: Text('$cupo personas', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ),
          const SizedBox(height: 10),
          for (final i in visibles)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i.cantidad} ${i.nombre}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  if (_abierto && i.nota.isNotEmpty)
                    Text('nota: ${i.nota}',
                        style: const TextStyle(color: AppEstilos.meseroOliva, fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          if (_abierto) ...[
            const SizedBox(height: 8),
            Text('Valor total: ${formatoPesos(total)}', style: const TextStyle(color: _verde, fontSize: 12)),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (listo)
                TextButton(onPressed: widget.onEntregar, child: const Text('Entregar', style: TextStyle(color: Color(0xFFFFD60A)))),
              GestureDetector(
                onTap: () => setState(() => _abierto = !_abierto),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_abierto ? 'ocultar' : 'ver detalle', style: const TextStyle(color: _verde, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}