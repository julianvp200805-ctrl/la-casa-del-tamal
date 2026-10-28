import 'package:flutter/material.dart';
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
  String _categoriaActiva = 'almuerzo';
  List<MenuItem> _platos = [];
  bool _cargando = true;

  final List<String> _categorias = const ['desayuno', 'almuerzo', 'comida rapida', 'bebidas'];

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
    final filtrados = _platos.where((p) => (p.categoria ?? '').toLowerCase().trim() == _categoriaActiva).toList();

    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Text('Comida', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                ],
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categorias.length,
                itemBuilder: (context, idx) {
                  final cat = _categorias[idx];
                  final esActivo = _categoriaActiva == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: esActivo,
                      onSelected: (_) => setState(() => _categoriaActiva = cat),
                      selectedColor: AppEstilos.verdeBoton,
                      backgroundColor: AppEstilos.inputOscuro,
                      showCheckmark: false,
                      labelStyle: TextStyle(color: esActivo ? Colors.black87 : Colors.white70, fontWeight: esActivo ? FontWeight.bold : FontWeight.normal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: esActivo ? Colors.transparent : AppEstilos.bordeOscuro)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildLista(filtrados)),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(List<MenuItem> items) {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
    if (items.isEmpty) return const Center(child: Text('No hay registros en esta sección.', style: TextStyle(color: Colors.white38)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final p = items[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppEstilos.inputOscuro, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppEstilos.bordeOscuro)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                    ? Image.network(p.imagenUrl!, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
                    : _fallback(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(p.descripcion ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductoDetallePage(plato: p, ingredientes: _obtenerChips(p.descripcion)))),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('ver platillo >', style: TextStyle(color: Colors.white38, fontSize: 13, decoration: TextDecoration.underline)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fallback() => Container(width: 80, height: 80, color: AppEstilos.bordeOscuro, child: const Icon(Icons.fastfood, color: Colors.white24));
}