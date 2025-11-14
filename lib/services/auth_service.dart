import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _access;
  String? _refresh;

  bool get isAuthenticated => _access != null && _access!.isNotEmpty;
  String? get accessToken => _access;

  Future<void> loadTokens() async {
    _access = await _storage.read(key: 'access');
    _refresh = await _storage.read(key: 'refresh');
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final dio = ApiClient().dioNoAuth;
      final res = await dio.post('/api/v1/authentication/token/', data: {
        'username': username,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      _access = data['access'] as String?;
      _refresh = data['refresh'] as String?;
      if (_access == null || _refresh == null) {
        throw Exception('Token não recebido');
      }
      await _storage.write(key: 'access', value: _access);
      await _storage.write(key: 'refresh', value: _refresh);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      String msg = 'Falha no login';
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        msg = 'Credenciais inválidas';
      } else if (e.type == DioExceptionType.connectionError) {
        msg = 'Sem conexão com o servidor';
      } else if (e.response != null) {
        msg = 'Erro (${e.response!.statusCode})';
      }
      throw Exception(msg);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _access = null;
    _refresh = null;
    await _storage.delete(key: 'access');
    await _storage.delete(key: 'refresh');
    notifyListeners();
  }

  Future<String?> refreshToken() async {
    if (_refresh == null) return null;
    try {
      final dio = ApiClient().dioNoAuth;
      final res =
          await dio.post('/api/v1/authentication/token/refresh/', data: {
        'refresh': _refresh,
      });
      final data = res.data as Map<String, dynamic>;
      _access = data['access'] as String?;
      if (_access != null) {
        await _storage.write(key: 'access', value: _access);
        notifyListeners();
      }
      return _access;
    } catch (_) {
      return null;
    }
  }
}
