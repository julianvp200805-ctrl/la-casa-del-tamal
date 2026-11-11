import 'dart:async';

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
  String _categoriaActiva = 'almuerzo';
  List<MenuItem> _platosBackend = [];
  bool _cargando = true;
  bool _sondeando = false;
  String? _errorMsg;
  String? _versionMenu;
  Timer? _sondeo;

  static const Duration _intervaloSondeo = Duration(seconds: 15);

  // Claves en minúscula para filtrar; la etiqueta visible va capitalizada.
  final List<String> _categorias = const [
    'desayuno',
    'almuerzo',
    'comida rapida',
    'bebidas'
  ];

  static const Map<String, String> _etiquetasCategorias = {
    'desayuno': 'Desayuno',
    'almuerzo': 'Almuerzo',
    'comida rapida': 'Comida rápida',
    'bebidas': 'Bebidas',
  };

  @override
  void initState() {
    super.initState();
    _obtenerDatosDeRender();
    _sondeo = Timer.periodic(_intervaloSondeo, (_) => _comprobarSiHayCambios());
  }

  @override
  void dispose() {
    _sondeo?.cancel();
    super.dispose();
  }

  Future<void> _obtenerDatosDeRender() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _errorMsg = null;
    });
    try {
      // La huella se toma antes de la lista: si el admin edita entre las dos
      // peticiones, el sondeo detecta el cambio (de lo contrario podría
      // quedar una versión nueva guardada como referencia sin verla en pantalla).
      final huellaInicial = await _menuService.obtenerVersion();
      // El cliente no ve los platos que el admin agotó; solo se piden los disponibles.
      final resultado = await _menuService.obtenerMenu(soloDisponibles: true);
      if (mounted) {
        setState(() {
          _platosBackend = resultado;
          _cargando = false;
        });
      }
      _versionMenu = huellaInicial;
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _cargando = false;
        });
      }
    }
  }

  /// Sondeo ligero: pide solo la huella del menú y recarga la lista si cambió.
  Future<void> _comprobarSiHayCambios() async {
    if (!mounted || _sondeando) return;
    _sondeando = true;
    try {
      final version = await _menuService.obtenerVersion();
      if (!mounted || version == null) return;
      if (_versionMenu == null) {
        _versionMenu = version;
        return;
      }
      if (version != _versionMenu) {
        _versionMenu = version;
        await _recargarEnSilencio();
      }
    } catch (_) {
      // Si falla el sondeo la lista visible sigue sirviendo.
    } finally {
      _sondeando = false;
    }
  }

  Future<void> _recargarEnSilencio() async {
    if (!mounted) return;
    try {
      final resultado = await _menuService.obtenerMenu(soloDisponibles: true);
      if (mounted) {
        setState(() {
          _platosBackend = resultado;
          _errorMsg = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    }
  }

  String _normalizar(String texto) => texto
      .toLowerCase()
      .trim()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');

  /// Los ingredientes los define el admin; si faltan, se deducen de la descripción.
  List<String> _ingredientesDe(MenuItem plato) {
    final delBackend = plato.ingredientes?.trim();
    if (delBackend != null && delBackend.isNotEmpty) {
      final lista = delBackend
          .split(RegExp(r'[,;\n]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((s) => s[0].toUpperCase() + s.substring(1))
          .toList();
      if (lista.isNotEmpty) return lista;
    }
    return _parsearIngredientes(plato.descripcion);
  }

  List<String> _parsearIngredientes(String? descripcion) {
    if (descripcion == null || descripcion.isEmpty) return ['Tradicional'];
    final descMinuscula = _normalizar(descripcion);
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
    final seleccion = _normalizar(_categoriaActiva);
    final filtrados = _platosBackend
        .where((p) => _normalizar(p.categoria ?? '') == seleccion)
        .toList();

    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: AppEstilos.verdeBoton),
                  SizedBox(width: 8),
                  Text(
                    'Bienvenido',
                    style: TextStyle(color: AppEstilos.verdeBoton, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'El sabor de casa',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'serif', fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  Text(
                    'En cada tamal.',
                    style: TextStyle(color: AppEstilos.verdeBoton, fontSize: 26, fontFamily: 'serif', fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ],
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
            errorBuilder: (_, _, _) => const Icon(Icons.restaurant, color: AppEstilos.verdeBoton, size: 32),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InicioSesion())),
            icon: const Icon(Icons.person_outline, color: AppEstilos.verdePildora, size: 18),
            label: const Text('Iniciar sesión', style: TextStyle(color: AppEstilos.verdePildora, fontSize: 13, fontWeight: FontWeight.w600)),
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
              label: Text(_etiquetasCategorias[c] ?? c),
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
      return AppErrorState(mensaje: _errorMsg!, onReintentar: _obtenerDatosDeRender);
    }
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _recargarEnSilencio,
        color: AppEstilos.verdeBoton,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            AppEmptyState(mensaje: 'No hay platos disponibles en esta categoría', icono: Icons.restaurant_menu_outlined),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _recargarEnSilencio,
      color: AppEstilos.verdeBoton,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final plato = items[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => ProductoDetallePage(plato: plato, ingredientes: _ingredientesDe(plato))));
              if (!mounted) return;
              await _comprobarSiHayCambios();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppEstilos.inputOscuro, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppEstilos.bordeOscuro)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                        ? Image.network(plato.imagenUrl!, width: 85, height: 85, fit: BoxFit.cover, errorBuilder: (_, _, _) => _fallbackImg())
                        : _fallbackImg(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plato.nombre, style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'serif', fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(plato.descripcion ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.35)),
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