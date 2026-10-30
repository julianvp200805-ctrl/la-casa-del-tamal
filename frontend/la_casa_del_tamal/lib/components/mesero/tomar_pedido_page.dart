import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/mesero_top_bar.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/components/mesero/plato_pedido_card.dart';
import 'package:frontend/components/mesero/selector_mesa.dart';
import 'package:frontend/core/app_states.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';
import 'package:frontend/services/mesero/mesero.dart';

class TomarPedidoPage extends StatefulWidget {
  static const String routeName = '/tomar-pedido';
  const TomarPedidoPage({super.key});

  @override
  State<TomarPedidoPage> createState() => _TomarPedidoPageState();
}

class _TomarPedidoPageState extends State<TomarPedidoPage> {
  static const _claves = ['desayuno', 'almuerzo', 'rapida', 'bebida']; // orden de CategoriaTabs
  final MenuService _menuService = MenuService();
  final MeseroService _meseroService = MeseroService();
  List<MenuItem> _platos = [];
  final Map<String, int> _cant = {};
  int? _mesa;
  int _personas = 1; // solo visual: el backend no lo recibe
  int _categoria = 2;
  bool _cargando = true, _enviando = false;
  String? _error;

  int get _totalItems => _cant.values.fold(0, (a, b) => a + b);
  double get _total => _platos.fold(0.0, (s, p) => s + (p.precio as num).toDouble() * (_cant[p.id] ?? 0));
  String get _detalle => _platos.where((p) => (_cant[p.id] ?? 0) > 0).map((p) => p.nombre).join(', ');

  // Lee "categoria" o "tipo" sin romper si no existen.
  String _texto(MenuItem p) {
    var s = '';
    try { s = '${(p as dynamic).categoria ?? ''}'; } catch (_) {}
    if (s.isEmpty) { try { s = '${(p as dynamic).tipo ?? ''}'; } catch (_) {} }
    s = s.toLowerCase();
    const a = 'áéíóú', b = 'aeiou';
    for (var i = 0; i < 5; i++) { s = s.replaceAll(a[i], b[i]); }
    return s;
  }

  String _etiqueta(MenuItem p) {
    try {
      final t = '${(p as dynamic).tipo ?? ''}';
      if (t.isNotEmpty) return t[0].toUpperCase() + t.substring(1);
    } catch (_) {}
    return 'Típico';
  }

  List<MenuItem> get _visibles {
    if (!_platos.any((p) => _claves.any(_texto(p).contains))) return _platos;
    return _platos.where((p) => _texto(p).contains(_claves[_categoria])).toList();
  }

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

  void _cambiar(String id, int d) => setState(() {
        final n = ((_cant[id] ?? 0) + d).clamp(0, 99);
        n == 0 ? _cant.remove(id) : _cant[id] = n;
      });

  void _mensaje(String t, {bool esError = false}) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700));

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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppEstilos.fondoOscuro,
        body: SafeArea(
          child: Column(
            children: [
              const MeseroTopBar(),
              const TituloMesero(texto: 'Tomar pedido'),
              CategoriaTabs(seleccionada: _categoria, onChanged: (i) => setState(() => _categoria = i)),
              SelectorMesa(
                mesa: _mesa,
                onChanged: (m) => setState(() => _mesa = m),
                personas: _personas,
                onPersonas: (p) => setState(() => _personas = p),
              ),
              Expanded(child: _contenido()),
              ResumenPedido(mesa: _mesa, detalle: _detalle, total: _total),
              BotonHacerPedido(cantidad: _totalItems, enviando: _enviando, onPressed: _hacerPedido),
            ],
          ),
        ),
      );

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.meseroOliva));
    if (_error != null) return AppErrorState(mensaje: _error!, onReintentar: _cargar);
    if (_platos.isEmpty) return const AppEmptyState(mensaje: 'El menú está vacío');
    final v = _visibles;
    if (v.isEmpty) return const AppEmptyState(mensaje: 'No hay platos en esta categoría');
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      children: [
        for (final p in v)
          PlatoPedidoCard(
            plato: p,
            etiqueta: _etiqueta(p),
            cantidad: _cant[p.id] ?? 0,
            onMas: () => _cambiar(p.id, 1),
            onMenos: () => _cambiar(p.id, -1),
          ),
      ],
    );
  }
}