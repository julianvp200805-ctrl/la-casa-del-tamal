import 'package:flutter/material.dart';
import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';

/// Tarjeta de un plato al tomar el pedido: foto, nombre, descripción,
/// precio y el selector de cantidad ( + [n] − ).
class PlatoPedidoCard extends StatelessWidget {
  final MenuItem plato;
  final int cantidad;
  final VoidCallback onMas;
  final VoidCallback onMenos;

  const PlatoPedidoCard({super.key, required this.plato, required this.cantidad, required this.onMas, required this.onMenos});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppEstilos.platoMesero,
        borderRadius: BorderRadius.circular(8),
        border: cantidad > 0 ? Border.all(color: AppEstilos.meseroOliva, width: 1.2) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                ? Image.network(plato.imagenUrl!, width: 76, height: 76, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _vacia())
                : _vacia(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plato.nombre, style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'serif')),
                const SizedBox(height: 3),
                if ((plato.descripcion ?? '').isNotEmpty)
                  Text(plato.descripcion!, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: Text('Precio: ${formatoMoneda(plato.precio)}', style: const TextStyle(color: Colors.white60, fontSize: 10))),
                    _boton(Icons.add, onMas),
                    Container(
                      width: 24,
                      height: 22,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(3)),
                      child: Text('$cantidad', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    _boton(Icons.remove, cantidad > 0 ? onMenos : null),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _boton(IconData icono, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(padding: const EdgeInsets.all(4), child: Icon(icono, size: 18, color: onTap == null ? Colors.white24 : Colors.white)),
    );
  }

  Widget _vacia() => Container(width: 76, height: 76, color: AppEstilos.fondoOscuro, child: const Icon(Icons.restaurant, color: Colors.white38));
}