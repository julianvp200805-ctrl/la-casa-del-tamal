import 'package:flutter/material.dart';
import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/components/ventas/venta_total_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_service.dart';


/// Muestra un reporte del backend: tarjeta de total + filas por producto.
/// Maneja solo los estados de carga y error. La página dueña guarda el
/// `futuro` en su estado y lo recrea al cambiar la selección o reintentar.
class ReporteResultado extends StatelessWidget {
  final Future<ReporteVentas> futuro;
  final String etiqueta;
  final bool verde;
  final VoidCallback onReintentar;

  const ReporteResultado({
    super.key,
    required this.futuro,
    required this.etiqueta,
    required this.onReintentar,
    this.verde = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReporteVentas>(
      future: futuro,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton)),
          );
        }
        if (snap.hasError) {
          final msg = snap.error.toString().replaceAll('Exception: ', '');
          return AppErrorState(mensaje: msg, onReintentar: onReintentar);
        }
        final r = snap.data!;
        return Column(
          children: [
            VentaTotalCard(etiqueta: etiqueta, total: r.totalVentas, verde: verde),
            const SizedBox(height: 18),
            VentaItemsList(items: r.itemsAgrupados),
          ],
        );
      },
    );
  }
}