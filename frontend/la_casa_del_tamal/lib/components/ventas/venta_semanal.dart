import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/ventas/reporte_resultado.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_service.dart';

const _letras = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

/// Ventas de la semana: se elige un día (L M M J V S D) y se pide al
/// backend el reporte de ese día exacto de la semana actual.
class VentasSemanaPage extends StatefulWidget {
  const VentasSemanaPage({super.key});

  @override
  State<VentasSemanaPage> createState() => _VentasSemanaPageState();
}

class _VentasSemanaPageState extends State<VentasSemanaPage> {
  final PedidoService _pedidoService = PedidoService();
  int _dia = DateTime.now().weekday - 1; // empieza en el día de hoy
  late Future<ReporteVentas> _futuro = _cargarDia(_dia);

  Future<ReporteVentas> _cargarDia(int indice) {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day - (hoy.weekday - 1) + indice);
    final fin = DateTime(inicio.year, inicio.month, inicio.day, 23, 59, 59);
    return _pedidoService.obtenerReporteRango(inicio, fin);
  }

  void _elegir(int indice) => setState(() {
        _dia = indice;
        _futuro = _cargarDia(indice);
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
            const VentaTituloRow(titulo: 'semana'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < _letras.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          Expanded(child: _Chip(letra: _letras[i], activo: i == _dia, onTap: () => _elegir(i))),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    ReporteResultado(futuro: _futuro, etiqueta: 'Total ventas', verde: false, onReintentar: () => _elegir(_dia)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String letra;
  final bool activo;
  final VoidCallback onTap;

  const _Chip({required this.letra, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activo ? AppEstilos.verdeBoton : AppEstilos.inputOscuro,
          borderRadius: BorderRadius.circular(8),
          border: activo ? null : Border.all(color: AppEstilos.bordeOscuro),
        ),
        child: Text(letra, style: TextStyle(color: activo ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontFamily: 'serif')),
      ),
    );
  }
}