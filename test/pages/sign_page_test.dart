import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mov_app/pages/sign_page.dart';

void main() {
  testWidgets('Abre página de assinatura', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignPage(movId: 1, titulo: 'Teste')));
    expect(find.textContaining('Teste'), findsOneWidget);
    expect(find.byType(SignPage), findsOneWidget);
  });
}
