import 'package:flutter/material.dart';
import 'package:frontend/components/inicio/inicio_sesion.dart';
import 'package:frontend/components/productos/producto_detalle_page.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MenuService _menuService = MenuService();
  String _categoriaActiva = 'Almuerzo';
  List<MenuItem> _platosBackend = [];
  bool _cargando = true;
  String? _errorMsg;

  final List<String> _categorias = const [
    'Desayuno',
    'Almuerzo',
    'Comida Rápida',
    'Bebidas'
  ];

  @override
  void initState() {
    super.initState();
    _obtenerDatosDeRender();
  }

  Future<void> _obtenerDatosDeRender() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _errorMsg = null;
    });
    try {
      final resultado = await _menuService.obtenerMenu();
      if (mounted) {
        setState(() {
          _platosBackend = resultado;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _cargando = false;
        });
      }
    }
  }

  List<String> _parsearIngredientes(String? descripcion) {
    if (descripcion == null || descripcion.isEmpty) return ['Tradicional'];
    final descMinuscula = descripcion.toLowerCase();
    final listaPalabrasClave = [
      'pollo', 'cerdo', 'tocino', 'arroz', 'arveja', 'huevo', 
      'papa', 'zanahoria', 'hogao', 'maiz', 'maduro', 'carnes'
    ];
    final encontrados = listaPalabrasClave
        .where((ing) => descMinuscula.contains(ing))
        .map((ing) => ing[0].toUpperCase() + ing.substring(1))
        .toList();
    return encontrados.isEmpty ? ['Tradicional'] : encontrados;
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _platosBackend.where((p) {
      final c = (p.categoria ?? '').toLowerCase().trim();
      return c == _categoriaActiva;
    }).toList();

    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'El sabor de casa\nen cada tamal.',
                style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'serif', fontWeight: FontWeight.bold, height: 1.2),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Elige lo que se te antoje y pide en segundos.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            _buildCategoriasBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildListaContenido(filtrados)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/image/logo.png',
            width: 120,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: AppEstilos.verdeBoton, size: 32),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InicioSesion())),
            icon: const Icon(Icons.person_outline, color: AppEstilos.verdePildora, size: 18),
            label: const Text('Iniciar sesion', style: TextStyle(color: AppEstilos.verdePildora, fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppEstilos.verdePildora, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasBar() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final c = _categorias[index];
          final esActivo = _categoriaActiva == c;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(c),
              selected: esActivo,
              onSelected: (_) => setState(() => _categoriaActiva = c),
              selectedColor: AppEstilos.verdeBoton,
              backgroundColor: AppEstilos.inputOscuro,
              showCheckmark: false,
              labelStyle: TextStyle(color: esActivo ? Colors.black87 : Colors.white70, fontWeight: esActivo ? FontWeight.bold : FontWeight.normal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: esActivo ? Colors.transparent : AppEstilos.bordeOscuro)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListaContenido(List<MenuItem> items) {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMsg', style: const TextStyle(color: Colors.white70)),
            TextButton(onPressed: _obtenerDatosDeRender, child: const Text('Reintentar', style: TextStyle(color: AppEstilos.verdeBoton))),
          ],
        ),
      );
    }
    if (items.isEmpty) return const Center(child: Text('No hay platos disponibles en esta categoría.', style: TextStyle(color: Colors.white38)));

    return RefreshIndicator(
      onRefresh: _obtenerDatosDeRender,
      color: AppEstilos.verdeBoton,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final plato = items[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductoDetallePage(plato: plato, ingredientes: _parsearIngredientes(plato.descripcion)))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppEstilos.inputOscuro, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppEstilos.bordeOscuro)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                        ? Image.network(plato.imagenUrl!, width: 85, height: 85, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallbackImg())
                        : _fallbackImg(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plato.nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(plato.descripcion ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fallbackImg() => Container(width: 85, height: 85, color: AppEstilos.bordeOscuro, child: const Icon(Icons.fastfood, color: Colors.white38));
}