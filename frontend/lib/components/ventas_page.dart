import 'package:flutter/material.dart';
import '../core/colores.dart';
import '../services/pedido_service.dart';

/// Pantalla "VENTAS" del admin - Casa del Tamal
class VentasPage extends StatelessWidget {
  static const String routeName = '/ventas';

  const VentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppFondo(
        child: SafeArea(
          child: Column(
            children: [
              AppEncabezado(
                titulo: 'VENTAS',
                mostrarLogo: false,
                iconoDerecho: Icons.eco, // el ícono "chatbot" del tamal
                onIconoDerecho: () {
                  // TODO: aquí se conecta con la misma ChatBotPage
                  // que ya usas en AdminHomePage.
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      AppBotonMenu(
                        texto: 'Diarias',
                        onTap: () => _abrirReporte(context, 'diaria', 'Ventas de hoy'),
                      ),
                      const SizedBox(height: 20),
                      AppBotonMenu(
                        texto: 'De la semana',
                        onTap: () => _abrirReporte(context, 'semanal', 'Ventas de la semana'),
                      ),
                      const SizedBox(height: 20),
                      AppBotonMenu(
                        texto: 'Mensuales',
                        onTap: () => _abrirReporte(context, 'mensual', 'Ventas del mes'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirReporte(BuildContext context, String tipo, String titulo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReporteVentasPage(tipo: tipo, titulo: titulo),
      ),
    );
  }
}

/// Pantalla que muestra el reporte ya calculado por el backend
/// (GET /pedido/reporte?tipo=diaria|semanal|mensual)
class ReporteVentasPage extends StatefulWidget {
  final String tipo;
  final String titulo;

  const ReporteVentasPage({super.key, required this.tipo, required this.titulo});

  @override
  State<ReporteVentasPage> createState() => _ReporteVentasPageState();
}

class _ReporteVentasPageState extends State<ReporteVentasPage> {
  final PedidoService _pedidoService = PedidoService();

  bool _cargando = true;
  String? _error;
  ReporteVentas? _reporte;

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  Future<void> _cargarReporte() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final reporte = await _pedidoService.obtenerReporteVentas(widget.tipo);
      if (!mounted) return;
      setState(() => _reporte = reporte);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _formatoMoneda(double valor) {
    // Formato simple de pesos colombianos, sin depender de paquetes extra.
    final texto = valor.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < texto.length; i++) {
      final posicionDesdeElFinal = texto.length - i;
      buffer.write(texto[i]);
      if (posicionDesdeElFinal > 1 && posicionDesdeElFinal % 3 == 1) {
        buffer.write('.');
      }
    }
    return '\$${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppFondo(
        child: SafeArea(
          child: Column(
            children: [
              AppEncabezado(titulo: widget.titulo, mostrarLogo: false),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildContenido(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarReporte,
              style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.colorDorado),
              child: const Text('Reintentar', style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      );
    }

    final reporte = _reporte!;

    return RefreshIndicator(
      onRefresh: _cargarReporte,
      child: ListView(
        children: [
          AppTarjeta(
            child: Column(
              children: [
                const Text(
                  'Total en ventas',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatoMoneda(reporte.totalVentas),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppEstilos.headerFin,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long, size: 18, color: Colors.black45),
                    const SizedBox(width: 6),
                    Text(
                      '${reporte.cantidadPedidos} pedidos',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (reporte.pedidos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'No hay pedidos en este periodo',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ...reporte.pedidos.map((p) => _buildFilaPedido(p)),
        ],
      ),
    );
  }

  Widget _buildFilaPedido(dynamic pedido) {
    final total = (pedido['total'] as num?)?.toDouble() ?? 0.0;
    final fecha = pedido['fecha_pedido']?.toString() ?? '';
    final estado = pedido['estado']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido #${pedido['id']}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  fecha.length >= 16 ? fecha.substring(0, 16).replaceFirst('T', ' ') : fecha,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  estado,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          Text(
            _formatoMoneda(total),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppEstilos.headerFin),
          ),
        ],
      ),
    );
  }
}