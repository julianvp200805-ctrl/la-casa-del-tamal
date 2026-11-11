import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';


/// Tarjeta de un plato en "Modificar menú": foto, nombre, descripción y los
/// íconos de eliminar (arriba) y editar (abajo). El disco verde de la esquina
/// es el interruptor de disponibilidad: "-" agota el plato y "+" lo reactiva.
class AdminMenuCard extends StatelessWidget {
  final MenuItem plato;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onToggleDisponibilidad;

  const AdminMenuCard({
    super.key,
    required this.plato,
    required this.onEditar,
    required this.onEliminar,
    required this.onToggleDisponibilidad,
  });

  @override
  Widget build(BuildContext context) {
    final agotado = !plato.disponible;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(12, 28, 4, 10),
          decoration: BoxDecoration(
            color: AppEstilos.inputOscuro,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: agotado ? AppEstilos.rojoChip : AppEstilos.bordeOscuro),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Opacity(
                  opacity: agotado ? 0.35 : 1,
                  child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                      ? Image.network(plato.imagenUrl!, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, _, _) => _vacia())
                      : _vacia(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plato.nombre, style: TextStyle(color: agotado ? Colors.white70 : Colors.white, fontSize: 15, fontFamily: 'serif')),
                    const SizedBox(height: 4),
                    if ((plato.descripcion ?? '').isNotEmpty)
                      Text(plato.descripcion!, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    if (agotado) ...[
                      const SizedBox(height: 6),
                      const _PillAgotado(),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.delete, color: AppEstilos.verdeAccion, size: 20), onPressed: onEliminar),
                  IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.edit, color: AppEstilos.verdeAccion, size: 18), onPressed: onEditar),
                ],
              ),
            ],
          ),
        ),
        // La insignia va clavada en la esquina izquierda de la tarjeta, como
        // en la maqueta; el contenido empieza debajo de ella.
        Positioned(left: 10, top: 9, child: _insigniaDisponibilidad(agotado)),
      ],
    );
  }

  Widget _insigniaDisponibilidad(bool agotado) {
    return Tooltip(
      message: agotado ? 'Habilitar plato' : 'Descontinuar plato',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleDisponibilidad,
          customBorder: const CircleBorder(),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: agotado ? AppEstilos.rojoVencido : AppEstilos.verdeBoton,
              shape: BoxShape.circle,
              border: Border.all(color: AppEstilos.fondoOscuro, width: 2),
            ),
            child: Icon(agotado ? Icons.add : Icons.remove, size: 16, color: AppEstilos.fondoOscuro),
          ),
        ),
      ),
    );
  }

  Widget _vacia() => Container(width: 64, height: 64, color: AppEstilos.bordeOscuro, child: const Icon(Icons.restaurant, color: Colors.white38));
}

class _PillAgotado extends StatelessWidget {
  const _PillAgotado();

  @override
  Widget build(BuildContext context) {
    // Fondo rojo vivo con texto blanco: antes era texto rojo claro sobre un
    // rojo apagado y casi no se leía la letra.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppEstilos.rojoVencido,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Descontinuado',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.4),
      ),
    );
  }
}
