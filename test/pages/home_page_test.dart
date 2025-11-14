import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mov_app/pages/home_page.dart';

void main() {
  testWidgets('Renderiza botões principais', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // Verifica pelos textos dos CTAs (independente do tipo de botão)
    expect(find.text('Listar pendentes'), findsOneWidget);
    expect(find.text('Enviar assinaturas offline'), findsOneWidget);

    // Ícone de sincronização na AppBar
    expect(find.byIcon(Icons.sync), findsOneWidget);
  });
}
