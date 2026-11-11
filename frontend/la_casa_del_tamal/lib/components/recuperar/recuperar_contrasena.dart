import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/menu/campo_inicio.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

class RecuperarContrasenaPage extends StatefulWidget {
  const RecuperarContrasenaPage({super.key});

  @override
  State<RecuperarContrasenaPage> createState() => _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperarContrasenaPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _nuevaPassCtrl = TextEditingController();
  final _focusCodigo = FocusNode();

  bool _cargandoCodigo = false;
  bool _cargandoVerificacion = false;
  bool _codigoEnviadoExitosamente = false;

  @override
  void initState() {
    super.initState();
    _focusCodigo.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codigoCtrl.dispose();
    _nuevaPassCtrl.dispose();
    _focusCodigo.dispose();
    super.dispose();
  }

  // Paso 1: el backend envía un código de 6 dígitos al correo.
  Future<void> _solicitarCodigoBrevo() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return _msg('Ingresa tu correo electrónico', true);

    setState(() => _cargandoCodigo = true);
    try {
      await UserService().enviarCodigoRecuperacion(email);
      if (!mounted) return;
      setState(() => _codigoEnviadoExitosamente = true);
      _msg('Código enviado con éxito a tu correo', false);
    } catch (e) {
      if (mounted) _msg(e.toString(), true);
    } finally {
      if (mounted) setState(() => _cargandoCodigo = false);
    }
  }

  // Paso 2: valida los 6 dígitos y asienta la nueva contraseña.
  Future<void> _procesarRestablecimiento() async {
    final codigo = _codigoCtrl.text.trim();
    final pass = _nuevaPassCtrl.text;

    if (codigo.length < 6) return _msg('Ingresa el código de 6 dígitos', true);
    if (pass.length < 8) return _msg('La contraseña debe tener mínimo 8 caracteres', true);

    setState(() => _cargandoVerificacion = true);
    try {
      await UserService().confirmarRecuperacion(
        email: _emailCtrl.text.trim(),
        codigo: codigo,
        nuevaContrasena: pass,
      );
      if (!mounted) return;
      _msg('Contraseña restablecida correctamente', false);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _msg(e.toString(), true);
    } finally {
      if (mounted) setState(() => _cargandoVerificacion = false);
    }
  }

  void _msg(String txt, bool err) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(txt), backgroundColor: err ? Colors.red.shade700 : Colors.green.shade700, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                const Text('Recupera tu contraseña', style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'serif', fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Te enviaremos un código, ingrésalo para que puedas tener una contraseña nueva.', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 24),
                CampoInicio(controller: _emailCtrl, hint: 'Correo', icono: Icons.mail_outline, teclado: TextInputType.emailAddress),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _cargandoCodigo ? null : _solicitarCodigoBrevo,
                    style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.verdeBoton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _cargandoCodigo ? const CircularProgressIndicator(color: Colors.black) : const Text('Enviar código', style: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Ingresar código', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                _buildGrillaNumericaDeSeisDigitos(),
                const SizedBox(height: 20),
                const Text('Nueva contraseña', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                CampoInicio(controller: _nuevaPassCtrl, hint: 'Nueva contraseña', icono: Icons.lock_outline, esPassword: true),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: (_cargandoVerificacion || !_codigoEnviadoExitosamente) ? null : _procesarRestablecimiento,
                    style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.verdeBoton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _cargandoVerificacion ? const CircularProgressIndicator(color: Colors.black) : const Text('Verificar', style: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrillaNumericaDeSeisDigitos() {
    final len = _codigoCtrl.text.length;
    final str = _codigoCtrl.text.padRight(6, ' ');
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            final char = str[i].trim();
            final esCasillaEnfocada = _focusCodigo.hasFocus && (len == i || (len == 6 && i == 5));
            return Container(
              width: MediaQuery.of(context).size.width * 0.12,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppEstilos.inputOscuro,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: esCasillaEnfocada ? AppEstilos.verdeBoton : (char.isNotEmpty ? AppEstilos.verdeBoton.withValues(alpha: 0.5) : AppEstilos.bordeOscuro), width: esCasillaEnfocada ? 1.5 : 1),
              ),
              child: Text(char, style: const TextStyle(color: AppEstilos.colorDorado, fontSize: 16, fontWeight: FontWeight.bold)),
            );
          }),
        ),
        TextField(
          controller: _codigoCtrl,
          focusNode: _focusCodigo,
          maxLength: 6,
          enabled: _codigoEnviadoExitosamente,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.transparent),
          cursorColor: Colors.transparent,
          decoration: const InputDecoration(counterText: '', border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: true, fillColor: Colors.transparent),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
  