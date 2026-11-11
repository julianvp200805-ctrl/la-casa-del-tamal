import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';

const Color _amarillo = Color(0xFFFFD60A);

/// Tarjeta de un plato en "Tomar pedido": foto, nombre con precio,
/// descripción, nota para cocina y el contador − n +. La altura se adapta
/// al contenido: con nota o descripción larga ya no se desborda.
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
      width: 72,
      height: 72,
      color: AppEstilos.fondoOscuro,
      child: const Icon(Icons.restaurant, color: Colors.white38, size: 28));

  Widget _boton(IconData icono, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icono, size: 18, color: onTap == null ? Colors.white24 : _amarillo),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hayImagen = plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty;
    final colorEtiqueta = etiqueta.toLowerCase().startsWith('t') ? const Color(0xFF4ADE60) : _amarillo;
    final seleccion = cantidad > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppEstilos.platoMesero,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: seleccion ? AppEstilos.meseroOliva : AppEstilos.bordeOscuro, width: seleccion ? 1.4 : 1),
        boxShadow: seleccion
            ? [BoxShadow(color: AppEstilos.meseroOliva.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: hayImagen
                    ? Image.network(plato.imagenUrl!, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, _, _) => _vacia())
                    : _vacia(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            plato.nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'serif', fontWeight: FontWeight.bold, height: 1.2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('\$${formatoPesos(plato.precio)}',
                            style: const TextStyle(color: _amarillo, fontSize: 13, fontFamily: 'serif', fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (plato.descripcion ?? '').isEmpty ? 'Sin descripción' : plato.descripcion!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: (plato.descripcion ?? '').isEmpty ? Colors.white24 : Colors.white54,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                    if (nota.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.notes, size: 12, color: AppEstilos.meseroOliva),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(nota,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppEstilos.meseroOliva, fontSize: 11, fontStyle: FontStyle.italic, height: 1.25)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: colorEtiqueta, borderRadius: BorderRadius.circular(10)),
                child: Text(etiqueta, style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Tooltip(
                message: nota.isEmpty ? 'Nota para cocina' : 'Editar la nota',
                child: InkWell(
                  onTap: onEditar,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.edit_note, size: 21, color: nota.isEmpty ? Colors.white70 : AppEstilos.meseroOliva),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: AppEstilos.fondoOscuro, borderRadius: BorderRadius.circular(17)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _boton(Icons.remove, cantidad > 0 ? onMenos : null),
                    SizedBox(
                      width: 28,
                      child: Text('$cantidad',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: seleccion ? _amarillo : Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    _boton(Icons.add, onMas),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}