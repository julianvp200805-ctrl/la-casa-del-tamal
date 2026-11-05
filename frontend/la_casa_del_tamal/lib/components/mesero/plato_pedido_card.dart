import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';

const Color _amarillo = Color(0xFFFFD60A);

/// Tarjeta de un plato en "Tomar pedido": arriba la etiqueta y la foto, abajo
/// el nombre con la descripción, el lápiz de la nota para cocina y el − n +.
/// Todas miden lo mismo, así un plato recién creado entra con el mismo formato
/// que los demás.
class PlatoPedidoCard extends StatelessWidget {
  final MenuItem plato;
  final int cantidad;
  final VoidCallback onMas;
  final VoidCallback onMenos;
  final String etiqueta;

  /// Nota escrita para la cocina; vacía si el mesero no puso ninguna.
  final String nota;
  final VoidCallback? onEditar;

  const PlatoPedidoCard({
    super.key,
    required this.plato,
    required this.cantidad,
    required this.onMas,
    required this.onMenos,
    this.etiqueta = 'Típico',
    this.nota = '',
    this.onEditar,
  });

  Widget _vacia() => Container(
      width: 58, height: 58, color: AppEstilos.fondoOscuro, child: const Icon(Icons.restaurant, color: Colors.white38));

  Widget _boton(IconData icono, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icono, size: 18, color: onTap == null ? Colors.white24 : _amarillo),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hayImagen = plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty;
    final colorEtiqueta = etiqueta.toLowerCase().startsWith('t') ? const Color(0xFF4ADE60) : _amarillo;
    final seleccion = cantidad > 0;
    return Container(
      height: 152,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppEstilos.platoMesero,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: seleccion ? AppEstilos.meseroOliva : AppEstilos.bordeOscuro, width: seleccion ? 1.3 : 1),
      ),
      child: Column(
        children: [
          Container(
            height: 78,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E4A3C), Color(0xFF2A4238)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: colorEtiqueta, borderRadius: BorderRadius.circular(11)),
                    child: Text(etiqueta, style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 10,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), border: Border.all(color: Colors.black26)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: hayImagen
                          ? Image.network(plato.imagenUrl!, width: 58, height: 58, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _vacia())
                          : _vacia(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Row en lugar de Stack: el Stack encogía al ancho del texto y con
          // nombres cortos el lápiz y el contador salían corridos.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plato.nombre, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'serif', height: 1.2)),
                        const SizedBox(height: 3),
                        if ((plato.descripcion ?? '').isNotEmpty)
                          Text(plato.descripcion!, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.3))
                        else
                          const Text('Sin descripción', style: TextStyle(color: Colors.white24, fontSize: 10, height: 1.3)),
                        if (nota.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.notes, size: 11, color: AppEstilos.meseroOliva),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(nota, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppEstilos.meseroOliva, fontSize: 10, fontStyle: FontStyle.italic)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: nota.isEmpty ? 'Nota para cocina' : 'Editar la nota',
                        child: InkWell(
                          onTap: onEditar,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(Icons.edit, size: 17, color: nota.isEmpty ? Colors.white70 : AppEstilos.meseroOliva),
                          ),
                        ),
                      ),
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(color: AppEstilos.fondoOscuro, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _boton(Icons.remove, cantidad > 0 ? onMenos : null),
                            SizedBox(
                              width: 26,
                              child: Text('$cantidad', textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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