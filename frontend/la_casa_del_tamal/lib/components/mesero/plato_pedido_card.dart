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
      height: 148,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppEstilos.platoMesero,
        borderRadius: BorderRadius.circular(10),
        border: cantidad > 0 ? Border.all(color: AppEstilos.meseroOliva, width: 1.2) : null,
      ),
      child: Column(
        children: [
          Container(
            height: 74,
            width: double.infinity,
            color: const Color(0xFF2E4A3C),
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(color: colorEtiqueta, borderRadius: BorderRadius.circular(10)),
                    child: Text(etiqueta, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 10,
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
          // Row en lugar de Stack: el Stack encogía al ancho del texto y con
          // nombres cortos el lápiz y el contador salían corridos.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plato.nombre, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'serif')),
                        if ((plato.descripcion ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(plato.descripcion!, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.25)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(onTap: onEditar, child: const Icon(Icons.edit, size: 17, color: Colors.white70)),
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(color: AppEstilos.fondoOscuro, borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _boton(Icons.remove, cantidad > 0 ? onMenos : null),
                            SizedBox(
                              width: 26,
                              child: Text('$cantidad', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                            _boton(Icons.add, onMas),
                          ],
                        ),
                      ),
                    ],
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