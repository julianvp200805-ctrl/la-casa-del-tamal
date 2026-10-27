import 'package:flutter/material.dart';
import 'app_estilos.dart';

/// Botón grande de menú, con sombra y borde, igual al de las pantallas
/// de Ventas / Inventario / Pedidos / Modificar menú.
class AppBotonMenu extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  final bool cargando;
  final Color? color; // si no se pasa, usa el verde de siempre
  
  const AppBotonMenu({
    super.key,
    required this.texto,
    required this.onTap,
    this.cargando = false,
    this.color,
  });

  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppEstilos.radioBoton),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 120, // grande, como en el mockup
        child: ElevatedButton(
          onPressed: cargando ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppEstilos.botonVerde,
            side: BorderSide(color: color ?? AppEstilos.botonBorde, width: 1.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEstilos.radioBoton),
            ),
          ),
          child: cargando
              ? const SizedBox(
                  width: 35,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  texto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Tarjeta blanca/verde suave para mostrar datos (usada en los reportes).
class AppTarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppTarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppEstilos.radioTarjeta),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: child,
    );
  }
}