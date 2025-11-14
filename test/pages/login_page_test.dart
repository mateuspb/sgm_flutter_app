import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mov_app/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mov_app/services/auth_service.dart';

class _AuthMock extends ChangeNotifier implements AuthService {
  bool called = false;
  Future<bool> login(String u, String p) async { called = true; return (u == 'user' && p == '123'); }
  @override bool get isAuthenticated => false;
  @override String? get accessToken => null;
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  testWidgets('Valida campos e tenta login', (tester) async {
    final auth = _AuthMock();
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: auth,
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'user');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(auth.called, isTrue);
  });
}
