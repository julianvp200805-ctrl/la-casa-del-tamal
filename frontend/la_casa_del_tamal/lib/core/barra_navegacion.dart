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

class _ShellConBarraState extends State<ShellConBarra> with SingleTickerProviderStateMixin {
  late int _activa = widget.controlador?.value ?? widget.pestanaInicial;

  /// Desplazamiento en píxeles mientras el dedo arrastra la pantalla.
  double _deslize = 0;

  /// Punto de partida del deslizamiento de la pestaña nueva: el ancho completo
  /// al tocar la barra, o donde quedó el dedo al soltar el arrastre.
  double _desde = 0;

  late final AnimationController _anima =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 280))..value = 1;

  static const double _umbral = 44;

  @override
  void initState() {
    super.initState();
    widget.controlador?.addListener(_sincronizar);
  }

  void _sincronizar() => _moverA(widget.controlador!.value);

  @override
  void dispose() {
    widget.controlador?.removeListener(_sincronizar);
    _anima.dispose();
    super.dispose();
  }

  /// Cambia de pestaña deslizando la nueva hacia su sitio. `desde` evita el
  /// brinco cuando el cambio nace de un arrastre: se retoma del punto donde
  /// quedó el dedo en vez de empezar desde el borde de la pantalla.
  void _moverA(int i, {double? desde}) {
    if (!mounted) return;
    if (i < 0 || i >= widget.pestanas.length || i == _activa) {
      if (_deslize != 0) setState(() => _deslize = 0);
      return;
    }
    final ancho = MediaQuery.sizeOf(context).width;
    setState(() {
      _desde = desde ?? (i > _activa ? ancho : -ancho);
      _deslize = 0;
      _activa = i;
    });
    if (widget.controlador != null && widget.controlador!.value != i) widget.controlador!.value = i;
    _anima.forward(from: 0);
  }

  void _alArrastrar(DragUpdateDetails d) {
    final primera = _activa == 0;
    final ultima = _activa == widget.pestanas.length - 1;
    var dx = _deslize + d.delta.dx;
    // En los extremos la pantalla cede poco, para que se sienta que no hay más.
    if ((primera && dx > 0) || (ultima && dx < 0)) dx = dx / 3;
    setState(() => _deslize = dx.clamp(-_umbral * 1.6, _umbral * 1.6));
  }

  void _alSoltar(DragEndDetails d) {
    final velocidad = d.velocity.pixelsPerSecond.dx;
    final destino = (_deslize < -_umbral || velocidad < -400)
        ? _activa + 1
        : (_deslize > _umbral || velocidad > 400)
            ? _activa - 1
            : _activa;
    if (destino == _activa) {
      setState(() => _deslize = 0);
      return;
    }
    _moverA(destino, desde: _deslize);
  }

  @override
  Widget build(BuildContext context) {
    final deslizable = widget.pestanas.length > 1;
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: widget.botonFlotante,
      bottomNavigationBar: BarraNavegacion(
        indiceActivo: _activa,
        colorActivo: widget.colorActivo,
        onTap: _moverA,
        pestanas: widget.pestanas,
      ),
      // IndexedStack conserva el estado y el scroll de cada pestaña; la que
      // entra se desliza desde el lado que toca en vez de aparecer de golpe.
      body: GestureDetector(
        onHorizontalDragUpdate: deslizable ? _alArrastrar : null,
        onHorizontalDragEnd: deslizable ? _alSoltar : null,
        onHorizontalDragCancel: () => setState(() => _deslize = 0),
        child: AnimatedBuilder(
          animation: _anima,
          builder: (context, child) => Transform.translate(
            offset: Offset(_desde * (1 - Curves.easeOutCubic.transform(_anima.value)) + _deslize, 0),
            child: child,
          ),
          child: IndexedStack(
            index: _activa,
            children: [for (final p in widget.pestanas) p.pagina ?? const SizedBox.shrink()],
          ),
        ),
      ),
    );
  }
}
