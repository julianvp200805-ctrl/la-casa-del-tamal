import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/components/ventas_page.dart';
import 'package:frontend/components/admin_menu.dart';

/// Página principal del admin - Casa del Tamal
/// Muestra el nombre del usuario logueado, el menú de opciones y un
/// botón de chatbot (ícono del tamal).
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

  // El nombre ya se guardó en el login (gerent_services.dart), aquí solo
  // se lee de SharedPreferences.
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
        // TODO: reemplazar por Navigator.push a cada página real
        // (Pedidos en proceso, Inventario, Modificar menu) cuando existan.
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

/// Página simple de chatbot, conectada al backend.
/// Reemplaza la URL/endpoint por el real cuando lo tengas.
class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _mensajeController = TextEditingController();
  final List<Map<String, String>> _mensajes = []; // {texto, de: 'usuario'/'bot'}
  bool _cargando = false;

  Future<void> _enviarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add({'texto': texto, 'de': 'usuario'});
      _cargando = true;
    });
    _mensajeController.clear();

    try {
      // TODO: reemplazar por la llamada real al backend del chatbot
      // final respuesta = await ChatService().enviarMensaje(texto);
      await Future.delayed(const Duration(seconds: 1));
      final respuesta = 'Respuesta de ejemplo del chatbot';
      setState(() => _mensajes.add({'texto': respuesta, 'de': 'bot'}));
    } catch (e) {
      setState(() => _mensajes.add({'texto': 'Error: $e', 'de': 'bot'}));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente Casa del Tamal')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                final esUsuario = msg['de'] == 'usuario';
                return Align(
                  alignment:
                      esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: esUsuario ? Colors.green.shade200 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['texto'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (_cargando) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}