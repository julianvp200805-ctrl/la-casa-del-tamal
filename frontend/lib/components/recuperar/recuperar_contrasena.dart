import 'package:flutter/material.dart';
import 'package:frontend/components/recuperar/boton_verde.dart';
import 'package:frontend/components/recuperar/encabezado_recuperar.dart';
import 'package:frontend/components/recuperar/otp_input.dart';
import 'package:frontend/components/recuperar/recuperar.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/principal/campo_correo.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

class RecuperarContrasenaPage extends StatefulWidget {
  static const String routeName = '/recuperar-contrasena';
  final String logoAssetPath;

  const RecuperarContrasenaPage({
    super.key,
    this.logoAssetPath = 'assets/image/logo.png',
  });

  @override
  State<RecuperarContrasenaPage> createState() =>
      _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperarContrasenaPage> {
  final _correoController = TextEditingController();
  static const _cantidadDigitos = 6;
  late final _codigoControllers = List.generate(
    _cantidadDigitos,
    (_) => TextEditingController(),
  );
  late final _codigoFocusNodes = List.generate(
    _cantidadDigitos,
    (_) => FocusNode(),
  );
  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _correoController.dispose();
    for (final c in _codigoControllers) {
      c.dispose();
    }
    for (final f in _codigoFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _enviarCorreo() async {
    final email = _correoController.text.trim();
    if (email.isEmpty) {
      _mensaje('Por favor ingresa tu email', esError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      _mensaje(await _userService.enviarCodigoRecuperacion(email));
    } catch (e) {
      _mensaje(e.toString(), esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _irANuevaContrasena() {
    final email = _correoController.text.trim();
    final codigo = _codigoControllers.map((c) => c.text).join();

    if (email.isEmpty) {
      _mensaje('Ingresa tu correo primero', esError: true);
      return;
    }
    if (codigo.length < _cantidadDigitos) {
      _mensaje('Ingresa el código completo', esError: true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NuevaContrasenaPage(
          email: email,
          codigo: codigo,
          logoAssetPath: widget.logoAssetPath,
        ),
      ),
    );
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
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EncabezadoRecuperar(),
              const SizedBox(height: 24),
              CampoCorreo(controller: _correoController),
              const SizedBox(height: 16),
              BotonVerde.compacto(
                texto: 'Enviar codigo',
                onPressed: _enviarCorreo,
                cargando: _isLoading,
              ),
              const SizedBox(height: 28),
              const Text(
                'Ingresar codigo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              OtpInput(
                controllers: _codigoControllers,
                focusNodes: _codigoFocusNodes,
                oscuro: true,
              ),
              const SizedBox(height: 28),
              BotonVerde.compacto(
                texto: 'Verificar',
                onPressed: _irANuevaContrasena,
                cargando: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}