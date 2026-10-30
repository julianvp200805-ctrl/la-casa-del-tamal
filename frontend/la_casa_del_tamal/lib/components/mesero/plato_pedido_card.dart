import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';

const Color _amarillo = Color(0xFFFFD60A);

/// Franja superior (etiqueta + foto) y abajo nombre, descripción, editar y − n +.
class PlatoPedidoCard extends StatelessWidget {
  final MenuItem plato;
  final int cantidad;
  final VoidCallback onMas;
  final VoidCallback onMenos;
  final String etiqueta;
  final VoidCallback? onEditar;

  const PlatoPedidoCard({
    super.key,
    required this.plato,
    required this.cantidad,
    required this.onMas,
    required this.onMenos,
    this.etiqueta = 'Típico',
    this.onEditar,
  });

  Widget _vacia() => Container(
      width: 54, height: 54, color: AppEstilos.fondoOscuro, child: const Icon(Icons.restaurant, color: Colors.white38));

  Widget _boton(IconData icono, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(icono, size: 18, color: onTap == null ? Colors.white24 : _amarillo),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hayImagen = plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty;
    final colorEtiqueta = etiqueta.toLowerCase().startsWith('t') ? const Color(0xFF4ADE60) : _amarillo;
    return Container(
      height: 136,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppEstilos.platoMesero,
        borderRadius: BorderRadius.circular(8),
        border: cantidad > 0 ? Border.all(color: AppEstilos.meseroOliva, width: 1.2) : null,
      ),
      child: Column(
        children: [
          Container(
            height: 68,
            width: double.infinity,
            color: const Color(0xFF2E4A3C),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(color: colorEtiqueta, borderRadius: BorderRadius.circular(10)),
                    child: Text(etiqueta, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                  ),
                ),
                Positioned(
                  right: 38,
                  top: 7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: hayImagen
                        ? Image.network(plato.imagenUrl!, width: 54, height: 54, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _vacia())
                        : _vacia(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plato.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'serif')),
                      if ((plato.descripcion ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 90),
                          child: Text(plato.descripcion!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'serif')),
                        ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(onTap: onEditar, child: const Icon(Icons.edit, size: 18, color: Colors.white)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(color: AppEstilos.fondoOscuro.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _boton(Icons.remove, cantidad > 0 ? onMenos : null),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('$cantidad', style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                          _boton(Icons.add, onMas),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}