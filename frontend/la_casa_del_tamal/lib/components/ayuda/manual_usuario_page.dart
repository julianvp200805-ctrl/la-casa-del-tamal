import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:frontend/components/ayuda/web_helper_stub.dart'
    if (dart.library.html) 'package:frontend/components/ayuda/web_helper_web.dart';
import 'package:frontend/core/colores.dart';

/// Pantalla que muestra el manual de usuario (PDF incluido en assets).
class ManualUsuarioPage extends StatefulWidget {
  static const String routeName = '/manual-usuario';
  const ManualUsuarioPage({super.key});

  @override
  State<ManualUsuarioPage> createState() => _ManualUsuarioPageState();
}

class _ManualUsuarioPageState extends State<ManualUsuarioPage> {
  Uint8List? _bytes;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // En web no usamos flutter_pdfview (plugin nativo). Abrimos el PDF
      // en una nueva pestaña del navegador.
      _cargando = false;
    } else {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    try {
      final data = await rootBundle.load('assets/manuales/manual_usuario.pdf');
      if (!mounted) return;
      setState(() {
        _bytes = data.buffer.asUint8List();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      appBar: AppBar(
        backgroundColor: AppEstilos.fondoOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manual de usuario', style: TextStyle(color: Colors.white, fontFamily: 'serif', fontWeight: FontWeight.bold)),
      ),
      body: kIsWeb
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 64, color: AppEstilos.verdeBoton),
                    const SizedBox(height: 16),
                    const Text(
                      'El manual se abrirá en una nueva pestaña del navegador.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => openPdfInNewTab('assets/manuales/manual_usuario.pdf'),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Abrir manual'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.verdeBoton, foregroundColor: Colors.black87),
                    ),
                  ],
                ),
              ),
            )
          : _cargando
              ? const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton))
              : _error != null
                  ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: Colors.white))))
                  : PDFView(
                      pdfData: _bytes,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      onError: (e) => setState(() => _error = e.toString()),
                    ),
    );
  }
}