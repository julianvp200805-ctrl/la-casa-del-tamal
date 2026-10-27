import 'package:flutter/material.dart';
import 'package:frontend/components/productos/hoja_formulario.dart';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/components/productos/tipo_producto_dialog.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/productos/producto_service.dart';

/// Hoja para registrar un lote de producto. Devuelve true si se guardó.
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
  final _lote = TextEditingController();
  List<TipoProducto> _tipos = [];
  String? _tipoId;
  DateTime _ingreso = DateTime.now();
  bool _cargandoTipos = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarTipos();
  }

  @override
  void dispose() {
    _lote.dispose();
    super.dispose();
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

  Future<void> _elegirFecha() async {
    final f = await showDatePicker(context: context, initialDate: _ingreso, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (f != null) setState(() => _ingreso = f);
  }

  Future<void> _guardar() async {
    final tipo = _tipos.where((t) => t.id.toString() == _tipoId).firstOrNull;
    if (tipo == null || _lote.text.trim().isEmpty) {
      _mensaje('Elige el tipo y escribe el código de lote', esError: true);
      return;
    }
    setState(() => _guardando = true);
    try {
      final f = '${_ingreso.year}-${_ingreso.month.toString().padLeft(2, '0')}-${_ingreso.day.toString().padLeft(2, '0')}';
      await widget.service.crearProducto(idTipo: tipo.id, fechaIngreso: f, lote: _lote.text.trim());
      if (mounted) Navigator.pop(context, true);
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
          CajaHoja(
            onTap: _elegirFecha,
            child: Row(children: [
              const Icon(Icons.event, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Text('Ingreso: ${fechaCorta(_ingreso)}', style: const TextStyle(color: Colors.white, fontSize: 13)),
            ]),
          ),
          CampoHoja(controller: _lote, hint: 'Código de lote (ej: CT001)'),
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