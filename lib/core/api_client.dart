import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // Points to Render backend so that the mobile app can load live database data just like the website.
      // Change to 'http://10.0.2.2:5000/api' if testing with a local emulator, or use your computer's local IP (e.g. http://192.168.x.x:5000/api) for local physical device testing.
      baseUrl: 'https://smart-inventory-management-system-backend.onrender.com/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          // TODO: Handle automatic logout here using ref
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
