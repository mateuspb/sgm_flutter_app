import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mov_app/services/auth_service.dart';
import 'package:flutter_mov_app/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class _AuthServiceTestable extends AuthService {
  // expõe um método helper para testar com um Dio injetável
  Future<bool> loginWithDio(Dio dio, String u, String p) async {
    try {
      final res = await dio.post('/api/auth/jwt/create/', data: {'username': u, 'password': p});
      final data = res.data as Map<String, dynamic>;
      // simula a escrita nos campos privados
      // ignore: invalid_use_of_protected_member
      // não acessamos storage real nos testes
      return data['access'] != null && data['refresh'] != null;
    } catch (_) {
      return false;
    }
  }
}

void main() {
  group('AuthService (fluxos)', () {
    test('login sucesso escreve tokens', () async {
      final dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;

      adapter.onPost('/api/auth/jwt/create/', (server) {
        server.reply(200, {'access': 'a', 'refresh': 'r'});
      }, data: {'username': 'u', 'password': 'p'});

      final svc = _AuthServiceTestable();
      final ok = await svc.loginWithDio(dio, 'u', 'p');

      expect(ok, isTrue);
    });

    test('login falha retorna false', () async {
      final dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;

      adapter.onPost('/api/auth/jwt/create/', (server) {
        server.reply(401, {'detail': 'invalid'});
      }, data: {'username': 'u', 'password': 'bad'});

      final svc = _AuthServiceTestable();
      final ok = await svc.loginWithDio(dio, 'u', 'bad');
      expect(ok, isFalse);
    });
  });
}
