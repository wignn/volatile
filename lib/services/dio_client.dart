import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vasvault/constants/app_constant.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/utils/session_meneger.dart';

/// Global navigator key for redirecting from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Singleton class providing a shared Dio instance with auto token refresh
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final SessionManager _session = SessionManager();
  bool _isRefreshing = false;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: '${AppConstants.baseUrl}/api/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.tokenKey,
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _session.getAccessToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;

            try {
              final newTokens = await _refreshToken();

              if (newTokens != null) {
                await _session.saveSession(
                  newTokens.accessToken,
                  newTokens.refreshToken,
                  await _session.getId(),
                );

                final opts = error.requestOptions;
                opts.headers['Authorization'] =
                    'Bearer ${newTokens.accessToken}';

                final response = await dio.fetch(opts);
                _isRefreshing = false;
                return handler.resolve(response);
              } else {
                await _handleSessionExpired();
              }
            } catch (_) {
              await _handleSessionExpired();
            }

            _isRefreshing = false;
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<AuthResponseModel?> _refreshToken() async {
    try {
      String refreshToken = await _session.getRefreshToken();
      if (refreshToken.isEmpty) return null;

      final response = await Dio().post(
        '${AppConstants.baseUrl}/api/v1/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': AppConstants.tokenKey,
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleSessionExpired() async {
    await _session.removeAccessToken();
    _isRefreshing = false;

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}
