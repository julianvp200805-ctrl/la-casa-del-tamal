import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_menu_card.dart';
import 'package:frontend/components/admin/admin_menu_from.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';


/// Modificar menú (solo admin): lista de platos, agregar, editar y eliminar.
class AdminMenuPage extends StatefulWidget {
  static const String routeName = '/admin-menu';
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final MenuService _menuService = MenuService();
  final TextEditingController _busqueda = TextEditingController();
  late Future<List<MenuItem>> _futuro = _menuService.obtenerMenu();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(() => setState(() => _query = _busqueda.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _recargar() {
    // setState exige un callback void: con la flecha (=>) la asignación
    // devolvía el Future y disparaba el warning de setState.
    setState(() {
      _futuro = _menuService.obtenerMenu();
    });
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700, duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _abrirFormulario({MenuItem? plato}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminMenuForm(plato: plato, menuService: _menuService),
    );
    if (guardado == true) {
      _mensaje(plato == null ? 'Plato creado' : 'Plato actualizado');
      _recargar();
    }
  }

  Future<void> _toggleDisponibilidad(MenuItem plato) async {
    final agotando = plato.disponible;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppEstilos.tablaInventario,
        // Textos claros: el fondo es oscuro y con el color por defecto del
        // tema claro las letras quedaban casi invisibles.
        title: Text(
          agotando ? 'Descontinuar plato' : 'Habilitar plato',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          agotando
              ? '¿Desea descontinuar "${plato.nombre}"? Deja de verse en la carta y el mesero no puede tomarlo.'
              : '¿Desea volver a habilitar "${plato.nombre}"? Vuelve a la carta y a los pedidos.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              agotando ? 'Descontinuar' : 'Habilitar',
              style: TextStyle(color: agotando ? AppEstilos.rojoVencido : AppEstilos.verdeAccion, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final msg = await _menuService.marcarDisponibilidad(plato.id, !plato.disponible);
      if (!mounted) return;
      _mensaje(msg);
      _recargar();
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    }
  }

  Future<void> _eliminar(MenuItem plato) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppEstilos.tablaInventario,
        // Textos claros: el fondo es oscuro y con el tema claro las letras
        // quedaban casi invisibles.
        title: const Text('Eliminar plato', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Seguro que quieres eliminar permanentemente "${plato.nombre}" del menú? Si ya tiene pedidos registrados, también se borrarán esas líneas de pedido.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppEstilos.rojoVencido, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final msg = await _menuService.eliminarPlato(plato.id);
      if (!mounted) return;
      _mensaje(msg);
      _recargar();
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_agregar_producto',
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppEstilos.verdeAccion,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add),
        label: const Text('Agregar producto', style: TextStyle(fontFamily: 'serif', fontSize: 14)),
      ),
      // El shell del admin pone su FAB de Tamalín en esta esquina; el botón
      // sube para que queden apilados en lugar de encimados.
      floatingActionButtonLocation: const _FlotanteSobreElChat(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AdminTopBar(),
            const VentaTituloRow(titulo: 'Modificar menú'),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: TextField(
                controller: _busqueda,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar plato...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: AppEstilos.verdeBoton),
                  filled: true,
                  fillColor: AppEstilos.inputOscuro,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppEstilos.bordeOscuro)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppEstilos.bordeOscuro)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppEstilos.verdeBoton, width: 1.5)),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<MenuItem>>(
                future: _futuro,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
                  }
                  if (snap.hasError) {
                    return AppErrorState(mensaje: snap.error.toString().replaceAll('Exception: ', ''), onReintentar: _recargar);
                  }
                  final todos = snap.data!;
                  final filtrados = _query.isEmpty
                      ? todos
                      : todos.where((p) => p.nombre.toLowerCase().contains(_query)).toList();
                  if (filtrados.isEmpty) {
                    return const AppEmptyState(mensaje: 'No hay platos que coincidan', icono: Icons.search_off);
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _recargar(),
                    child: ListView(
                      // Holgado abajo para que el último plato quede libre de
                      // los dos FAB apilados (Agregar producto + Tamalín).
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 168),
                      children: [
                        for (final p in filtrados)
                          AdminMenuCard(
                            plato: p,
                            onEditar: () => _abrirFormulario(plato: p),
                            onEliminar: () => _eliminar(p),
                            onToggleDisponibilidad: () => _toggleDisponibilidad(p),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ubicación de FAB que deja espacio para el botón de Tamalín del shell.
class _FlotanteSobreElChat extends FloatingActionButtonLocation {
  const _FlotanteSobreElChat();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometria) =>
      FloatingActionButtonLocation.endFloat.getOffset(geometria) - const Offset(0, 74);

  @override
  String toString() => 'FlotanteSobreElChat';
}