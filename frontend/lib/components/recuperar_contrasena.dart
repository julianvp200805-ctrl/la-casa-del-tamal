import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerent_services.dart';
import 'package:frontend/components/recuperar.dart';

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
  final TextEditingController _correoController = TextEditingController();

  final int cantidadDigitosCodigo = 6;

  late List<TextEditingController> _codigoControllers;
  late List<FocusNode> _codigoFocusNodes;

  final UserService _userService = UserService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _codigoControllers = List.generate(
      cantidadDigitosCodigo,
      (index) => TextEditingController(),
    );

    _codigoFocusNodes = List.generate(
      cantidadDigitosCodigo,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();

    for (final controller in _codigoControllers) {
      controller.dispose();
    }

    for (final node in _codigoFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  Future<void> _enviarCorreo() async {
    final email = _correoController.text.trim();

    if (email.isEmpty) {
      _mostrarMensaje(
        'Por favor ingresa tu email',
        esError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final msg = await _userService.enviarCodigoRecuperacion(email);
      _mostrarMensaje(msg);
    } catch (e) {
      _mostrarMensaje(
        e.toString(),
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _irANuevaContrasena() {
    final email = _correoController.text.trim();

    final codigo = _codigoControllers
        .map((controller) => controller.text)
        .join();

    if (email.isEmpty) {
      _mostrarMensaje(
        'Ingresa tu correo primero',
        esError: true,
      );
      return;
    }

    if (codigo.length < cantidadDigitosCodigo) {
      _mostrarMensaje(
        'Ingresa el código completo',
        esError: true,
      );
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

  void _mostrarMensaje(
    String texto, {
    bool esError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor:
            esError ? Colors.red.shade700 : Colors.green.shade700,
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
              const SizedBox(height: 14),
              Expanded(
                child: _buildTarjetaFormulario(),
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
      padding: const EdgeInsets.symmetric(
        vertical: 26,
        horizontal: 20,
      ),
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
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return const Icon(
                Icons.house,
                size: 60,
                color: Colors.white,
              );
            },
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaFormulario() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        8,
        0,
        8,
        12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF48A350),
            Color(0xFF2E5432),
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppEstilos.radioTarjeta,
        ),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'RECUPERAR CONTRASEÑA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'serif',
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'te enviaremos un codigo ingresalo para\n'
              'que puedas tener una contraseña nueva',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildCampoCorreo(),
            const SizedBox(height: 20),
            _buildBotonDorado(
              texto: 'Enviar',
              onPressed: _enviarCorreo,
            ),
            const SizedBox(height: 28),
            const Text(
              'Ingresar codigo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 18),
            _buildCasillasCodigo(),
            const SizedBox(height: 28),
            _buildBotonDorado(
              texto: 'Recuperar',
              onPressed: _irANuevaContrasena,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoCorreo() {
    return TextField(
      controller: _correoController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Ingrese su email',
        hintStyle: const TextStyle(
          color: Color(0xFF9C9C94),
        ),
        filled: true,
        fillColor: AppEstilos.colorInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBotonDorado({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppEstilos.colorDorado,
          disabledBackgroundColor: AppEstilos.colorDorado,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                texto,
                style: const TextStyle(
                  color: Colors.black87,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildCasillasCodigo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        cantidadDigitosCodigo,
        (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: SizedBox(
              width: 48,
              height: 55,
              child: TextField(
                controller: _codigoControllers[index],
                focusNode: _codigoFocusNodes[index],
                textAlign: TextAlign.center,
                textInputAction: index ==
                        cantidadDigitosCodigo - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFD0BD00),
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (valor) {
                  if (valor.isNotEmpty) {
                    if (index < cantidadDigitosCodigo - 1) {
                      _codigoFocusNodes[index + 1]
                          .requestFocus();
                    } else {
                      _codigoFocusNodes[index].unfocus();
                    }
                  } else if (index > 0) {
                    _codigoFocusNodes[index - 1]
                        .requestFocus();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
