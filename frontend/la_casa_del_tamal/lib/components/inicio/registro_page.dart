import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _emailCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _focusCodigo = FocusNode();

  // _fechaIso (yyyy-MM-dd) es lo que viaja al backend; _fechaCtrl muestra dd/mm/yyyy.
  String? _fechaIso;
  String _tipoDoc = 'C.C.';
  bool _cargando = false;
  bool _has8Char = false, _hasUpper = false, _hasNumber = false;

  // Rol impuesto por el código de registro (lo genera el admin).
  String? _rolDelCodigo;
  bool _verificandoCodigo = false;
  String? _errorCodigo;

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
    _emailCtrl.dispose();
    _fechaCtrl.dispose();
    _passCtrl.dispose();
    _codigoCtrl.dispose();
    _focusCodigo.dispose();
    super.dispose();
  }

  String _tituloRol(String rol) => rol == 'cocina' ? 'Cocina' : 'Mesero';

  // POST /auth/verificar-codigo-registro: confirma que el código existe,
  // no está vencido ni usado, y devuelve el rol asignado por el admin.
  Future<void> _verificarCodigo(String codigo) async {
    setState(() {
      _verificandoCodigo = true;
      _errorCodigo = null;
      _rolDelCodigo = null;
    });
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/verificar-codigo-registro'),
        headers: ApiConfig.headers,
        body: jsonEncode({'codigo': codigo}),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200 && data['valid'] == true) {
        setState(() {
          _rolDelCodigo = (data['rol_asignado'] ?? '').toString();
          _verificandoCodigo = false;
        });
      } else {
        setState(() {
          _errorCodigo = (data['error'] ?? 'El código no es válido').toString();
          _verificandoCodigo = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorCodigo = 'No se pudo verificar el código. Revisa tu conexión.';
        _verificandoCodigo = false;
      });
    }
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime(hoy.year - 20),
      firstDate: DateTime(1900),
      lastDate: hoy,
      helpText: 'Fecha de nacimiento',
    );
    if (seleccion == null) return;
    setState(() {
      _fechaIso = '${seleccion.year.toString().padLeft(4, '0')}-'
          '${seleccion.month.toString().padLeft(2, '0')}-'
          '${seleccion.day.toString().padLeft(2, '0')}';
      _fechaCtrl.text = '${seleccion.day.toString().padLeft(2, '0')}/'
          '${seleccion.month.toString().padLeft(2, '0')}/${seleccion.year}';
    });
  }

  Future<void> _registrarse() async {
    final codigo = _codigoCtrl.text.trim().toUpperCase();
    if (codigo.length != 11) return _msg('Código interno incompleto', true);
    if (_errorCodigo != null) return _msg(_errorCodigo!, true);
    if (_rolDelCodigo == null) return _msg('Verifica primero el código de registro', true);
    if (!_has8Char || !_hasUpper || !_hasNumber) {
      return _msg('La contraseña no cumple los requisitos', true);
    }
    if (_fechaIso == null) return _msg('Selecciona tu fecha de nacimiento', true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/registro');

      // Limpieza estricta de espacios y caracteres invisibles o de retroceso (\u0008)
      final emailLimpio = _emailCtrl.text
          .trim()
          .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

      // El rol NO se envía: lo impone el código en el backend.
      final bodyData = {
        'nombre': _nombreCtrl.text.trim(),
        'tipo_documento': _tipoDoc,
        'numero_documento': _docCtrl.text.trim(),
        'email': emailLimpio,
        'fecha_nacimiento': _fechaIso,
        'contrasena': _passCtrl.text,
        'codigo': codigo,
      };

      final res = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(bodyData),
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        _msg('Cuenta registrada con éxito', false);
        Navigator.pop(context);
      } else {
        String errorMessage = 'Error al registrar';
        try {
          final decoded = jsonDecode(res.body);
          errorMessage = decoded['error'] ?? decoded['message'] ?? res.body;
        } catch (_) {
          errorMessage = res.body;
        }
        throw Exception(errorMessage);
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
                  validator: (val) => val == null || val.isEmpty ? 'Ingrese su nombre' : null,
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
                            validator: (val) {
                              final t = (val ?? '').trim();
                              if (t.isEmpty) return 'Ingrese documento';
                              if (!RegExp(r'^[A-Za-z0-9]{5,20}$').hasMatch(t)) {
                                return 'Entre 5 y 20 letras o números';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _lbl('Correo'),
                CampoInicio(
                  controller: _emailCtrl,
                  hint: 'Correo electrónico',
                  icono: Icons.mail_outline,
                  validator: (val) {
                    final t = (val ?? '').trim();
                    if (t.isEmpty) return 'Ingrese el correo';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                      return 'Correo no válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _lbl('Fecha de nacimiento'),
                _buildCampoFecha(),
                const SizedBox(height: 12),
                _lbl('Rol'),
                _buildCampoRol(),
                const SizedBox(height: 12),
                _lbl('Contraseña'),
                CampoInicio(
                  controller: _passCtrl,
                  hint: 'Mínimo 8 caracteres',
                  icono: Icons.lock_outline,
                  esPassword: true,
                  validator: (val) => !_has8Char || !_hasUpper || !_hasNumber ? 'Contraseña inválida' : null,
                ),
                const SizedBox(height: 10),
                _buildRequisitos(),
                const SizedBox(height: 16),
                _lbl('Codigo interno'),
                _buildCodigoInternoCompleto(),
                _buildEstadoCodigo(),
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

  // Sin prefijo de icono: la maqueta muestra 'C.C.' solo y el campo es angosto
  // (2/5 del ancho), que con icono no da para el texto más la flecha.
  InputDecoration _dropDeco() => InputDecoration(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.07),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    initialValue: _tipoDoc,
    isDense: true,
    dropdownColor: AppEstilos.inputOscuro,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: _dropDeco(),
    items: ['C.C.', 'C.E.', 'T.I.', 'Pasaporte']
        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
        .toList(),
    onChanged: (v) => setState(() => _tipoDoc = v!),
  );

  Widget _buildCampoFecha() {
    return GestureDetector(
      onTap: _elegirFecha,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _fechaCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'dd/mm/aaaa',
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 15),
            prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppEstilos.verdeBoton),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppEstilos.verdeBoton, width: 1.5),
            ),
          ),
          validator: (_) => _fechaIso == null ? 'Selecciona tu fecha de nacimiento' : null,
        ),
      ),
    );
  }

  // El rol no se elige: lo impone el código interno verificado contra el backend.
  Widget _buildCampoRol() {
    final texto = _verificandoCodigo
        ? 'Verificando...'
        : (_rolDelCodigo == null ? 'Pendiente' : _tituloRol(_rolDelCodigo!));
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppEstilos.verdeBoton, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: _rolDelCodigo == null ? Colors.white54 : Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          const Icon(Icons.expand_more, color: AppEstilos.colorDorado, size: 22),
        ],
      ),
    );
  }

  Widget _buildRequisitos() {    Widget item(String txt, bool ok) => Padding(
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

  // Bajo las casillas: verificación en vivo del código y su rol asignado.
  Widget _buildEstadoCodigo() {
    if (_verificandoCodigo) {
      return const Padding(
        padding: EdgeInsets.only(top: 8, left: 4),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppEstilos.verdeBoton),
            ),
            SizedBox(width: 8),
            Text('Verificando código...', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      );
    }
    if (_errorCodigo != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, left: 4),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_errorCodigo!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ],
        ),
      );
    }
    if (_rolDelCodigo != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, left: 4),
        child: Row(
          children: [
            const Icon(Icons.verified_outlined, color: AppEstilos.verdeBoton, size: 15),
            const SizedBox(width: 8),
            Text(
              'Código válido · rol asignado: ${_tituloRol(_rolDelCodigo!)}',
              style: const TextStyle(color: AppEstilos.verdeBoton, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.only(top: 8, left: 4),
      child: Text(
        'Pídele el código al administrador. Vence en 15 minutos y sirve una sola vez.',
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }

  Widget _buildCodigoInternoCompleto() {
    final len = _codigoCtrl.text.length;
    final str = _codigoCtrl.text.padRight(11, ' ');
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MediaQuery.of(context).size.width > 600
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: List.generate(11, (i) {
            final char = str[i].trim(), esGuion = i == 3 || i == 8;
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
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            _Mayusculas(),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z2-9-]')),
          ],
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
              if (formateada.length == 3 || formateada.length == 8) {
                formateada += '-';
              }
              formateada += limpia[i];
            }
            if (formateada != val) {
              _codigoCtrl.value = TextEditingValue(
                text: formateada,
                selection: TextSelection.collapsed(offset: formateada.length),
              );
            }
            setState(() {});
            // Al completar TAM-XXXX-XX se verifica solo contra el backend.
            if (formateada.length == 11) {
              _verificarCodigo(formateada);
            } else if (_rolDelCodigo != null || _errorCodigo != null || _verificandoCodigo) {
              setState(() {
                _rolDelCodigo = null;
                _errorCodigo = null;
                _verificandoCodigo = false;
              });
            }
          },
        ),
      ],
    );
  }
}

class _Mayusculas extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}