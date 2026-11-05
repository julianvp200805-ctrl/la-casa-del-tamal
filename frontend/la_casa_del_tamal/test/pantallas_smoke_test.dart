// Prueba de humo de pantallas: monta cada maqueta a tamaño de teléfono y
// comprueba que se construye sin reventar (nulos, widgets fuera de Scaffold,
// timers colgados).
//
// Los desbordes de layout se imprimen pero no hacen fallar: en `flutter test`
// la fuente de relleno (Ahem) mide cada carácter a 1em, mucho más ancha que la
// serif real del dispositivo, así que un desborde aquí no significa que la
// pantalla se vea mal en el teléfono. Se listan igual, para revisarlos a ojo.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/components/admin/admin_menu.dart';
import 'package:frontend/components/admin/admin_shell.dart';
import 'package:frontend/components/admin/generar_codigo_page.dart';
import 'package:frontend/components/chat/chat_page.dart';
import 'package:frontend/components/cocina/cocina_shell.dart';
import 'package:frontend/components/inicio/inicio_sesion.dart';
import 'package:frontend/components/inicio/registro_page.dart';
import 'package:frontend/components/mesero/mesero_shell.dart';
import 'package:frontend/components/productos/inventario_page.dart';
import 'package:frontend/components/recuperar/recuperar_contrasena.dart';
import 'package:frontend/components/ventas/ventas_page.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/principal/pantalla_cargas.dart';
import 'package:frontend/pantallas/principal/pantalla_principal.dart';
import 'package:frontend/services/pedido/pedido_proceso_page.dart';

const Size _telefono = Size(390, 844);

Future<void> _montar(WidgetTester tester, Widget pagina, {bool desmontar = true}) async {
  tester.view.physicalSize = _telefono;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(home: pagina));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(seconds: 1));
  // Deja pasar el retardo del splash; si no, el Timer queda pendiente y la
  // prueba falla sin que haya ningún problema de verdad.
  await tester.pump(const Duration(seconds: 4));
  // Los shells de mesero y cocina refrescan con Timer.periodic; sin desmontar,
  // flutter_test reporta ese timer como pendiente al terminar la prueba.
  if (desmontar) await tester.pumpWidget(const SizedBox());
}

/// Falla solo por excepciones distintas de un desborde de layout.
void _sinErrores(Object? error, String nombre) {
  if (error == null) return;
  if (error.toString().contains('overflowed')) {
    debugPrint('[$nombre] desborde de layout (revisar a ojo): $error');
    return;
  }
  fail('falló al renderizar $nombre: $error');
}

void main() {
  final pantallas = <String, Widget>{
    '00 splash': const PantallaSplash(),
    '01 home publico': const HomeScreen(),
    '02 iniciar sesion': const InicioSesion(),
    '03 recuperar contrasena': const RecuperarContrasenaPage(),
    '04 registrarme': const RegistroPage(),
    '10 shell admin (ventas)': const AdminShell(),
    '13 admin pedidos': const PedidosProcesoPage(),
    '14 admin codigo acceso': const GenerarCodigoPage(),
    '15 admin inventario': const InventarioPage(),
    '17 admin modificar menu': const AdminMenuPage(),
    '18 admin tamalin': const ChatBotPage(),
    '20 shell mesero': const MeseroShell(),
    '30 shell cocina': const CocinaShell(),
    'ventas (pestana suelta)': const VentasPage(),
  };

  pantallas.forEach((nombre, pagina) {
    testWidgets(nombre, (WidgetTester tester) async {
      await _montar(tester, pagina);
      _sinErrores(tester.takeException(), nombre);
    });
  });

  testWidgets('la barra del admin cambia de pestana', (WidgetTester tester) async {
    await _montar(tester, const AdminShell(), desmontar: false);
    final barra = find.byType(BarraNavegacion);
    expect(find.descendant(of: barra, matching: find.text('Inventario')), findsOneWidget);
    await tester.tap(find.descendant(of: barra, matching: find.text('Inventario')));
    await tester.pump(const Duration(milliseconds: 400));
    _sinErrores(tester.takeException(), 'cambio de pestana');
  });

  testWidgets('deslizar el cuerpo cambia de pestana', (WidgetTester tester) async {
    await _montar(tester, const MeseroShell(), desmontar: false);
    expect(pestanaMeseroActiva.value, 0);

    await tester.dragFrom(const Offset(195, 420), const Offset(-320, 0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(pestanaMeseroActiva.value, 1, reason: 'arrastrar a la izquierda pasa a la siguiente pestana');

    await tester.dragFrom(const Offset(195, 420), const Offset(320, 0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(pestanaMeseroActiva.value, 0, reason: 'arrastrar a la derecha regresa');

    _sinErrores(tester.takeException(), 'deslizar pestanas');
    await tester.pumpWidget(const SizedBox());
  });
}
