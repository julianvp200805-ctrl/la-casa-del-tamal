import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerent_services.dart';
import 'package:frontend/components/inicio_sesion.dart';

class NuevaContrasenaPage extends StatefulWidget {
  static const String routeName = '/nueva-contrasena';
  final String logoAssetPath;
  final String email;
  final String codigo;

  const NuevaContrasenaPage({
    super.key,
    this.logoAssetPath = 'assets/image/logo.png',
    required this.email,
    required this.codigo,
  });

  @override
  State<NuevaContrasenaPage> createState() => _NuevaContrasenaPageState();
}

class _NuevaContrasenaPageState extends State<NuevaContrasenaPage> {
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();

  final UserService _userService = UserService();
  bool _isLoading = false;

  Future<void> _recuperar() async {
    if (_nuevaController.text.isEmpty || _confirmarController.text.isEmpty) {
      _mensaje('Completa ambos campos', esError: true);
      return;
    }
    if (_nuevaController.text != _confirmarController.text) {
      _mensaje('Las contraseñas no coinciden', esError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final msg = await _userService.confirmarRecuperacion(
        email: widget.email,
        codigo: widget.codigo,
        nuevaContrasena: _nuevaController.text,
      );
      if (!mounted) return;
      _mensaje(msg);
      // Contraseña cambiada -> devolvemos al usuario al login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const InicioSesion()),
        (route) => false,
      );
    } catch (e) {
      _mensaje(e.toString(), esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      body: AppFondo(
        child: SafeArea(
          child: Column(
            children: [
              _buildEncabezado(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      const Text(
                        'RECUPERAR CONTRASEÑA',
                        style: TextStyle(
                          color: Color(0xFF107E24),
                          fontSize: 16,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _campo(_nuevaController, 'Nueva contraseña'),
                      const SizedBox(height: 16),
                      _campo(_confirmarController, 'Confirmar contraseña'),
                      const SizedBox(height: 28),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppEstilos.sombraSuave,
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _recuperar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppEstilos.botonVerde,
                            minimumSize: const Size(140, 44),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Recuperar',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppEstilos.degradadoHeader,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            widget.logoAssetPath,
            height: 90,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.house, size: 60, color: Colors.white),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: const Icon(Icons.logout, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9C9C94)),
        filled: true,
        fillColor: AppEstilos.colorInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}