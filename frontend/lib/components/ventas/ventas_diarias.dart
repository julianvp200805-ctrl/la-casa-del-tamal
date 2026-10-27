import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/ventas/reporte_resultado.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_service.dart';
/// Ventas diarias: total de hoy + desglose por producto (backend).
class VentasDiariasPage extends StatefulWidget {
  const VentasDiariasPage({super.key});

  @override
  State<VentasDiariasPage> createState() => _VentasDiariasPageState();
}

class _VentasDiariasPageState extends State<VentasDiariasPage> {
  final PedidoService _pedidoService = PedidoService();
  late Future<ReporteVentas> _futuro = _pedidoService.obtenerReporteVentas('diaria');

  void _recargar() => setState(() => _futuro = _pedidoService.obtenerReporteVentas('diaria'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: const ChatFab(),
      body: SafeArea(
        child: Column(
          children: [
            const AdminTopBar(),
            const VentaTituloRow(titulo: 'Ventas diarias'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                child: ReporteResultado(futuro: _futuro, etiqueta: 'ventas de hoy', onReintentar: _recargar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}