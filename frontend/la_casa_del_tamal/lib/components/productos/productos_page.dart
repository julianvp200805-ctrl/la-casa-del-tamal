import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/components/productos/producto_fila.dart';
import 'package:frontend/components/productos/productos_from_sheet.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/productos/producto_service.dart';

/// Productos: tabla Producto | Lote con los datos reales del inventario.
class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
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
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'mas_producto',
            backgroundColor: AppEstilos.botonMas,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: _agregar,
            child: const Icon(Icons.add, color: Colors.black),
          ),
          const SizedBox(height: 12),
          const ChatFab(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AdminTopBar(),
            const VentaTituloRow(titulo: 'Productos'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
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
          ],
        ),
      ),
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