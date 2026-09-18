import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/components/ventas_page.dart';
import 'package:frontend/components/admin_menu.dart';
import 'package:frontend/services/chat_service.dart';

/// Página principal del admin - Casa del Tamal
class AdminHomePage extends StatefulWidget {
  static const String routeName = '/admin-home';
  final String logoAssetPath;

  const AdminHomePage({
    super.key,
    this.logoAssetPath = 'assets/image/logo.png',
  });

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _nombreUsuario = 'admin';

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('user_name');
    if (nombre != null && nombre.isNotEmpty && mounted) {
      setState(() => _nombreUsuario = nombre);
    }
  }

  void _abrirChatBot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatBotPage()),
    );
  }

  void _irA(String pantalla) {
    switch (pantalla) {
      case 'Ventas':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VentasPage()),
        );
        break;
      case 'Modificar menu':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminMenuPage()),
        );
        break;
      default:
        // TODO: conectar Pedidos en proceso e Inventario cuando existan
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ir a $pantalla')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppFondo(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildCabecera(),
                const SizedBox(height: 24),
                AppBotonMenu(texto: 'Ventas', onTap: () => _irA('Ventas')),
                const SizedBox(height: 16),
                AppBotonMenu(
                  texto: 'Pedidos en proceso',
                  onTap: () => _irA('Pedidos en proceso'),
                ),
                const SizedBox(height: 16),
                AppBotonMenu(texto: 'Inventario', onTap: () => _irA('Inventario')),
                const SizedBox(height: 16),
                AppBotonMenu(
                  texto: 'Modificar menu',
                  onTap: () => _irA('Modificar menu'),
                ),
                const Spacer(),
                Image.asset(
                  widget.logoAssetPath,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.house, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCabecera() {
    return Row(
      children: [
        // Ícono del tamal = botón del chatbot
        IconButton(
          onPressed: _abrirChatBot,
          icon: const Icon(Icons.eco, color: Colors.white, size: 28),
        ),
        Expanded(
          child: Text(
            'Hola, $_nombreUsuario',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'serif',
            ),
          ),
        ),
        const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }
}

/// Chatbot "Tamalín" conectado al backend real (POST /api/chat).
class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  final List<Map<String, String>> _mensajes = []; // {texto, de}
  bool _cargando = false;

  // El backend devuelve un sesionId; lo guardamos para que toda la
  // conversación quede agrupada en la misma sesión.
  String? _sesionId;

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _bajarScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
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
    _bajarScroll();

    try {
      final resultado = await _chatService.enviarMensaje(
        mensaje: texto,
        sesionId: _sesionId,
      );
      if (!mounted) return;
      setState(() {
        _sesionId = resultado.sesionId;
        _mensajes.add({'texto': resultado.respuesta, 'de': 'bot'});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensajes.add({
          'texto': 'No pude responder: ${e.toString()}',
          'de': 'bot',
        });
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
        _bajarScroll();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoClaro,
      appBar: AppBar(
        title: const Text('Tamalín — Asistente'),
        backgroundColor: AppEstilos.headerInicio,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _mensajes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Pregúntame sobre el menú,\nlas ventas o cómo mejorar el negocio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _mensajes.length,
                    itemBuilder: (context, index) {
                      final msg = _mensajes[index];
                      final esUsuario = msg['de'] == 'usuario';
                      return Align(
                        alignment: esUsuario
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.78,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: esUsuario
                                ? AppEstilos.botonVerde
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppEstilos.sombraSuave,
                          ),
                          child: Text(
                            msg['texto'] ?? '',
                            style: TextStyle(
                              color:
                                  esUsuario ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Tamalín está escribiendo...',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviarMensaje(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        filled: true,
                        fillColor: AppEstilos.colorInput,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppEstilos.botonVerde,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _cargando ? null : _enviarMensaje,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}