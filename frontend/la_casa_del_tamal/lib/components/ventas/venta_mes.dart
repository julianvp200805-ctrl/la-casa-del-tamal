import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/components/ventas/venta_total_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_service.dart';

const _meses = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

/// Ventas del mes: total del mes y el total de cada semana (barras). Cada
/// semana se pide al backend por su rango exacto de fechas.
class VentasMesPage extends StatefulWidget {
  const VentasMesPage({super.key});

  @override
  State<VentasMesPage> createState() => _VentasMesPageState();
}

class _VentasMesPageState extends State<VentasMesPage> {
  final PedidoService _pedidoService = PedidoService();
  int _mes = DateTime.now().month;
  late Future<List<ReporteVentas>> _futuro = _cargarMes(_mes);

  // Semanas 1-3 = días 1-7, 8-14, 15-21; la semana 4 llega hasta fin de mes.
  Future<List<ReporteVentas>> _cargarMes(int mes) {
    final anio = DateTime.now().year;
    final ultimo = DateTime(anio, mes + 1, 0).day;
    return Future.wait([
      for (int n = 1; n <= 4; n++)
        _pedidoService.obtenerReporteRango(
          DateTime(anio, mes, (n - 1) * 7 + 1),
          DateTime(anio, mes, n < 4 ? n * 7 : ultimo, 23, 59, 59),
        ),
    ]);
  }

  void _elegir(int mes) => setState(() {
        _mes = mes;
        _futuro = _cargarMes(mes);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: const ChatFab(),
      body: SafeArea(
        child: Column(
          children: [
            const AdminTopBar(),
            const VentaTituloRow(titulo: 'Mes', centrado: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                child: Column(
                  children: [
                    _selectorMes(),
                    const SizedBox(height: 16),
                    FutureBuilder<List<ReporteVentas>>(
                      future: _futuro,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
                        }
                        if (snap.hasError) {
                          return AppErrorState(mensaje: snap.error.toString().replaceAll('Exception: ', ''), onReintentar: () => _elegir(_mes));
                        }
                        return _resumen(snap.data!.map((r) => r.totalVentas).toList());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectorMes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(color: AppEstilos.inputOscuro, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppEstilos.bordeOscuro)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _mes,
          isExpanded: true,
          dropdownColor: AppEstilos.inputOscuro,
          icon: const Icon(Icons.expand_more, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'serif'),
          items: [for (int m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(_meses[m]))],
          onChanged: (m) {
            if (m != null) _elegir(m);
          },
        ),
      ),
    );
  }

  Widget _resumen(List<double> semanas) {
    final total = semanas.fold<double>(0, (a, b) => a + b);
    final mayor = semanas.fold<double>(0, (a, b) => a > b ? a : b);
    return Column(
      children: [
        VentaTotalCard(etiqueta: 'Total mes', total: total, verde: false),
        const SizedBox(height: 22),
        for (int i = 0; i < semanas.length; i++) _FilaSemana(numero: i + 1, total: semanas[i], proporcion: mayor == 0 ? 0 : semanas[i] / mayor),
      ],
    );
  }
}

class _FilaSemana extends StatelessWidget {
  final int numero;
  final double total;
  final double proporcion; // 0..1 respecto a la mejor semana del mes

  const _FilaSemana({required this.numero, required this.total, required this.proporcion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(color: AppEstilos.inputOscuro, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppEstilos.bordeOscuro)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('semana $numero', style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'serif'))),
              Text('\$${formatoMoneda(total)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'serif')),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: proporcion,
            minHeight: 3,
            backgroundColor: Colors.white,
            valueColor: const AlwaysStoppedAnimation(AppEstilos.verdeBoton),
          ),
        ],
      ),
    );
  }
}