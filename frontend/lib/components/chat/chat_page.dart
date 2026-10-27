import 'package:flutter/material.dart';
import 'package:frontend/components/chat/chat_input.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/chat/chat_service.dart';

/// Asistente "Tamalín" conectado al backend (POST /api/chat vía ChatService).
class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final _mensajeController = TextEditingController();
  final _scroll = ScrollController();
  final ChatService _chatService = ChatService();
  final List<Map<String, String>> _mensajes = []; // {texto, de: 'usuario'/'bot'}
  bool _cargando = false;
  String? _sesionId; // agrupa la conversación en el backend

  @override
  void dispose() {
    _mensajeController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  Future<void> _enviarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty || _cargando) return;

    setState(() {
      _mensajes.add({'texto': texto, 'de': 'usuario'});
      _cargando = true;
    });
    _mensajeController.clear();
    _bajar();

    try {
      final res = await _chatService.enviarMensaje(mensaje: texto, sesionId: _sesionId);
      if (!mounted) return;
      setState(() {
        _sesionId = res.sesionId;
        _mensajes.add({'texto': res.respuesta, 'de': 'bot'});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _mensajes.add({'texto': 'No pude responder: $e', 'de': 'bot'}));
    } finally {
      if (mounted) setState(() => _cargando = false);
      _bajar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 24, 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).maybePop()),
                  const SizedBox(width: 6),
                  const Text('Tamalin - Asistente', style: TextStyle(color: AppEstilos.verdeAccion, fontSize: 16)),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset('assets/image/logo.png', width: 200, errorBuilder: (_, __, ___) => const Icon(Icons.house, size: 100, color: AppEstilos.verdeBoton)),
                  ),
                  ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    itemCount: _mensajes.length,
                    itemBuilder: (context, i) => _burbuja(_mensajes[i]),
                  ),
                ],
              ),
            ),
            if (_cargando) const LinearProgressIndicator(minHeight: 2, color: AppEstilos.verdeAccion, backgroundColor: AppEstilos.inputOscuro),
            ChatInput(
              controller: _mensajeController,
              enviando: _cargando,
              onEnviar: _enviarMensaje,
            ),
          ],
        ),
      ),
    );
  }

  Widget _burbuja(Map<String, String> msg) {
    final usuario = msg['de'] == 'usuario';
    return Align(
      alignment: usuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(color: usuario ? AppEstilos.verdeAccion : AppEstilos.burbujaBot, borderRadius: BorderRadius.circular(16)),
        child: Text(msg['texto'] ?? '', style: TextStyle(color: usuario ? Colors.black87 : Colors.white70, fontSize: 13)),
      ),
    );
  }
}