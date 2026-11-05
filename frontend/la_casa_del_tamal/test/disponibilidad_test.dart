import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/components/admin/admin_menu_card.dart';
import 'package:frontend/services/menu/menu_services.dart';

MenuItem _plato({bool? disponible}) => MenuItem.fromJson({
  'id': 7,
  'nombre': 'Tamal de olla',
  'precio': 32,
  'disponible': ?disponible,
});

void main() {
  test('sin el campo disponible el plato se toma como disponible', () {
    expect(_plato().disponible, isTrue);
  });

  test('disponible=false agota el plato', () {
    expect(_plato(disponible: false).disponible, isFalse);
  });

  testWidgets('la tarjeta disponible ofrece el gesto de agotar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AdminMenuCard(
          plato: _plato(),
          onEditar: () {},
          onEliminar: () {},
          onToggleDisponibilidad: () {},
        ),
      ),
    ));

    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.text('Agotado'), findsNothing);
  });

  testWidgets('la tarjeta agotada ofrece el gesto de reactivar', (tester) async {
    var reactivado = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AdminMenuCard(
          plato: _plato(disponible: false),
          onEditar: () {},
          onEliminar: () {},
          onToggleDisponibilidad: () => reactivado = true,
        ),
      ),
    ));

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Agotado'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    expect(reactivado, isTrue);
  });
}
