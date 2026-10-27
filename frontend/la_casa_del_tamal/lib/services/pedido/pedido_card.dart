import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

/// Colores de la pastilla de estado: (fondo, texto).
(Color, Color) coloresEstado(String estado) {
  switch (estado) {
    case 'en_proceso':
      return (const Color(0xFF756632), const Color(0xFFE8B93A));
    case 'listo':
      return (const Color(0xFF4A9849), AppEstilos.fondoOscuro);
    case 'entregado':
      return (AppEstilos.bordeOscuro, Colors.white54);
    case 'cancelado':
      return (const Color(0xFF5A2A2A), const Color(0xFFFF8A8A));
    default:
      return (const Color(0xFF3A4540), Colors.white70);
  }
}

String textoEstado(String estado) {
  if (estadosPedido.containsKey(estado)) return estadosPedido[estado]!;
  if (estado.isEmpty) return 'Pendiente';
  return estado[0].toUpperCase() + estado.substring(1).replaceAll('_', ' ');
}

/// Tarjeta de un pedido: mesa, estado (se cambia con el menú), productos y "ver detalle".
class PedidoCard extends StatelessWidget {
  final PedidoProceso pedido;
  final ValueChanged<String>? onEstado; // null = solo lectura (mesero)
  final VoidCallback onDetalle;

  const PedidoCard({super.key, required this.pedido, this.onEstado, required this.onDetalle});

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = coloresEstado(pedido.estado);
    final extra = pedido.items.length - 3;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(pedido.cabecera, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'serif')),
              const SizedBox(width: 12),
              Expanded(child: _pastilla(fondo, texto)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 2, bottom: 8),
            child: Text(pedido.numero, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'serif')),
          ),
          for (final item in pedido.items.take(3))
            Text('${item.cantidad} ${item.nombre}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          if (extra > 0) Text('+$extra más', style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDetalle,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 30)),
              child: const Text('ver detalle', style: TextStyle(color: AppEstilos.verdeBoton, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // Pastilla de estado. Con onEstado abre el menú para cambiarlo; sin él es solo lectura.
  Widget _pastilla(Color fondo, Color texto) {
    final pastilla = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(child: Text(textoEstado(pedido.estado), style: TextStyle(color: texto, fontSize: 12, fontWeight: FontWeight.w600))),
          if (onEstado != null) Icon(Icons.arrow_drop_down, color: texto, size: 18),
        ],
      ),
    );
    if (onEstado == null) return pastilla;
    return PopupMenuButton<String>(
      onSelected: onEstado,
      itemBuilder: (_) => [for (final e in estadosPedido.entries) PopupMenuItem(value: e.key, child: Text(e.value))],
      child: pastilla,
    );
  }
}