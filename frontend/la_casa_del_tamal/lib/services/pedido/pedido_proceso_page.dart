import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_card.dart';
import 'package:frontend/services/pedido/pedido_detalle_sheet.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';
import 'package:frontend/services/pedido/pedido_service.dart';

/// Pedidos en proceso: lista del backend; el estado se cambia desde cada tarjeta.
class PedidosProcesoPage extends StatefulWidget {
  static const String routeName = '/pedidos-proceso';
  const PedidosProcesoPage({super.key});

  @override
  State<PedidosProcesoPage> createState() => _PedidosProcesoPageState();
}

class _PedidosProcesoPageState extends State<PedidosProcesoPage> {
  final PedidoService _service = PedidoService();
  List<PedidoProceso> _pedidos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = _pedidos.isEmpty; _error = null; });
    try {
      final lista = await _service.obtenerPedidosEnProceso();
      if (!mounted) return;
      setState(() => _pedidos = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarEstado(PedidoProceso p, String nuevo) async {
    if (nuevo == p.estado) return;
    try {
      await _service.cambiarEstado(p.id, nuevo);
      if (!mounted) return;
      setState(() {
        if (estadosFinales.contains(nuevo)) {
          _pedidos.removeWhere((x) => x.id == p.id);
        } else {
          final i = _pedidos.indexWhere((x) => x.id == p.id);
          if (i >= 0) _pedidos[i] = p.copyWith(estado: nuevo);
        }
      });
      _mensaje('${p.cabecera} ${p.numero}: ${textoEstado(nuevo)}');
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    }
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700),
    );
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
            const VentaTituloRow(titulo: 'Pedidos en proceso'),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
    if (_error != null) return AppErrorState(mensaje: _error!, onReintentar: _cargar);
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
        children: [
          if (_pedidos.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 60), child: AppEmptyState(mensaje: 'No hay pedidos en proceso')),
          for (final p in _pedidos)
            PedidoCard(pedido: p, onEstado: (e) => _cambiarEstado(p, e), onDetalle: () => mostrarDetallePedido(context, p)),
        ],
      ),
    );
  }
}