import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';


/// Tarjeta de un plato en el menú público (solo lectura).
class MenuCard extends StatelessWidget {
  final MenuItem plato;
  final String precioFormateado;

  const MenuCard({super.key, required this.plato, required this.precioFormateado});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                ? Image.network(plato.imagenUrl!, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
                : _fallback(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plato.nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if ((plato.descripcion ?? '').isNotEmpty)
                  Text(plato.descripcion!, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Text('Precio: $precioFormateado', style: const TextStyle(color: AppEstilos.verdeBoton, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(width: 80, height: 80, color: AppEstilos.bordeOscuro, child: const Icon(Icons.restaurant, color: Colors.white38));
}