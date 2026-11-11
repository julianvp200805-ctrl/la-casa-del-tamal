import 'package:flutter/material.dart';
import 'package:frontend/components/productos/hoja_formulario.dart';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/components/productos/tipo_producto_dialog.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/productos/producto_service.dart';

/// Hoja para registrar un lote de producto. La fecha de ingreso se fija al
/// día en que se registra (hoy) y el código de lote lo asigna el backend
/// (LT001, LT002... según el tipo). Devuelve true si se guardó.
Future<bool?> mostrarFormProducto(BuildContext context, ProductoService service) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FormProducto(service: service),
  );
}

class _FormProducto extends StatefulWidget {
  final ProductoService service;
  const _FormProducto({required this.service});

  @override
  State<_FormProducto> createState() => _FormProductoState();
}

class _FormProductoState extends State<_FormProducto> {
  static const _nuevo = '__nuevo__';
  List<TipoProducto> _tipos = [];
  String? _tipoId;
  bool _cargandoTipos = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarTipos();
  }

  Future<void> _cargarTipos() async {
    try {
      final tipos = await widget.service.obtenerTipos();
      if (!mounted) return;
      setState(() => _tipos = tipos);
    } catch (e) {
      if (mounted) _mensaje(e.toString(), esError: true);
    } finally {
      if (mounted) setState(() => _cargandoTipos = false);
    }
  }

  Future<void> _elegirTipo(String? valor) async {
    if (valor != _nuevo) return setState(() => _tipoId = valor);
    final creado = await pedirNuevoTipo(context, widget.service);
    if (creado == null || !mounted) return;
    setState(() {
      _tipos = [..._tipos, creado];
      _tipoId = creado.id.toString();
    });
  }

  TipoProducto? get _tipo => _tipos.where((t) => t.id.toString() == _tipoId).firstOrNull;

  Future<void> _guardar() async {
    final tipo = _tipo;
    if (tipo == null) {
      _mensaje('Elige el tipo de producto', esError: true);
      return;
    }
    setState(() => _guardando = true);
    try {
      final aviso = await widget.service.crearProducto(idTipo: tipo.id);
      if (!mounted) return;
      // El aviso llega del backend: "Lote LT002 de carne: vence el ..."
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(aviso), backgroundColor: Colors.green.shade700),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _mensaje(e.toString(), esError: true);
      setState(() => _guardando = false);
    }
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final tipo = _tipo;
    final vence = tipo == null ? null : DateTime(hoy.year, hoy.month, hoy.day).add(Duration(days: tipo.dias));
    return HojaFormulario(
      titulo: 'Agregar producto',
      child: Column(
        children: [
          CajaHoja(
            child: _cargandoTipos
                ? const SizedBox(height: 18, child: LinearProgressIndicator(color: AppEstilos.verdeBoton))
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _tipoId,
                      isExpanded: true,
                      isDense: true,
                      hint: const Text('Tipo de producto', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      dropdownColor: AppEstilos.inputOscuro,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: [
                        for (final t in _tipos) DropdownMenuItem(value: t.id.toString(), child: Text('${t.nombre} (${t.dias} días)')),
                        const DropdownMenuItem(value: _nuevo, child: Text('+ Nuevo tipo...', style: TextStyle(color: AppEstilos.verdeBoton))),
                      ],
                      onChanged: _elegirTipo,
                    ),
                  ),
          ),
          // La fecha de ingreso se fija al día en que se registra el lote y el
          // código de lote lo asigna el backend, así que aquí solo se informa
          // cómo va a quedar el registro antes de guardarlo.
          CajaHoja(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.event_available, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Text('Ingreso: hoy ${fechaCorta(hoy)}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.schedule, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      vence == null ? 'Vence: elige un tipo' : 'Vence: ${fechaCorta(vence)} (${tipo!.dias} días)',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.tag, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Lote: se asigna automáticamente', style: const TextStyle(color: Colors.white, fontSize: 13))),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.verdeAccion, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              child: _guardando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                  : const Text('Guardar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
