import 'package:flutter/material.dart';
import 'package:frontend/components/ventas/venta_item_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/menu/menu_card.dart';
import 'package:frontend/pantallas/menu/menu_header.dart';
import 'package:frontend/services/menu/menu_services.dart';


/// Menú público: lo ve cualquier persona sin iniciar sesión (solo lectura).
/// Aquí no hay chatbot: ese asistente es solo para el personal.
class MenuPage extends StatefulWidget {
  static const String routeName = '/menu';
  final String logoAssetPath;

  const MenuPage({super.key, this.logoAssetPath = 'assets/image/logo.png'});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  static const int _cantidadInicial = 3;
  static const int _cantidadPorPagina = 3;

  final MenuService _menuService = MenuService();
  List<MenuItem> _platos = [];
  bool _cargando = true;
  String? _error;
  int _visibles = _cantidadInicial;

  @override
  void initState() {
    super.initState();
    _cargarMenu();
  }

  Future<void> _cargarMenu() async {
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

  void _verMas() => setState(() => _visibles = (_visibles + _cantidadPorPagina).clamp(0, _platos.length));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Column(
          children: [
            MenuHeader(logoAssetPath: widget.logoAssetPath),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
    if (_error != null) return AppErrorState(mensaje: _error!, onReintentar: _cargarMenu);
    if (_platos.isEmpty) return const AppEmptyState(mensaje: 'Aún no hay platos en el menú');

    final quedanMas = _visibles < _platos.length;
    return RefreshIndicator(
      onRefresh: _cargarMenu,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          for (final plato in _platos.take(_visibles)) MenuCard(plato: plato, precioFormateado: '\$${formatoMoneda(plato.precio)}'),
          if (quedanMas)
            Center(
              child: TextButton(
                onPressed: _verMas,
                child: const Text('VER MAS...', style: TextStyle(color: AppEstilos.verdeBoton, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
        ],
      ),
    );
  }
}