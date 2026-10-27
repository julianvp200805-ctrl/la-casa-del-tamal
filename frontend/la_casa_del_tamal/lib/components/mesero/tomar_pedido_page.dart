import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/mesero_top_bar.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/components/mesero/plato_pedido_card.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';
import 'package:frontend/services/mesero/mesero.dart';


/// Tomar pedido: se elige la mesa, se suben o bajan las cantidades de cada
/// plato del menú (de a 3 por página) y se envía a cocina.
class TomarPedidoPage extends StatefulWidget {
  static const String routeName = '/tomar-pedido';
  const TomarPedidoPage({super.key});

  @override
  State<TomarPedidoPage> createState() => _TomarPedidoPageState();
}

class _TomarPedidoPageState extends State<TomarPedidoPage> {
  static const _porPagina = 3;
  final MenuService _menuService = MenuService();
  final MeseroService _meseroService = MeseroService();
  List<MenuItem> _platos = [];
  final Map<String, int> _cant = {}; // id del plato -> cantidad
  int? _mesa;
  int _pagina = 0;
  bool _cargando = true;
  bool _enviando = false;
  String? _error;

  int get _totalItems => _cant.values.fold(0, (a, b) => a + b);
  int get _paginas => (_platos.length / _porPagina).ceil();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final platos = await _menuService.obtenerMenu();
      if (!mounted) return;
      setState(() => _platos = platos);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _cambiar(String id, int delta) => setState(() {
        final n = ((_cant[id] ?? 0) + delta).clamp(0, 99);
        n == 0 ? _cant.remove(id) : _cant[id] = n;
      });

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700),
    );
  }

  Future<void> _hacerPedido() async {
    if (_mesa == null) return _mensaje('Elige la mesa del pedido', esError: true);
    if (_totalItems == 0) return _mensaje('Agrega al menos un plato', esError: true);
    setState(() => _enviando = true);
    try {
      await _meseroService.crearPedido(mesa: '$_mesa', cantidades: _cant);
      if (!mounted) return;
      _mensaje('Pedido de la mesa $_mesa enviado a cocina');
      setState(_cant.clear);
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Column(
          children: [
            const MeseroTopBar(),
            const VentaTituloRow(titulo: 'Tomar pedido'),
            SelectorMesa(mesa: _mesa, onChanged: (m) => setState(() => _mesa = m)),
            Expanded(child: _contenido()),
            BotonHacerPedido(cantidad: _totalItems, enviando: _enviando, onPressed: _hacerPedido),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.meseroOliva));
    if (_error != null) return AppErrorState(mensaje: _error!, onReintentar: _cargar);
    if (_platos.isEmpty) return const AppEmptyState(mensaje: 'El menú está vacío');
    final visibles = _platos.skip(_pagina * _porPagina).take(_porPagina);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      children: [
        for (final p in visibles)
          PlatoPedidoCard(plato: p, cantidad: _cant[p.id] ?? 0, onMas: () => _cambiar(p.id, 1), onMenos: () => _cambiar(p.id, -1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_pagina > 0) IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18), onPressed: () => setState(() => _pagina--)),
            Text('Pag ${_pagina + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'serif')),
            if (_pagina + 1 < _paginas) IconButton(icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18), onPressed: () => setState(() => _pagina++)),
          ],
        ),
      ],
    );
  }
}