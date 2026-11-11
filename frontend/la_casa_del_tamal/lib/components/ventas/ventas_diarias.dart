import 'package:flutter/material.dart';
import 'package:frontend/components/ventas/reporte_resultado.dart';
import 'package:frontend/services/pedido/pedido_service.dart';

/// Pestaña "Diario" de Ventas: total de hoy + desglose por producto.
/// La página dueña (VentasPage) pone la barra superior y el título.
class VentasDiariasVista extends StatefulWidget {
  const VentasDiariasVista({super.key});

  @override
  State<VentasDiariasVista> createState() => _VentasDiariasVistaState();
}

class _VentasDiariasVistaState extends State<VentasDiariasVista> {
  final PedidoService _pedidoService = PedidoService();
  late Future<ReporteVentas> _futuro = _pedidoService.obtenerReporteHoy();

  void _recargar() {
    setState(() {
      _futuro = _pedidoService.obtenerReporteHoy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: ReporteResultado(futuro: _futuro, etiqueta: 'Ventas de hoy', onReintentar: _recargar),
    );
  }
}
