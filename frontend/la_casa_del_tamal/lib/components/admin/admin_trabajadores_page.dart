import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

/// Pantalla del admin: lista de trabajadores registrados (con opción de
/// eliminar) y ranking del mes de los meseros que más mesas atendieron.
class AdminTrabajadoresPage extends StatefulWidget {
  static const String routeName = '/admin-trabajadores';
  const AdminTrabajadoresPage({super.key});

  @override
  State<AdminTrabajadoresPage> createState() => _AdminTrabajadoresPageState();
}

class _AdminTrabajadoresPageState extends State<AdminTrabajadoresPage> {
  final UserService _service = UserService();
  late Future<List<Trabajador>> _trabajadores = _service.obtenerTrabajadores();
  late Future<List<RankingMesero>> _ranking = _service.obtenerRankingMes();

  void _recargar() {
    setState(() {
      _trabajadores = _service.obtenerTrabajadores();
      _ranking = _service.obtenerRankingMes();
    });
  }

  Future<void> _eliminar(Trabajador t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppEstilos.tablaInventario,
        title: const Text('Eliminar trabajador', style: TextStyle(color: Colors.white)),
        content: Text('¿Seguro que quieres eliminar a "${t.nombre}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: AppEstilos.rojoVencido, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.eliminarTrabajador(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trabajador eliminado'), backgroundColor: Colors.green, duration: Duration(seconds: 3)));
      _recargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700, duration: const Duration(seconds: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      appBar: AppBar(
        backgroundColor: AppEstilos.fondoOscuro,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Trabajadores', style: TextStyle(color: Colors.white, fontFamily: 'serif', fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _recargar(),
        color: AppEstilos.verdeBoton,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ranking del mes — mesas atendidas', style: TextStyle(color: AppEstilos.verdeBoton, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
              const SizedBox(height: 8),
              FutureBuilder<List<RankingMesero>>(
                future: _ranking,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
                  }
                  if (snap.hasError || (snap.data ?? []).isEmpty) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Sin datos este mes', style: TextStyle(color: Colors.white54, fontSize: 13)));
                  }
                  return Column(
                    children: [
                      for (int i = 0; i < snap.data!.length; i++)
                        _rankingTile(i + 1, snap.data![i]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Trabajadores registrados', style: TextStyle(color: AppEstilos.verdeBoton, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
              const SizedBox(height: 8),
              FutureBuilder<List<Trabajador>>(
                future: _trabajadores,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator(color: AppEstilos.verdeBoton));
                  }
                  if (snap.hasError) {
                    return Text(snap.error.toString(), style: const TextStyle(color: Colors.red));
                  }
                  final lista = snap.data ?? [];
                  if (lista.isEmpty) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No hay trabajadores registrados', style: TextStyle(color: Colors.white54, fontSize: 13)));
                  }
                  return Column(
                    children: [for (final t in lista) _trabajadorTile(t)],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rankingTile(int pos, RankingMesero r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppEstilos.inputOscuro, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppEstilos.bordeOscuro)),
      child: Row(
        children: [
          Text('#$pos', style: const TextStyle(color: AppEstilos.verdeBoton, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(child: Text(r.nombre, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Text('${r.mesas} mesas', style: const TextStyle(color: AppEstilos.colorDorado, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _trabajadorTile(Trabajador t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppEstilos.inputOscuro, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppEstilos.bordeOscuro)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.nombre, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${t.rol} · ${t.email}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppEstilos.rojoVencido), onPressed: () => _eliminar(t)),
        ],
      ),
    );
  }
}