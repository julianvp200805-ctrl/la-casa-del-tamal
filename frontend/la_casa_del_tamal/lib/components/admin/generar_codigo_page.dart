import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/components/admin/admin_shell.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

class GenerarCodigoPage extends StatefulWidget {
  const GenerarCodigoPage({super.key});

  @override
  State<GenerarCodigoPage> createState() => _GenerarCodigoPageState();
}

class _GenerarCodigoPageState extends State<GenerarCodigoPage> {
  String _rolSeleccionado = 'mesero'; 
  String _codigoGenerado = '';
  bool _cargando = false;

  Future<void> _peticionGenerarCodigo() async {
    setState(() => _cargando = true);
    try {
      final data = await ApiClient.I.postJson(
        '/auth/generar-codigo',
        {'rol': _rolSeleccionado},
        conToken: true,
        defecto: 'Error al procesar la solicitud',
      );
      if (!mounted) return;
      setState(() => _codigoGenerado = data['codigo'] ?? '');
      _notificar('Código generado con éxito', esError: false);
    } catch (e) {
      if (mounted) _notificar(e.toString(), esError: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _notificar(String texto, {required bool esError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _copiarAlPortapapeles() {
    if (_codigoGenerado.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _codigoGenerado));
    _notificar('Código copiado al portapapeles', esError: false);
  }

  Future<void> _cerrarSesion() async {
    await UserService().cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: const ChatFab(),
      // La maqueta 14 muestra la barra del admin sin ninguna pestana activa:
      // esta pantalla es hija del shell y al tocar una pestana se regresa al shell.
      bottomNavigationBar: BarraNavegacion(
        indiceActivo: -1,
        onTap: (i) {
          pestanaAdminActiva.value = i;
          Navigator.pop(context);
        },
        pestanas: pestanasAdmin,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.subdirectory_arrow_left, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // Cierre de sesión disponible desde la pantalla de generar
                      // código, igual que desde el perfil del admin.
                      IconButton(
                        icon: const Icon(Icons.logout_outlined, color: AppEstilos.rojoVencido),
                        onPressed: _cerrarSesion,
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.account_circle, color: AppEstilos.verdeBoton, size: 30),
                      Text('ADMIN', style: TextStyle(color: AppEstilos.verdeBoton, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text('Código de acceso', style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'serif', fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Genera un código para que el nuevo usuario se registre con el rol que elijas.', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 24),
              const Text('Rol del nuevo usuario', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSelectorRol('mesero', 'Mesero', 'Pedidos y mesas')),
                  const SizedBox(width: 14),
                  Expanded(child: _buildSelectorRol('cocina', 'Cocina', 'Preparación')),
                ],
              ),
              const SizedBox(height: 24),
              const Text('El código vence en: 15 minutos', style: TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'serif')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _peticionGenerarCodigo,
                  style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.verdeBoton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _cargando 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Generar código', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                ),
              ),
              const SizedBox(height: 24),
              if (_codigoGenerado.isNotEmpty) _buildCardCodigo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorRol(String id, String titulo, String sub) {
    final activo = _rolSeleccionado == id;
    return GestureDetector(
      onTap: () => setState(() => _rolSeleccionado = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppEstilos.inputOscuro,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: activo ? AppEstilos.verdeBoton : AppEstilos.bordeOscuro, width: activo ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(color: activo ? AppEstilos.verdeBoton : Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  String get _rolEtiqueta => _rolSeleccionado == 'cocina' ? 'Cocina' : 'Mesero';

  Widget _buildCardCodigo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppEstilos.verdeBoton, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(text: 'Código para rol ', style: const TextStyle(color: Colors.white60, fontSize: 12), children: [
                  TextSpan(text: _rolEtiqueta, style: const TextStyle(color: AppEstilos.verdeBoton, fontWeight: FontWeight.bold)),
                ]),
              ),
              GestureDetector(
                onTap: _copiarAlPortapapeles,
                child: const Text('Copiar', style: TextStyle(color: AppEstilos.colorDorado, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_codigoGenerado, style: const TextStyle(color: AppEstilos.colorDorado, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ],
      ),
    );
  }
}
