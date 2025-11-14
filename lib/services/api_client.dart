import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl = 'http://98.94.247.216:80';

  Dio get dioNoAuth {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    return dio;
  }

  Dio dioWithAuth(BuildContext context) {
    final dio = dioNoAuth;

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final auth = Provider.of<AuthService>(context, listen: false);
        final token = auth.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final auth = Provider.of<AuthService>(context, listen: false);
          final newAccess = await auth.refreshToken();
          if (newAccess != null) {
            e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
            final cloneReq = await dio.fetch(e.requestOptions);
            return handler.resolve(cloneReq);
          }
        }
        return handler.next(e);
      },
    ));
    return dio;
  }
}
