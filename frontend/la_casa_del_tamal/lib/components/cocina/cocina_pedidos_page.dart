import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/components/cocina/cocina_top_bar.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/mesero/mesero.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

/// Bandeja de cocina: cada pedido es un acordeón con una casilla por plato y
/// el botón "Entregar" (maqueta 30).
class CocinaPedidosPage extends StatefulWidget {
  const CocinaPedidosPage({super.key});

  @override
  State<CocinaPedidosPage> createState() => _CocinaPedidosPageState();
}

class _CocinaPedidosPageState extends State<CocinaPedidosPage> {
  final MeseroService _service = MeseroService();
  List<PedidoProceso> _pedidosCocina = [];
  final Map<String, List<bool>> _checkstates = {};
  final Set<String> _abiertos = {};
  bool _cargando = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _cargarPedidos(silencioso: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarPedidos({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() {
        _cargando = _pedidosCocina.isEmpty;
        _error = null;
      });
    }
    try {
      final lista = await _service.obtenerAbiertosCocina();
      if (!mounted) return;

      setState(() {
        _pedidosCocina = lista.where((p) => p.estado == 'pendiente' || p.estado == 'en_proceso').toList();
        _error = null;
        _cargando = false;
      });
    } catch (e) {
      if (mounted && !silencioso) {
        setState(() {
          _error = e.toString();
          _cargando = false;
        });
      }
    }
  }

  Future<void> _cambiarEstado(PedidoProceso p, String nuevoEstado) async {
    try {
      await _service.cambiarEstado(p.id, nuevoEstado);
      _mensaje('Pedido ${p.numero} actualizado a $nuevoEstado');
      _cargarPedidos();
    } catch (e) {
      _mensaje(e.toString(), esError: true);
    }
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CocinaTopBar(),
            const TituloCocina(texto: 'Bandeja Pedidos'),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.acentoCocina));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.white70)));
    if (_pedidosCocina.isEmpty) return const Align(alignment: Alignment.topCenter, child: _BandaVacia());

    return RefreshIndicator(
      onRefresh: _cargarPedidos,
      color: AppEstilos.acentoCocina,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          for (final p in _pedidosCocina) _tarjetaPedido(p),
          const Padding(padding: EdgeInsets.only(top: 10), child: _BandaVacia()),
        ],
      ),
    );
  }

  Widget _tarjetaPedido(PedidoProceso p) {
    final lineas = [for (final i in p.items) '${i.cantidad} ${i.nombre}'];
    final esPendiente = p.estado == 'pendiente';
    final abierto = _abiertos.contains(p.id);
    // "personas" aún no viene del backend; se lee tolerando que falte.
    Object? personas;
    try { personas = (p as dynamic).personas; } catch (_) { personas = null; }

    if (!_checkstates.containsKey(p.id) || _checkstates[p.id]!.length != lineas.length) {
      _checkstates[p.id] = List.generate(lineas.length, (_) => false);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 4, 8, 10),
      decoration: BoxDecoration(
        color: AppEstilos.platoMesero,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => abierto ? _abiertos.remove(p.id) : _abiertos.add(p.id)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white70),
                  const SizedBox(width: 10),
                  Text('${p.cabecera} ${p.numero}', style: const TextStyle(color: Colors.white, fontSize: 15)),
                  const SizedBox(width: 10),
                  if (personas != null && '$personas' != '0')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF1F3A2C), borderRadius: BorderRadius.circular(8)),
                      child: Text('personas $personas', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  const Spacer(),
                  Icon(abierto ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppEstilos.acentoCocina, size: 26),
                ],
              ),
            ),
          ),
          if (abierto) ...[
            for (var i = 0; i < lineas.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Expanded(child: Text(lineas[i].trim(), style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: Checkbox(
                        value: _checkstates[p.id]![i],
                        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : Colors.transparent),
                        checkColor: Colors.black87,
                        side: const BorderSide(color: Colors.white70),
                        onChanged: esPendiente ? null : (v) => setState(() => _checkstates[p.id]![i] = v!),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: () => _cambiarEstado(p, esPendiente ? 'en_proceso' : 'listo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppEstilos.botonMesero,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(esPendiente ? 'Preparar' : 'Entregar',
                      style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// La maqueta cierra la bandeja con la banda ámbar "No hay mas pedidos".
class _BandaVacia extends StatelessWidget {
  const _BandaVacia();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: AppEstilos.botonMesero,
        child: const Text('No hay mas pedidos',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'serif')),
      );
}
