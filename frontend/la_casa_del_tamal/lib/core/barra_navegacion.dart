import 'package:flutter/material.dart';
import 'package:frontend/core/app_estilos.dart';

/// Pestaña de la barra inferior: etiqueta, icono y pantalla que muestra.
/// `pagina` es opcional para las barras que solo se dibujan (pantallas hijas
/// que se abren con Navigator y muestran la barra sin pestana activa).
class PestanaNav {
  final String texto;
  final IconData icono;
  final Widget? pagina;

  const PestanaNav({required this.texto, required this.icono, this.pagina});
}

/// Barra de navegación inferior de los mockups: icono sobre la etiqueta y la
/// pestaña activa lleva una pastilla de color detrás del icono.
class BarraNavegacion extends StatelessWidget {
  final int indiceActivo;
  final ValueChanged<int> onTap;
  final List<PestanaNav> pestanas;
  final Color colorActivo;

  const BarraNavegacion({
    super.key,
    required this.indiceActivo,
    required this.onTap,
    required this.pestanas,
    this.colorActivo = AppEstilos.verdeBoton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppEstilos.fondoBarra,
        border: Border(top: BorderSide(color: AppEstilos.bordeBarra, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              for (var i = 0; i < pestanas.length; i++)
                Expanded(child: _item(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i) {
    final pestana = pestanas[i];
    final activa = i == indiceActivo;
    final color = activa ? colorActivo : AppEstilos.textoBarraInactivo;
    return InkWell(
      onTap: () => onTap(i),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 27,
            decoration: BoxDecoration(
              color: activa ? colorActivo.withValues(alpha: 0.16) : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(pestana.icono, color: color, size: 20),
          ),
          const SizedBox(height: 3),
          Text(
            pestana.texto,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: activa ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Scaffold que comparten los tres roles: fondo, FAB opcional y la barra fija.
/// Las pantallas de cada pestaña van sin su propio Scaffold ni FAB.
class ShellConBarra extends StatefulWidget {
  final List<PestanaNav> pestanas;
  final Color colorActivo;
  final Widget? botonFlotante;
  final int pestanaInicial;

  /// Permite que una pantalla hija abierta con Navigator salte de pestana
  /// (por ejemplo al volver de "Codigo de acceso" a Pedidos).
  final ValueNotifier<int>? controlador;

  const ShellConBarra({
    super.key,
    required this.pestanas,
    this.colorActivo = AppEstilos.verdeBoton,
    this.botonFlotante,
    this.pestanaInicial = 0,
    this.controlador,
  });

  @override
  State<ShellConBarra> createState() => _ShellConBarraState();
}

class _ShellConBarraState extends State<ShellConBarra> {
  late int _activa = widget.controlador?.value ?? widget.pestanaInicial;

  @override
  void initState() {
    super.initState();
    widget.controlador?.addListener(_sincronizar);
  }

  void _sincronizar() {
    if (mounted) setState(() => _activa = widget.controlador!.value);
  }

  @override
  void dispose() {
    widget.controlador?.removeListener(_sincronizar);
    super.dispose();
  }

  void _elegir(int i) {
    widget.controlador?.value = i;
    setState(() => _activa = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: widget.botonFlotante,
      bottomNavigationBar: BarraNavegacion(
        indiceActivo: _activa,
        colorActivo: widget.colorActivo,
        onTap: _elegir,
        pestanas: widget.pestanas,
      ),
      // IndexedStack conserva el estado y el scroll de cada pestaña al cambiar.
      body: IndexedStack(
        index: _activa,
        children: [for (final p in widget.pestanas) p.pagina ?? const SizedBox.shrink()],
      ),
    );
  }
}
