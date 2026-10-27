import 'package:flutter/material.dart';
import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';


/// Tarjeta de un plato en "Modificar menu": foto, nombre, descripción,
/// precio, y los íconos de eliminar (arriba) y editar (abajo).
class AdminMenuCard extends StatelessWidget {
  final MenuItem plato;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const AdminMenuCard({super.key, required this.plato, required this.onEditar, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 6),
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                ? Image.network(plato.imagenUrl!, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _vacia())
                : _vacia(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plato.nombre, style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'serif')),
                const SizedBox(height: 4),
                if ((plato.descripcion ?? '').isNotEmpty)
                  Text(plato.descripcion!, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                Text('\$${formatoMoneda(plato.precio)}', style: const TextStyle(color: AppEstilos.verdeAccion, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.delete, color: AppEstilos.verdeAccion, size: 20), onPressed: onEliminar),
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.edit, color: AppEstilos.verdeAccion, size: 18), onPressed: onEditar),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vacia() => Container(width: 64, height: 64, color: AppEstilos.bordeOscuro, child: const Icon(Icons.restaurant, color: Colors.white38));
}