import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/components/productos/hoja_formulario.dart';
import 'package:frontend/services/menu/menu_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/colores.dart';

class AdminMenuForm extends StatefulWidget {
  final MenuItem? plato;
  final MenuService menuService;

  const AdminMenuForm({super.key, this.plato, required this.menuService});

  @override
  State<AdminMenuForm> createState() => _AdminMenuFormState();
}

class _AdminMenuFormState extends State<AdminMenuForm> {
  late final _nombre = TextEditingController(text: widget.plato?.nombre ?? '');
  late final _precio = TextEditingController(text: widget.plato != null ? widget.plato!.precio.toStringAsFixed(0) : '');
  late final _descripcion = TextEditingController(text: widget.plato?.descripcion ?? '');
  
  String _categoria = 'almuerzo';
  XFile? _foto;
  Uint8List? _vistaPrevia;
  bool _guardando = false;

  final List<String> _categoriasList = const [
    'desayuno',
    'almuerzo',
    'comida rapida',
    'bebidas'
  ];

  bool get _esEdicion => widget.plato != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion && widget.plato!.categoria != null && widget.plato!.categoria!.isNotEmpty) {
      final catLimpia = widget.plato!.categoria!.toLowerCase().trim();
      if (_categoriasList.contains(catLimpia)) {
        _categoria = catLimpia;
      }
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (mounted) setState(() { _foto = x; _vistaPrevia = bytes; });
    } catch (e) {
      if (mounted) _mensaje('No se pudo abrir la galería: $e', esError: true);
    }
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final digitos = _precio.text.replaceAll(RegExp(r'[^0-9]'), '');
    final precio = int.tryParse(digitos);
    if (nombre.isEmpty || precio == null) return _mensaje('El nombre y el precio son obligatorios', esError: true);
    if (!_esEdicion && _foto == null) return _mensaje('Sube una foto del plato', esError: true);

    setState(() => _guardando = true);
    try {
      final desc = _descripcion.text.trim();
      if (_esEdicion) {
        await widget.menuService.actualizarPlato(id: widget.plato!.id, nombre: nombre, descripcion: desc, precio: precio, categoria: _categoria, foto: _foto);
      } else {
        await widget.menuService.crearPlato(nombre: nombre, descripcion: desc, precio: precio, categoria: _categoria, foto: _foto!);
      }
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

  Widget _miniatura() {
    final actual = widget.plato?.imagenUrl;
    if (_vistaPrevia != null) return Image.memory(_vistaPrevia!, width: 44, height: 44, fit: BoxFit.cover);
    if (_esEdicion && actual != null && actual.isNotEmpty) return Image.network(actual, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.photo_camera_outlined, color: Colors.white));
    return const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 26);
  }

  @override
  Widget build(BuildContext context) {
    final conFoto = _foto != null;
    return HojaFormulario(
      titulo: _esEdicion ? 'Editar producto' : 'Agregar producto',
      child: Column(
        children: [
          CampoHoja(controller: _nombre, hint: 'nombre'),
          CampoHoja(controller: _precio, hint: 'precio', teclado: TextInputType.number),
          CampoHoja(controller: _descripcion, hint: 'descripción', lineas: 2),
          CajaHoja(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _categoria,
                isExpanded: true,
                isDense: true,
                dropdownColor: AppEstilos.inputOscuro,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                items: _categoriasList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: _guardando ? null : (v) => setState(() => _categoria = v!),
              ),
            ),
          ),
          CajaHoja(
            onTap: _guardando ? null : _elegirFoto,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(6), child: _miniatura()),
                const SizedBox(width: 12),
                Text(conFoto ? 'foto lista, toca para cambiar' : (_esEdicion ? 'cambiar foto' : 'subir foto'), style: const TextStyle(color: Colors.white, fontSize: 13)),
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
