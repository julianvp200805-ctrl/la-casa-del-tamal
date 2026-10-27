import 'package:flutter/material.dart';
import 'package:frontend/components/inicio/inicio_sesion.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

class NuevaContrasenaPage extends StatefulWidget {
  final String email, codigo, logoAssetPath;
  const NuevaContrasenaPage({super.key, required this.email, required this.codigo, this.logoAssetPath = 'assets/image/logo.png'});

  @override
  State<NuevaContrasenaPage> createState() => _NuevaContrasenaPageState();
}

class _NuevaContrasenaPageState extends State<NuevaContrasenaPage> {
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false, _ocultarNueva = true, _ocultarConfirmar = true;

  String get _clave => _nuevaController.text;
  bool get _tieneLargo => _clave.length >= 8;
  bool get _tieneMayuscula => RegExp(r'[A-Z]').hasMatch(_clave);
  bool get _tieneNumero => RegExp(r'\d').hasMatch(_clave);

  @override
  void dispose() {
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_tieneLargo && _tieneMayuscula && _tieneNumero)) return _msg('La contraseña no cumple los requisitos', err: true);
    if (_clave != _confirmarController.text) return _msg('Las contraseñas no coinciden', err: true);

    setState(() => _isLoading = true);
    try {
      final msg = await _userService.confirmarRecuperacion(email: widget.email, codigo: widget.codigo, nuevaContrasena: _clave);
      if (!mounted) return;
      _msg(msg);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const InicioSesion()), (r) => false);
    } catch (e) {
      _msg(e.toString(), err: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _msg(String txt, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt), backgroundColor: err ? Colors.red.shade700 : Colors.green.shade700));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(icon: const Icon(Icons.subdirectory_arrow_left, color: Colors.white), onPressed: () => Navigator.of(context).maybePop()),
                    const SizedBox(height: 40),
                    const Text('Nueva contraseña', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'serif', fontWeight: FontWeight.w500)),
                    const SizedBox(height: 24),
                    _input('Nueva contraseña', _nuevaController, _ocultarNueva, () => setState(() => _ocultarNueva = !_ocultarNueva), (v) => setState(() {})),
                    const SizedBox(height: 16),
                    _input('Confirmar contraseña', _confirmarController, _ocultarConfirmar, () => setState(() => _ocultarConfirmar = !_ocultarConfirmar)),
                    const SizedBox(height: 24),
                    _requisito('Mínimo 8 caracteres', _tieneLargo),
                    _requisito('Una mayúscula', _tieneMayuscula),
                    _requisito('Un número', _tieneNumero),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardar,
                  style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.verdeBoton, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                      : const Text('Guardar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController ctrl, bool obs, VoidCallback tap, [ValueChanged<String>? change]) {
    return TextField(
      controller: ctrl,
      obscureText: obs,
      onChanged: change,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppEstilos.inputOscuro,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(icon: Icon(obs ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 20), onPressed: tap),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppEstilos.verdeBoton, width: 1.2)),
      ),
    );
  }

  Widget _requisito(String txt, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 6),
      child: Row(
        children: [
          Icon(ok ? Icons.check : Icons.circle_outlined, size: 14, color: ok ? AppEstilos.verdeBoton : Colors.white38),
          const SizedBox(width: 8),
          Text(txt, style: TextStyle(color: ok ? Colors.white : Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}
