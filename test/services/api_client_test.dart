import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:flutter_mov_app/services/api_client.dart';
import 'package:flutter_mov_app/services/auth_service.dart';

class _AuthLogged extends AuthService {
  @override
  bool get isAuthenticated => true;
  @override
  String? get accessToken => 'tok';
}

void main() {
  test('dioNoAuth tem baseUrl e timeouts configurados', () {
    final client = ApiClient();
    final dio = client.dioNoAuth;
    expect(dio.options.baseUrl, ApiClient.baseUrl);
    expect(dio.options.connectTimeout, const Duration(seconds: 10));
    expect(dio.options.receiveTimeout, const Duration(seconds: 15));
  });

  testWidgets(
    'dioWithAuth injeta Authorization quando autenticado (Dio v5, curto-circuito)',
    (tester) async {
      // Monta uma árvore mínima com Provider<AuthService> logado e captura o contexto.
      BuildContext? ctx;
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>.value(
          value: _AuthLogged(),
          child: MaterialApp(
            home: Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(ctx, isNotNull);

      final client = ApiClient();
      final dio = client.dioWithAuth(ctx!);

      // Short-circuit: intercepta a request, captura o header e resolve 200 sem rede/adapters.
      String? capturedAuth;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedAuth = options.headers['Authorization'] as String?;
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: const {'ok': true},
            ));
          },
        ),
      );

      // Executa a Future em runAsync para não prender o loop do tester.
      final Response<dynamic>? res = await tester.runAsync(() => dio.get('/x'));

      expect(res?.statusCode, 200);
      expect(capturedAuth, isNotNull);
      expect(capturedAuth!.startsWith('Bearer '), isTrue);

      // Garante que nada fica pendente após o teste.
      dio.close(force: true);
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );
}
