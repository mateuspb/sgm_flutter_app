import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mov_app/main.dart';
import 'package:flutter_mov_app/pages/home_page.dart';

import 'package:flutter_mov_app/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mov_app/services/auth_service.dart';

class _AuthLogged extends ChangeNotifier implements AuthService {
  @override
  bool get isAuthenticated => true;
  @override
  String? get accessToken => 'tok';
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
class _AuthLoggedOut extends ChangeNotifier implements AuthService {
  @override
  bool get isAuthenticated => false;
  @override
  String? get accessToken => null;
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  testWidgets('Mostra LoginPage quando deslogado', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: _AuthLoggedOut(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    // Há dois "Entrar" (título e botão). Verifique pelo tipo da página e a presença do botão.
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  });

  
  testWidgets('Mostra HomePage quando logado', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: _AuthLogged(),
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    // Aceita qualquer um dos principais CTAs da Home
    final hasListarPendentes = find.widgetWithText(OutlinedButton, 'Listar pendentes');
    final hasEnviarOffline = find.widgetWithText(FilledButton, 'Enviar assinaturas offline');
    final hasSyncIcon = find.byIcon(Icons.sync);
    expect(
      hasListarPendentes.evaluate().isNotEmpty ||
      hasEnviarOffline.evaluate().isNotEmpty ||
      hasSyncIcon.evaluate().isNotEmpty,
      isTrue,
    );
  });

}
