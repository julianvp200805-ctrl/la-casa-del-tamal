import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_menu_card.dart';
import 'package:frontend/components/admin/admin_menu_from.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';


/// Modificar menu (solo admin): lista de platos, agregar, editar y eliminar.
class AdminMenuPage extends StatefulWidget {
  static const String routeName = '/admin-menu';
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final MenuService _menuService = MenuService();
  late Future<List<MenuItem>> _futuro = _menuService.obtenerMenu();

  void _recargar() => setState(() => _futuro = _menuService.obtenerMenu());

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700),
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

  Future<void> _eliminar(MenuItem plato) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar plato'),
        content: Text('¿Seguro que quieres eliminar "${plato.nombre}" del menú?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
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
      floatingActionButton: const ChatFab(),
      body: SafeArea(
        child: Column(
          children: [
            const AdminTopBar(),
            const VentaTituloRow(titulo: 'Modificar menu'),
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
                  return RefreshIndicator(
                    onRefresh: () async => _recargar(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
                      children: [
                        for (final p in snap.data!) AdminMenuCard(plato: p, onEditar: () => _abrirFormulario(plato: p), onEliminar: () => _eliminar(p)),
                        _botonAgregar(),
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

  Widget _botonAgregar() {
    return Material(
      color: AppEstilos.inputOscuro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppEstilos.bordeAgregar)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _abrirFormulario(),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppEstilos.verdeAccion, size: 20),
              SizedBox(width: 6),
              Text('Agregar producto', style: TextStyle(color: AppEstilos.verdeAccion, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}