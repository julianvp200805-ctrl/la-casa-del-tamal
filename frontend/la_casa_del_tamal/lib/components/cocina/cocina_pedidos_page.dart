import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/mesero/mesero.dart';
import 'package:frontend/services/pedido/pedido_proceso.dart';

class CocinaPedidosPage extends StatefulWidget {
  const CocinaPedidosPage({super.key});

  @override
  State<CocinaPedidosPage> createState() => _CocinaPedidosPageState();
}

class _CocinaPedidosPageState extends State<CocinaPedidosPage> {
  final MeseroService _service = MeseroService();
  List<PedidoProceso> _pedidosCocina = [];
  final Map<String, List<bool>> _checkstates = {};
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
      final lista = await _service.obtenerAbiertos();
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
      if (nuevoEstado == 'listo') {
        await _service.entregar(p.id);
      }
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Text('Bandeja Pedidos', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                ],
              ),
            ),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.white70)));
    if (_pedidosCocina.isEmpty) {
      return const Center(child: Text('No hay mas pedidos', style: TextStyle(color: AppEstilos.colorDorado, fontSize: 16, fontWeight: FontWeight.bold)));
    }

    return RefreshIndicator(
      onRefresh: _cargarPedidos,
      color: AppEstilos.verdeBoton,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _pedidosCocina.length,
        itemBuilder: (context, idx) => _buildTarjetaPedido(_pedidosCocina[idx]),
      ),
    );
  }

  Widget _buildTarjetaPedido(PedidoProceso p) {
    final esPendiente = p.estado == 'pendiente';
    
    // Tratamos p.descripcion dinámicamente según el tipado de tu modelo original de Flutter
    final rawDesc = p.descripcion;
    List<String> itemsPlatos = [];
    
    if (rawDesc is List) {
      itemsPlatos = rawDesc.map((e) => e.toString()).toList();
    } else if (rawDesc != null) {
      final strDesc = rawDesc.toString();
      itemsPlatos = strDesc.isNotEmpty ? strDesc.split(',') : <String>[];
    }
    
    if (!_checkstates.containsKey(p.id) || _checkstates[p.id]!.length != itemsPlatos.length) {
      _checkstates[p.id] = List.generate(itemsPlatos.length, (_) => false);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: AppEstilos.inputOscuro, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppEstilos.bordeOscuro)),
      child: ExpansionTile(
        iconColor: AppEstilos.colorDorado,
        collapsedIconColor: AppEstilos.colorDorado,
        leading: Icon(Icons.menu_book, color: esPendiente ? AppEstilos.rojoChip : AppEstilos.verdeBoton),
        title: Row(
          children: [
            Text('${p.cabecera} ${p.numero}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(esPendiente ? '[PENDIENTE]' : '[EN COCINA]', style: TextStyle(color: esPendiente ? AppEstilos.rojoChip : AppEstilos.verdeBoton, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const Divider(color: Colors.white24),
                ...List.generate(itemsPlatos.length, (i) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(itemsPlatos[i].trim(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      Checkbox(
                        value: _checkstates[p.id]![i],
                        activeColor: AppEstilos.verdeBoton,
                        checkColor: Colors.black,
                        side: const BorderSide(color: Colors.white54),
                        onChanged: esPendiente ? null : (v) => setState(() => _checkstates[p.id]![i] = v!),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _cambiarEstado(p, esPendiente ? 'en_proceso' : 'listo'),
                    style: ElevatedButton.styleFrom(backgroundColor: esPendiente ? AppEstilos.verdeBoton : AppEstilos.colorDorado),
                    child: Text(
                      esPendiente ? 'Empezar Preparación' : 'Marcar como Listo',
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
