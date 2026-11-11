import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/mesero_shell.dart';
import 'package:frontend/components/mesero/mesero_top_bar.dart';
import 'package:frontend/components/mesero/nota_cocina_sheet.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/components/mesero/plato_pedido_card.dart';
import 'package:frontend/components/mesero/selector_mesa.dart';
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
  final Map<String, String> _notas = {};
  int? _mesa;
  int _categoria = 2;
  bool _cargando = true, _enviando = false;
  String? _error;
  Timer? _timer;
  String? _version;
  bool _ocupado = false;

  int get _totalItems => _cant.values.fold(0, (a, b) => a + b);
  double get _total => _platos.fold(0.0, (s, p) => s + p.precio * (_cant[p.id] ?? 0));
  String get _detalle => _platos.where((p) => (_cant[p.id] ?? 0) > 0).map((p) => p.nombre).join(', ');

  // Categoría en minúsculas y sin tildes para comparar con las pestañas.
  String _clave(MenuItem p) {
    var s = (p.categoria ?? '').toLowerCase();
    const a = 'áéíóú', b = 'aeiou';
    for (var i = 0; i < 5; i++) {
      s = s.replaceAll(a[i], b[i]);
    }
    return s;
  }

  String _etiqueta(MenuItem p) {
    const nombres = {'desayuno': 'Desayuno', 'almuerzo': 'Almuerzo', 'rapida': 'Rápida', 'bebida': 'Bebida'};
    final clave = _clave(p);
    for (final e in nombres.entries) {
      if (clave.contains(e.key)) return e.value;
    }
    final c = (p.categoria ?? '').trim();
    if (c.isEmpty) return 'Típico';
    return c[0].toUpperCase() + c.substring(1);
  }

  List<MenuItem> get _visibles {
    if (!_platos.any((p) => _claves.any(_clave(p).contains))) return _platos;
    return _platos.where((p) => _clave(p).contains(_claves[_categoria])).toList();
  }

  @override
  void initState() {
    super.initState();
    _cargar();
    // Si el admin edita el menú, la huella cambia y la lista se refresca sola.
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _sondearVersion());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sondearVersion() async {
    if (_ocupado || _enviando) return;
    final v = await _menuService.obtenerVersion();
    if (!mounted || v == null) return;
    if (_version != null && v != _version) await _cargar(silencioso: true);
    _version = v;
  }

  Future<void> _cargar({bool silencioso = false}) async {
    if (_ocupado) return;
    _ocupado = true;
    if (!silencioso) setState(() { _cargando = true; _error = null; });
    try {
      // Los platos agotados no se muestran: el mesero no puede tomarlos.
      final platos = await _menuService.obtenerMenu(soloDisponibles: true);
      if (!mounted) return;
      setState(() { _platos = platos; _error = null; });
    } catch (e) {
      if (mounted && !silencioso) setState(() => _error = e.toString());
    } finally {
      _ocupado = false;
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _cambiar(String id, int d) => setState(() {
        final n = ((_cant[id] ?? 0) + d).clamp(0, 99);
        if (n == 0) {
          _cant.remove(id);
          _notas.remove(id); // sin plato en la cuenta no tiene sentido dejar la nota
        } else {
          _cant[id] = n;
        }
      });

  Future<void> _editarNota(MenuItem plato) async {
    final nueva = await abrirNotaCocina(context, plato: plato, nota: _notas[plato.id] ?? '');
    if (nueva == null || !mounted) return;
    setState(() {
      if (nueva.isEmpty) {
        _notas.remove(plato.id);
      } else {
        _notas[plato.id] = nueva;
      }
    });
  }

  void _mensaje(String t, {bool esError = false, String? accion, VoidCallback? alAccionar}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        action: accion != null
            ? SnackBarAction(label: accion, textColor: Colors.white, onPressed: alAccionar ?? () {})
            : null,
      ));

  Future<void> _hacerPedido() async {
    if (_mesa == null) return _mensaje('Elige la mesa del pedido', esError: true);
    if (_totalItems == 0) return _mensaje('Agrega al menos un plato', esError: true);
    setState(() => _enviando = true);
    try {
      await _meseroService.crearPedido(mesa: '$_mesa', cantidades: _cant, notas: _notas);
      if (!mounted) return;
      _mensaje(
        'Pedido de la mesa $_mesa enviado a cocina',
        accion: 'Ver pedidos',
        alAccionar: () => pestanaMeseroActiva.value = 1,
      );
      setState(() {
        _cant.clear();
        _notas.clear();
      });
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
          bottom: false,
          child: Column(
            children: [
              const MeseroTopBar(),
              const TituloMesero(texto: 'Tomar pedido'),
              CategoriaTabs(
                seleccionada: _categoria,
                onChanged: (i) => setState(() => _categoria = i),
                colorActivo: AppEstilos.meseroOliva,
              ),
              SelectorMesa(mesa: _mesa, onChanged: (m) => setState(() => _mesa = m)),
              Expanded(child: _contenido()),
              ResumenPedido(
                mesa: _mesa,
                detalle: _detalle,
                total: _total,
                items: _totalItems,
                notas: _notas.keys.where(_cant.containsKey).length,
              ),
              BotonHacerPedido(cantidad: _totalItems, enviando: _enviando, onPressed: _hacerPedido),
            ],
          ),
        ),
      );

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.meseroOliva));
    if (_error != null) return AppErrorState(mensaje: _error!, onReintentar: _cargar);
    if (_platos.isEmpty) return const AppEmptyState(mensaje: 'El menú está vacío', icono: Icons.restaurant_menu);
    final v = _visibles;
    if (v.isEmpty) return const AppEmptyState(mensaje: 'No hay platos en esta categoría', icono: Icons.no_meals_outlined);
    return RefreshIndicator(
      color: AppEstilos.meseroOliva,
      onRefresh: _cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        children: [
          for (final p in v)
            PlatoPedidoCard(
              plato: p,
              etiqueta: _etiqueta(p),
              cantidad: _cant[p.id] ?? 0,
              nota: _notas[p.id] ?? '',
              onMas: () => _cambiar(p.id, 1),
              onMenos: () => _cambiar(p.id, -1),
              onEditar: () => _editarNota(p),
            ),
        ],
      ),
    );
  }
}