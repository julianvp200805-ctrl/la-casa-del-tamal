import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/components/chat/aviso_listos.dart';
import 'package:frontend/components/mesero/mesero_top_bar.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/components/mesero/pedido_estado_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/mesero/mesero.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

/// Se refresca solo cada 15 segundos para ver cuándo la cocina deja un pedido "listo".
class EstadosPedidosPage extends StatefulWidget {
  static const String routeName = '/estados-pedidos';
  const EstadosPedidosPage({super.key});

  @override
  State<EstadosPedidosPage> createState() => _EstadosPedidosPageState();
}

class _EstadosPedidosPageState extends State<EstadosPedidosPage> {
  final MeseroService _service = MeseroService();
  List<PedidoProceso> _pedidos = [];
  bool _cargando = true;
  bool _ocupado = false;
  String? _entregandoId;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargar();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _cargar(silencioso: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _prioridad(String e) => e == 'listo' ? 0 : (e == 'en_proceso' ? 1 : 2);

  Future<void> _cargar({bool silencioso = false}) async {
    if (_ocupado) return;
    _ocupado = true;
    if (!silencioso) setState(() { _cargando = _pedidos.isEmpty; _error = null; });
    try {
      final lista = await _service.obtenerAbiertos();
      final ordenada = lista.asMap().entries.toList()
        ..sort((a, b) {
          final c = _prioridad(a.value.estado).compareTo(_prioridad(b.value.estado));
          return c != 0 ? c : a.key.compareTo(b.key);
        });
      if (!mounted) return;
      setState(() { _pedidos = ordenada.map((e) => e.value).toList(); _error = null; _cargando = false; });
    } catch (e) {
      if (mounted && !silencioso) setState(() { _error = e.toString(); _cargando = false; });
    } finally {
      _ocupado = false;
    }
  }

  // Entregar registra la venta: se pide confirmación para no tocarlo por error.
  Future<void> _entregar(PedidoProceso p) async {
    if (_entregandoId != null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppEstilos.inputOscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('¿Entregar ${p.cabecera} ${p.numero}?',
            style: const TextStyle(color: Colors.white, fontFamily: 'serif', fontSize: 18)),
        content: Text('La venta se registrará por \$${formatoPesos(p.total)}.',
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppEstilos.pillFresco,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Entregar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    setState(() => _entregandoId = p.id);
    try {
      await _service.entregar(p.id);
      if (!mounted) return;
      setState(() => _pedidos.removeWhere((x) => x.id == p.id));
      _mensaje('${p.cabecera} ${p.numero} entregado · Venta registrada');
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    } finally {
      if (mounted) setState(() => _entregandoId = null);
    }
  }

  void _mensaje(String t, {bool esError = false}) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppEstilos.fondoOscuro,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const MeseroTopBar(),
              const TituloMesero(texto: 'Estados\nde los pedidos', centrado: true),
              Expanded(child: _contenido()),
            ],
          ),
        ),
      );

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.meseroOliva));
    if (_error != null) return AppErrorState(mensaje: _error!, onReintentar: _cargar);
    final listos = _pedidos.where((p) => p.estado == 'listo').length;
    return RefreshIndicator(
      color: AppEstilos.meseroOliva,
      onRefresh: _cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        children: [
          if (listos > 0) AvisoListos(listos: listos),
          if (_pedidos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: AppEmptyState(mensaje: 'No tienes pedidos en proceso', icono: Icons.receipt_long_outlined),
            ),
          for (final p in _pedidos)
            PedidoEstadoCard(
              pedido: p,
              entregando: _entregandoId == p.id,
              onEntregar: () => _entregar(p),
            ),
        ],
      ),
    );
  }
}