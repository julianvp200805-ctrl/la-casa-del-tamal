import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu_services.dart';

class MenuPage extends StatefulWidget {
  static const String routeName = '/menu';
  final String logoAssetPath;

  const MenuPage({super.key, this.logoAssetPath = 'assets/image/logo.png'});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final MenuService _menuService = MenuService();

  // Cuántas tarjetas se muestran al inicio y cuántas se agregan con "Ver mas"
  static const int _cantidadInicial = 3;
  static const int _cantidadPorPagina = 3;

  bool _cargando = true;
  String? _error;
  List<MenuItem> _platos = [];
  int _cantidadVisible = _cantidadInicial;

  @override
  void initState() {
    super.initState();
    _cargarMenu();
  }

  Future<void> _cargarMenu() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final platos = await _menuService.obtenerMenu();
      if (!mounted) return;
      setState(() => _platos = platos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _verMas() {
    setState(() {
      _cantidadVisible =
          (_cantidadVisible + _cantidadPorPagina).clamp(0, _platos.length);
    });
  }

  String _formatoMoneda(double valor) {
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
              _buildEncabezado(),
              Expanded(child: _buildContenido()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppEstilos.degradadoHeader,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: AppEstilos.sombraSuave,
          ),
          child: Row(
            children: [
              Image.asset(
                widget.logoAssetPath,
                height: 55,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.house, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Ícono flotante para volver / chatbot, igual al resto de pantallas
        Positioned(
          left: 12,
          bottom: 12,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 3,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppEstilos.headerFin),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarMenu,
                style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.colorDorado),
                child: const Text('Reintentar', style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      );
    }

    if (_platos.isEmpty) {
      return const Center(
        child: Text('Aún no hay platos en el menú', style: TextStyle(color: Colors.white70)),
      );
    }

    final platosVisibles = _platos.take(_cantidadVisible).toList();
    final quedanMas = _cantidadVisible < _platos.length;

    return RefreshIndicator(
      onRefresh: _cargarMenu,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        children: [
          for (final plato in platosVisibles) _buildTarjetaPlato(plato),
          if (quedanMas)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: Center(
                child: TextButton(
                  onPressed: _verMas,
                  child: const Text(
                    'VER MAS...',
                    style: TextStyle(
                      color: AppEstilos.headerFin,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTarjetaPlato(MenuItem plato) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(AppEstilos.radioTarjeta),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                ? Image.network(
                    plato.imagenUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _iconoImagenFallback(),
                  )
                : _iconoImagenFallback(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plato.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (plato.descripcion != null && plato.descripcion!.isNotEmpty)
                  Text(
                    plato.descripcion!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Precio: ${_formatoMoneda(plato.precio)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppEstilos.headerFin,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconoImagenFallback() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.black12,
      child: const Icon(Icons.restaurant, color: Colors.black38),
    );
  }
}