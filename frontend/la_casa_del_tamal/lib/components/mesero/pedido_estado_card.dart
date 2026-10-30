import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

const Color _verde = Color(0xFF4ADE60);

/// Lee un campo de PedidoProceso sin romper si no existe.
T? _g<T>(T Function() f) {
  try { return f(); } catch (_) { return null; }
}

/// Tarjeta del diseño: Mesa + chip de estado, chip de personas, platos y "ver detalle".
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
    final d = p as dynamic;
    final items = _g(() => (d.items as List)) ?? [];
    final lineas = [for (final i in items) '${_g(() => i.cantidad) ?? 1} ${_g(() => i.nombre) ?? ''}'];
    final personas = _g(() => d.personas);
    final total = _g(() => (d.total as num)) ?? 0;
    final listo = p.estado == 'listo';
    final etiqueta = {'listo': 'Listo', 'en_proceso': 'En proceso'}[p.estado] ?? 'Pendiente';
    final visibles = _abierto ? lineas : lineas.take(2).toList();

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
          if (personas != null && '$personas' != '0')
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF1F3A2C), borderRadius: BorderRadius.circular(10)),
              child: Text('$personas personas', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ),
          const SizedBox(height: 10),
          for (final l in visibles) Text(l, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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