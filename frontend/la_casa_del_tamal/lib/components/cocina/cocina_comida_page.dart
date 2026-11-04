import 'package:flutter/material.dart';
import 'package:frontend/components/cocina/cocina_top_bar.dart';
import 'package:frontend/components/mesero/pedido_controles.dart' show CategoriaTabs;
import 'package:frontend/components/productos/producto_detalle_page.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';


class CocinaComidaPage extends StatefulWidget {
  const CocinaComidaPage({super.key});

  @override
  State<CocinaComidaPage> createState() => _CocinaComidaPageState();
}

class _CocinaComidaPageState extends State<CocinaComidaPage> {
  final MenuService _menuService = MenuService();
  static const _claves = ['desayuno', 'almuerzo', 'rapida', 'bebida']; // orden de CategoriaTabs
  int _categoria = 1;
  List<MenuItem> _platos = [];
  bool _cargando = true;

  // Quita acentos para comparar "Comida Rápida" con 'rapida'.
  String _normaliza(String s) {
    s = s.toLowerCase();
    const a = 'áéíóú', b = 'aeiou';
    for (var i = 0; i < 5; i++) { s = s.replaceAll(a[i], b[i]); }
    return s;
  }

  List<MenuItem> get _visibles =>
      _platos.where((p) => _normaliza(p.categoria ?? '').contains(_claves[_categoria])).toList();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final res = await _menuService.obtenerMenu();
      if (mounted) setState(() => _platos = res);
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  List<String> _obtenerChips(String? desc) {
    if (desc == null || desc.isEmpty) return ['General'];
    final m = desc.toLowerCase();
    final k = ['pollo', 'cerdo', 'tocino', 'arroz', 'arveja', 'huevo', 'papa', 'zanahoria', 'maiz'];
    final f = k.where((i) => m.contains(i)).map((i) => i.toUpperCase() + i.substring(1)).toList();
    return f.isEmpty ? ['General'] : f;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CocinaTopBar(),
            const TituloCocina(texto: 'Comida'),
            CategoriaTabs(seleccionada: _categoria, onChanged: (i) => setState(() => _categoria = i)),
            Expanded(child: _buildLista(_visibles)),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(List<MenuItem> items) {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
    if (items.isEmpty) return const Center(child: Text('No hay registros en esta sección.', style: TextStyle(color: Colors.white38)));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: items.length,
      itemBuilder: (context, idx) => _tarjeta(items[idx]),
    );
  }

  // Banda superior con etiqueta y foto centrada; abajo nombre, ingredientes,
  // "ver platillo" y el botón redondo de flecha (maqueta 31).
  Widget _tarjeta(MenuItem p) {
    final hayImagen = p.imagenUrl != null && p.imagenUrl!.isNotEmpty;
    final tipo = (p.categoria ?? 'Típico');
    final etiqueta = tipo[0].toUpperCase() + tipo.substring(1);
    final verde = _normaliza(etiqueta).startsWith('t');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppEstilos.platoMesero, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            height: 96,
            color: const Color(0xFF2E4A3C),
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: verde ? const Color(0xFF4ADE60) : const Color(0xFFFFD60A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(etiqueta, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                  ),
                ),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: hayImagen
                        ? Image.network(p.imagenUrl!, width: 76, height: 76, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
                        : _fallback(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nombre, style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'serif')),
                      const SizedBox(height: 3),
                      Text(p.descripcion ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductoDetallePage(plato: p, ingredientes: _obtenerChips(p.descripcion), deCocina: true))),
                        child: const Text('ver platillo', style: TextStyle(color: AppEstilos.acentoCocina, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductoDetallePage(plato: p, ingredientes: _obtenerChips(p.descripcion), deCocina: true))),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(color: Color(0xFF495751), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_ios, size: 14, color: AppEstilos.acentoCocina),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(width: 76, height: 76, color: AppEstilos.bordeOscuro, child: const Icon(Icons.fastfood, color: Colors.white24));
}