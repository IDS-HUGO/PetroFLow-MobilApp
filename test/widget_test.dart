import 'package:flutter_test/flutter_test.dart';
import 'package:petroflow/app/app.dart';

void main() {
  testWidgets('PetroFlow muestra la pantalla de acceso', (tester) async {
    await tester.pumpWidget(const App());

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PetroFlow'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Crear cuenta nueva'), findsOneWidget);
  });
}
