import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/menu/campo_inicio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/services/config/api_config.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _docCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _focusCodigo = FocusNode();

  String _tipoDoc = 'C.C.', _rol = 'Mesero';
  bool _cargando = false, _oculto = true;
  bool _has8Char = false, _hasUpper = false, _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_validarContrasena);
    _focusCodigo.addListener(() => setState(() {}));
  }

  void _validarContrasena() {
    final t = _passCtrl.text;
    setState(() {
      _has8Char = t.length >= 8;
      _hasUpper = t.contains(RegExp(r'[A-Z]'));
      _hasNumber = t.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _docCtrl.dispose();
    _correoCtrl.dispose();
    _fechaCtrl.dispose();
    _passCtrl.dispose();
    _codigoCtrl.dispose();
    _focusCodigo.dispose();
    super.dispose();
  }

  Future<void> _registrarse() async {
    final codigo = _codigoCtrl.text.trim().toUpperCase();
    if (codigo.length < 11) return _msg('Código interno incompleto', true);
    if (!_has8Char || !_hasUpper || !_hasNumber)
      return _msg('La contraseña no cumple los requisitos', true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/registro'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'nombre': _nombreCtrl.text.trim(),
          'tipo_documento': _tipoDoc,
          'numero_documento': _docCtrl.text.trim(),
          'correo': _correoCtrl.text.trim(),
          'fecha_nacimiento': _fechaCtrl.text.trim(),
          'rol': _rol.toLowerCase(),
          'contrasena': _passCtrl.text,
          'codigo_interno': codigo,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        _msg('Cuenta registrada con éxito', false);
        Navigator.pop(context);
      } else {
        throw Exception(jsonDecode(res.body)['error'] ?? 'Error al registrar');
      }
    } catch (e) {
      _msg(e.toString().replaceAll('Exception: ', ''), true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _msg(String txt, bool err) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(txt),
        backgroundColor: err ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
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
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Crea tu cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _lbl('Nombre completo'),
                CampoInicio(
                  controller: _nombreCtrl,
                  hint: 'Nombre y apellidos',
                  icono: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [_lbl('Tipo de documento'), _buildDropDoc()],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _lbl('Numero de documento'),
                          CampoInicio(
                            controller: _docCtrl,
                            hint: 'Número',
                            icono: Icons.badge_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _lbl('Correo'),
                CampoInicio(
                  controller: _correoCtrl,
                  hint: 'Correo electrónico',
                  icono: Icons.mail_outline,
                ),
                const SizedBox(height: 12),
                _lbl('Fecha de nacimiento'),
                CampoInicio(
                  controller: _fechaCtrl,
                  hint: 'dd/mm/aa',
                  icono: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 12),
                _lbl('Rol'),
                _buildDropRol(),
                const SizedBox(height: 12),
                _lbl('Contraseña'),
                _buildCampoContrasenaLocal(),
                const SizedBox(height: 10),
                _buildRequisitos(),
                const SizedBox(height: 16),
                _lbl('Codigo interno'),
                _buildCodigoInternoCompleto(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrarse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppEstilos.verdeBoton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Registrarme',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lbl(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 4, left: 4),
    child: Text(
      texto,
      style: const TextStyle(color: Colors.white70, fontSize: 13),
    ),
  );

  InputDecoration _dropDeco(IconData ico) => InputDecoration(
    prefixIcon: Icon(ico, color: AppEstilos.verdeBoton),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.07),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: AppEstilos.verdeBoton, width: 1.5),
    ),
  );

  Widget _buildDropDoc() => DropdownButtonFormField<String>(
    value: _tipoDoc,
    dropdownColor: AppEstilos.inputOscuro,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: _dropDeco(Icons.assignment_ind_outlined),
    items: [
      'C.C.',
      'C.E.',
      'P.P.',
    ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
    onChanged: (v) => setState(() => _tipoDoc = v!),
  );

  Widget _buildDropRol() => DropdownButtonFormField<String>(
    value: _rol,
    dropdownColor: AppEstilos.inputOscuro,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: _dropDeco(Icons.people_outline),
    items: [
      'Mesero',
      'Cocina',
    ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
    onChanged: (v) => setState(() => _rol = v!),
  );

  Widget _buildCampoContrasenaLocal() {
    return TextFormField(
      controller: _passCtrl,
      obscureText: _oculto,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Mínimo 8 caracteres',
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 15),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppEstilos.verdeBoton,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _oculto ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white54,
          ),
          onPressed: () => setState(() => _oculto = !_oculto),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppEstilos.verdeBoton,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRequisitos() {
    Widget item(String txt, bool ok) => Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 6),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            color: ok ? AppEstilos.verdeBoton : Colors.white38,
            size: 15,
          ),
          const SizedBox(width: 8),
          Text(
            txt,
            style: TextStyle(
              color: ok ? AppEstilos.verdeBoton : Colors.white54,
              fontSize: 13,
              fontWeight: ok ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
    return Column(
      children: [
        item('Mínimo 8 caracteres', _has8Char),
        item('Una mayúscula', _hasUpper),
        item('Un número', _hasNumber),
      ],
    );
  }

  Widget _buildCodigoInternoCompleto() {
    final len = _codigoCtrl.text.length;
    final str = _codigoCtrl.text.padRight(11, ' ');
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(11, (i) {
            final char = str[i].trim(), esGuion = i == 3 || i == 8;
            // Ilumina la casilla actual si el foco global está activo
            final esCasillaEnfocada =
                _focusCodigo.hasFocus && (len == i || (len == 11 && i == 10));
            return Container(
              width: MediaQuery.of(context).size.width * 0.072,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: esGuion ? Colors.transparent : AppEstilos.inputOscuro,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: esCasillaEnfocada && !esGuion
                      ? AppEstilos.verdeBoton
                      : (char.isNotEmpty && !esGuion
                            ? AppEstilos.verdeBoton.withOpacity(0.5)
                            : AppEstilos.bordeOscuro),
                  width: esCasillaEnfocada ? 1.5 : 1,
                ),
              ),
              child: Text(
                esGuion ? '-' : char,
                style: const TextStyle(
                  color: AppEstilos.colorDorado,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
        TextField(
          controller: _codigoCtrl,
          focusNode: _focusCodigo,
          maxLength: 11,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.transparent),
          cursorColor: Colors.transparent,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
          ),
          onChanged: (val) {
            String limpia = val.replaceAll('-', '');
            String formateada = '';
            for (int i = 0; i < limpia.length; i++) {
              if (formateada.length == 3 || formateada.length == 8)
                formateada += '-';
              formateada += limpia[i];
            }
            if (formateada != val) {
              _codigoCtrl.value = TextEditingValue(
                text: formateada,
                selection: TextSelection.collapsed(offset: formateada.length),
              );
            }
            setState(() {});
          },
        ),
      ],
    );
  }
}
