import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu_services.dart';

/// Pantalla "Modificar menu" - SOLO ADMIN
/// Permite crear, editar y eliminar platos. Todas las acciones van
/// contra rutas protegidas del backend (verificarToken + verificarAdmin).
class AdminMenuPage extends StatefulWidget {
  static const String routeName = '/admin-menu';

  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final MenuService _menuService = MenuService();

  bool _cargando = true;
  String? _error;
  List<MenuItem> _platos = [];

  @override
  void initState() {
    super.initState();
    _cargarMenu();
  }

  Future<void> _cargarMenu() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final platos = await _menuService.obtenerMenu();
      if (!mounted) return;
      setState(() => _platos = platos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  // Abre el formulario, tanto para crear (plato == null) como para editar
  Future<void> _abrirFormulario({MenuItem? plato}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioPlato(plato: plato, menuService: _menuService),
    );

    if (guardado == true) {
      _mensaje(plato == null ? 'Plato creado' : 'Plato actualizado');
      _cargarMenu();
    }
  }

  Future<void> _confirmarEliminar(MenuItem plato) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar plato'),
        content: Text('¿Seguro que quieres eliminar "${plato.nombre}" del menú?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final msg = await _menuService.eliminarPlato(plato.id);
      if (!mounted) return;
      _mensaje(msg);
      _cargarMenu();
    } catch (e) {
      if (!mounted) return;
      _mensaje(e.toString(), esError: true);
    }
  }

  String _formatoMoneda(double valor) {
    final texto = valor.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < texto.length; i++) {
      final posicionDesdeElFinal = texto.length - i;
      buffer.write(texto[i]);
      if (posicionDesdeElFinal > 1 && posicionDesdeElFinal % 3 == 1) {
        buffer.write('.');
      }
    }
    return '\$${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppFondo(
        child: SafeArea(
          child: Column(
            children: [
              const AppEncabezado(titulo: 'MODIFICAR MENU', mostrarLogo: false),
              Expanded(child: _buildContenido()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppEstilos.colorDorado,
        icon: const Icon(Icons.add, color: Colors.black87),
        label: const Text(
          'Agregar plato',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppEstilos.colorDorado,
                ),
                child: const Text('Reintentar',
                    style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      );
    }

    if (_platos.isEmpty) {
      return const Center(
        child: Text(
          'Aún no hay platos.\nUsa "Agregar plato" para crear el primero.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarMenu,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: _platos.length,
        itemBuilder: (context, index) => _buildTarjetaAdmin(_platos[index]),
      ),
    );
  }

  Widget _buildTarjetaAdmin(MenuItem plato) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppEstilos.radioTarjeta),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                ? Image.network(
                    plato.imagenUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagenFallback(),
                  )
                : _imagenFallback(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plato.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatoMoneda(plato.precio),
                  style: const TextStyle(
                    color: AppEstilos.headerFin,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (plato.categoria != null && plato.categoria!.isNotEmpty)
                  Text(
                    plato.categoria!,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppEstilos.botonVerde),
            onPressed: () => _abrirFormulario(plato: plato),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmarEliminar(plato),
          ),
        ],
      ),
    );
  }

  Widget _imagenFallback() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.black12,
      child: const Icon(Icons.restaurant, color: Colors.black38),
    );
  }
}

/// Formulario para crear o editar un plato.
class _FormularioPlato extends StatefulWidget {
  final MenuItem? plato;
  final MenuService menuService;

  const _FormularioPlato({this.plato, required this.menuService});

  @override
  State<_FormularioPlato> createState() => _FormularioPlatoState();
}

class _FormularioPlatoState extends State<_FormularioPlato> {
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  late final TextEditingController _imagenUrl;
  late final TextEditingController _categoria;
  late final TextEditingController _stock;

  bool _guardando = false;

  bool get _esEdicion => widget.plato != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plato;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _descripcion = TextEditingController(text: p?.descripcion ?? '');
    _precio = TextEditingController(
      text: p != null ? p.precio.toStringAsFixed(0) : '',
    );
    _imagenUrl = TextEditingController(text: p?.imagenUrl ?? '');
    _categoria = TextEditingController(text: p?.categoria ?? '');
    _stock = TextEditingController(text: p?.stock?.toString() ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _imagenUrl.dispose();
    _categoria.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final imagenUrl = _imagenUrl.text.trim();
    final precio = double.tryParse(_precio.text.trim());

    // El backend exige nombre, precio e imagen_url
    if (nombre.isEmpty || imagenUrl.isEmpty || precio == null) {
      _mensaje('Nombre, precio e imagen son obligatorios', esError: true);
      return;
    }

    setState(() => _guardando = true);
    try {
      if (_esEdicion) {
        await widget.menuService.actualizarPlato(
          id: widget.plato!.id,
          nombre: nombre,
          descripcion: _descripcion.text.trim(),
          precio: precio,
          imagenUrl: imagenUrl,
          categoria: _categoria.text.trim(),
          stock: int.tryParse(_stock.text.trim()),
        );
      } else {
        await widget.menuService.crearPlato(
          nombre: nombre,
          descripcion: _descripcion.text.trim(),
          precio: precio,
          imagenUrl: imagenUrl,
          categoria: _categoria.text.trim(),
          stock: int.tryParse(_stock.text.trim()),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _mensaje(e.toString(), esError: true);
      setState(() => _guardando = false);
    }
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sube el formulario cuando aparece el teclado
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _esEdicion ? 'Editar plato' : 'Nuevo plato',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  color: AppEstilos.headerFin,
                ),
              ),
              const SizedBox(height: 20),
              _campo(_nombre, 'Nombre del plato'),
              const SizedBox(height: 12),
              _campo(_descripcion, 'Descripción', lineas: 3),
              const SizedBox(height: 12),
              _campo(_precio, 'Precio (solo números)', numerico: true),
              const SizedBox(height: 12),
              _campo(_imagenUrl, 'URL de la imagen'),
              const SizedBox(height: 12),
              _campo(_categoria, 'Categoría (opcional)'),
              const SizedBox(height: 12),
              _campo(_stock, 'Stock (opcional)', numerico: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppEstilos.botonVerde,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _esEdicion ? 'Guardar cambios' : 'Crear plato',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
  Widget _campo(
    TextEditingController controller,
    String hint, {
    bool numerico = false,
    int lineas = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numerico ? TextInputType.number : TextInputType.text,
      maxLines: lineas,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}