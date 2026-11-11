import 'package:flutter/material.dart';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/components/productos/producto_fila.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/productos/producto_service.dart';

/// Pestaña "Vencidos" de Inventario: alerta roja con el total y botón para
/// sacar cada lote vencido. Al sacarlo, su número de lote queda libre para
/// el próximo ingreso de ese mismo tipo de producto.
class VencidosVista extends StatefulWidget {
  const VencidosVista({super.key});

  @override
  State<VencidosVista> createState() => _VencidosVistaState();
}

class _VencidosVistaState extends State<VencidosVista> {
  final ProductoService _service = ProductoService();
  late Future<List<Producto>> _futuro = _service.obtenerProductos();

  void _recargar() => setState(() => _futuro = _service.obtenerProductos());

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700),
    );
  }

  Future<void> _sacar(Producto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppEstilos.tablaInventario,
        title: const Text('Sacar lote vencido', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Sacar ${p.nombre} (lote ${p.lote}) del inventario? Su número de lote queda libre para el próximo ingreso.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sacar', style: TextStyle(color: AppEstilos.rojoVencido, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.eliminarProducto(p.id);
      if (!mounted) return;
      _mensaje('${p.nombre} (lote ${p.lote}) sacado del inventario');
      _recargar();
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
              Text('Productos vencidos: ${vencidos.length}', style: const TextStyle(color: AppEstilos.rojoVencido, fontSize: 13, fontWeight: FontWeight.bold)),
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
                    onTap: () => _sacar(p),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Sacar', style: TextStyle(color: AppEstilos.rojoVencido, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'serif')),
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
