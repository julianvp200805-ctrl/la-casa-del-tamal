import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/components/productos/producto_fila.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/productos/producto_service.dart';

/// Productos vencidos: alerta roja con el total y botón para descartar cada uno.
class ProductosVencidosPage extends StatefulWidget {
  const ProductosVencidosPage({super.key});

  @override
  State<ProductosVencidosPage> createState() => _ProductosVencidosPageState();
}

class _ProductosVencidosPageState extends State<ProductosVencidosPage> {
  final ProductoService _service = ProductoService();
  late Future<List<Producto>> _futuro = _service.obtenerProductos();

  void _recargar() => setState(() => _futuro = _service.obtenerProductos());

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700),
    );
  }

  Future<void> _descartar(Producto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Descartar producto'),
        content: Text('¿Descartar ${p.nombre} (lote ${p.lote})? Se eliminará del inventario.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Descartar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.eliminarProducto(p.id);
      if (!mounted) return;
      _mensaje('${p.nombre} descartado');
      _recargar();
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: const ChatFab(),
      body: SafeArea(
        child: Column(
          children: [
            const AdminTopBar(),
            const VentaTituloRow(titulo: 'Productos vencidos'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                child: FutureBuilder<List<Producto>>(
                  future: _futuro,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
                    }
                    if (snap.hasError) {
                      return AppErrorState(mensaje: snap.error.toString().replaceAll('Exception: ', ''), onReintentar: _recargar);
                    }
                    final vencidos = snap.data!.where((p) => p.vencido).toList();
                    if (vencidos.isEmpty) return const AppEmptyState(mensaje: 'Todo al día: no hay productos vencidos');
                    return _contenido(vencidos);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(List<Producto> vencidos) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: AppEstilos.rojoFondo, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppEstilos.rojoChip)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_rounded, color: AppEstilos.rojoVencido, size: 20),
              const SizedBox(width: 10),
              Text('productos vencidos ${vencidos.length}', style: const TextStyle(color: AppEstilos.rojoVencido, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppEstilos.tablaInventario, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppEstilos.bordeOscuro)),
          child: Column(
            children: [
              for (final p in vencidos)
                ProductoFila(
                  producto: p,
                  fechaEnChip: true,
                  trailing: InkWell(
                    onTap: () => _descartar(p),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Descartar', style: TextStyle(color: AppEstilos.rojoVencido, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}