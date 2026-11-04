import 'package:flutter/material.dart';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/components/productos/producto_fila.dart';
import 'package:frontend/components/productos/productos_from_sheet.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/productos/producto_service.dart';

/// Pestaña "Productos" de Inventario: tabla Producto | Lote con los datos
/// reales. La página dueña (InventarioPage) pone barra, título y botonera.
class ProductosVista extends StatefulWidget {
  const ProductosVista({super.key});

  @override
  State<ProductosVista> createState() => _ProductosVistaState();
}

class _ProductosVistaState extends State<ProductosVista> {
  final ProductoService _service = ProductoService();
  late Future<List<Producto>> _futuro = _service.obtenerProductos();

  void _recargar() => setState(() => _futuro = _service.obtenerProductos());

  Future<void> _agregar() async {
    final guardado = await mostrarFormProducto(context, _service);
    if (guardado == true) _recargar();
  }

  Color _colorLote(Producto p) {
    if (p.vencido) return AppEstilos.rojoChip;
    return p.porVencer ? AppEstilos.pillPorVencer : AppEstilos.pillFresco;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
            child: FutureBuilder<List<Producto>>(
              future: _futuro,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
                }
                if (snap.hasError) {
                  return AppErrorState(mensaje: snap.error.toString().replaceAll('Exception: ', ''), onReintentar: _recargar);
                }
                final lista = [...snap.data!]..sort((a, b) => (a.vencimiento ?? DateTime(9999)).compareTo(b.vencimiento ?? DateTime(9999)));
                if (lista.isEmpty) return const AppEmptyState(mensaje: 'No hay productos registrados.\nUsa el botón + para agregar.');
                return _tabla(lista);
              },
            ),
          ),
        ),
        Positioned(right: 24, bottom: 24, child: _BotonMas(onTap: _agregar)),
      ],
    );
  }

  Widget _tabla(List<Producto> lista) {
    const cabecera = TextStyle(color: AppEstilos.headerInicio, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'serif');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppEstilos.tablaInventario, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppEstilos.bordeOscuro)),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 4, 20, 10),
            child: Row(children: [Expanded(child: Text('Producto', style: cabecera)), Text('Lote', style: cabecera)]),
          ),
          for (final p in lista)
            ProductoFila(
              producto: p,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: _colorLote(p), borderRadius: BorderRadius.circular(12)),
                child: Text(p.lote, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Cuadrado verde con + de la maqueta. Botón normal, no FAB: el FAB ya lo usa
/// el shell para Tamalin y se montarían uno sobre otro.
class _BotonMas extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonMas({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppEstilos.botonMas,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: const SizedBox(
          width: 46,
          height: 46,
          child: Icon(Icons.add, color: Colors.black, size: 26),
        ),
      ),
    );
  }
}