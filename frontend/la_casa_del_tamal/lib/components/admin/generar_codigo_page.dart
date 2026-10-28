import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/colores.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/services/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // MODIFICACIÓN DE RUTA: Probamos apuntar al path con el prefijo /api/ común en servidores Express
      String urlFinal = '${ApiConfig.baseUrl}/auth/generar-codigo';
      if (!ApiConfig.baseUrl.endsWith('/api') && !urlFinal.contains('/api/')) {
        urlFinal = '${ApiConfig.baseUrl}/api/auth/generar-codigo';
      }

      final response = await http.post(
        Uri.parse(urlFinal),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {'rol': _rolSeleccionado},
      );

      // Si la ruta /api/ dio error 404/HTML, reintentamos con la ruta plana original de respaldo
      if (response.body.trim().startsWith('<!DOCTYPE')) {
        final fallbackResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/generar-codigo'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },
          body: {'rol': _rolSeleccionado},
        );

        if (fallbackResponse.body.trim().startsWith('<!DOCTYPE')) {
          _notificar('Ruta inválida en Render. Revisa tus logs de Express.', esError: true);
          return;
        }
        _procesarRespuesta(fallbackResponse);
      } else {
        _procesarRespuesta(response);
      }
    } catch (e) {
      _notificar('Error de red: ${e.toString()}', esError: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _procesarRespuesta(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() => _codigoGenerado = data['codigo'] ?? '');
      _notificar('Código generado con éxito', esError: false);
    } else {
      _notificar(data['error'] ?? 'Error al generar código', esError: true);
    }
  }

  void _notificar(String texto, {required bool esError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copiarAlPortapapeles() {
    if (_codigoGenerado.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _codigoGenerado));
    _notificar('Código copiado al portapapeles', esError: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
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
              const Text('Codigo de acceso', style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'serif', fontWeight: FontWeight.bold)),
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
              const Text('El código vence en: 15 minutos', style: TextStyle(color: Colors.white60, fontSize: 13, fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _peticionGenerarCodigo,
                  style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.verdeBoton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _cargando 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Generar codigo', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
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
            Text(titulo, style: TextStyle(color: activo ? AppEstilos.verdeBoton : Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

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
              Text('Código para rol ${_rolSeleccionado.toUpperCase()}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
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