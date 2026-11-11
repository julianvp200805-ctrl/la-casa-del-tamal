import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/components/cocina/cocina_top_bar.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/mesas.dart';
import 'package:frontend/services/mesero/mesero.dart';
import 'package:frontend/services/pedido/pedido_card.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

/// Bandeja de cocina: cada pedido es un acordeón con una casilla por plato.
/// "Preparar" lo pasa a en proceso; "Marcar listo" exige todas las casillas
/// marcadas y lo deja listo para que el mesero lo entregue.
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
  final Set<String> _actualizando = {};
  bool _cargando = true;
  bool _ocupado = false;
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
    if (_ocupado) return;
    _ocupado = true;
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
    } finally {
      _ocupado = false;
    }
  }

  Future<void> _cambiarEstado(PedidoProceso p, String nuevoEstado) async {
    if (_actualizando.contains(p.id)) return;
    setState(() => _actualizando.add(p.id));
    try {
      await _service.cambiarEstado(p.id, nuevoEstado);
      if (!mounted) return;
      _mensaje('Pedido ${p.numero}: ${textoEstado(nuevoEstado)}');
      // Reflejo inmediato en la lista mientras llega el sondeo de fondo.
      setState(() {
        if (nuevoEstado == 'listo') {
          _pedidosCocina.removeWhere((x) => x.id == p.id);
          _checkstates.remove(p.id);
          _abiertos.remove(p.id);
        } else {
          _pedidosCocina = _pedidosCocina.map((x) => x.id == p.id ? x.copyWith(estado: nuevoEstado) : x).toList();
        }
      });
      _cargarPedidos(silencioso: true);
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    } finally {
      if (mounted) setState(() => _actualizando.remove(p.id));
    }
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
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
            const TituloCocina(texto: 'Bandeja de pedidos'),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.acentoCocina));
    if (_error != null) return AppErrorState(mensaje: _error!, onReintentar: _cargarPedidos);

    return RefreshIndicator(
      onRefresh: _cargarPedidos,
      color: AppEstilos.acentoCocina,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          if (_pedidosCocina.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 50, bottom: 24),
              child: AppEmptyState(mensaje: 'No hay pedidos pendientes en cocina', icono: Icons.soup_kitchen_outlined),
            ),
            const _BandaVacia(),
          ],
          for (final p in _pedidosCocina) _tarjetaPedido(p),
        ],
      ),
    );
  }

  Widget _tarjetaPedido(PedidoProceso p) {
    final items = p.items;
    final esPendiente = p.estado == 'pendiente';
    final abierto = _abiertos.contains(p.id);
    // El cupo no viene en el pedido: es el que le toca a esa mesa del salón.
    final numero = mesaNumero(p.numero);
    final cupo = numero == null ? null : cupoMesa(numero);
    final actualizando = _actualizando.contains(p.id);
    final (fondoEstado, colorEstado) = coloresEstado(p.estado);

    final guardados = _checkstates[p.id];
    final checks = (guardados != null && guardados.length == items.length)
        ? guardados
        : List.generate(items.length, (_) => false);
    _checkstates[p.id] = checks;
    final marcados = checks.where((c) => c).length;
    final todoListo = items.isNotEmpty && marcados == items.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 4, 10, 12),
      decoration: BoxDecoration(
        color: AppEstilos.platoMesero,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: esPendiente ? AppEstilos.bordeOscuro : AppEstilos.acentoCocina, width: esPendiente ? 1 : 1.3),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => abierto ? _abiertos.remove(p.id) : _abiertos.add(p.id)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.soup_kitchen_outlined, color: AppEstilos.acentoCocina, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.cabecera} ${p.numero}',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'serif', fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (p.hora.isNotEmpty) p.hora,
                            if (cupo != null) '$cupo personas',
                          ].join(' · '),
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: fondoEstado, borderRadius: BorderRadius.circular(10)),
                    child: Text(textoEstado(p.estado), style: TextStyle(color: colorEstado, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 4),
                  Icon(abierto ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppEstilos.acentoCocina, size: 26),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !abierto
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${items[i].cantidad} × ${items[i].nombre}'.trim(),
                                        style: TextStyle(
                                          color: checks[i] ? Colors.white38 : Colors.white70,
                                          fontSize: 13,
                                          decoration: checks[i] ? TextDecoration.lineThrough : null,
                                        )),
                                    if (items[i].nota.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2, right: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.notes, size: 12, color: AppEstilos.acentoCocina),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(items[i].nota,
                                                  style: const TextStyle(
                                                      color: AppEstilos.acentoCocina, fontSize: 11, fontStyle: FontStyle.italic, height: 1.25)),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 34,
                                height: 34,
                                child: Checkbox(
                                  value: checks[i],
                                  fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppEstilos.acentoCocina : Colors.transparent),
                                  checkColor: Colors.black87,
                                  side: const BorderSide(color: Colors.white70),
                                  onChanged: esPendiente || actualizando ? null : (v) => setState(() => checks[i] = v!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!esPendiente) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: items.isEmpty ? 0 : marcados / items.length,
                                  minHeight: 5,
                                  color: AppEstilos.acentoCocina,
                                  backgroundColor: AppEstilos.bordeOscuro,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Platos listos: $marcados de ${items.length}',
                                style: const TextStyle(color: AppEstilos.acentoCocina, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: actualizando || (!esPendiente && !todoListo)
                              ? null
                              : () => _cambiarEstado(p, esPendiente ? 'en_proceso' : 'listo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppEstilos.acentoCocina,
                            disabledBackgroundColor: AppEstilos.acentoCocina.withValues(alpha: 0.35),
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: actualizando
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54))
                              : Icon(esPendiente ? Icons.local_fire_department_outlined : Icons.done_all, size: 20),
                          label: Text(
                            actualizando ? 'Actualizando...' : (esPendiente ? 'Preparar' : 'Marcar listo'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if (!esPendiente && !todoListo)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text('Marca todos los platos para poder marcar el pedido como listo',
                              style: TextStyle(color: Colors.white38, fontSize: 11)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Banda ámbar que cierra la bandeja cuando no queda ningún pedido.
class _BandaVacia extends StatelessWidget {
  const _BandaVacia();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppEstilos.botonMesero, borderRadius: BorderRadius.circular(10)),
        child: const Text('No hay más pedidos',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'serif', fontWeight: FontWeight.bold)),
      );
}
