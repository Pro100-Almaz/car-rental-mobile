import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_token_storage.dart';

// ---------------------------------------------------------------------------
// Logout event stream — router listens to navigate to /login on session loss.
// ---------------------------------------------------------------------------

final logoutStreamProvider = Provider<Stream<void>>((ref) {
  return ref.watch(logoutControllerProvider).stream;
});

final logoutControllerProvider =
    Provider<LogoutController>((_) => LogoutController());

class LogoutController {
  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;
  void emit() => _controller.add(null);
}

// ---------------------------------------------------------------------------
// AuthInterceptor — attaches Bearer token; retries after transparent refresh.
// ---------------------------------------------------------------------------

const _kRetried = 'x-auth-retried';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor({
    required SecureTokenStorage storage,
    required Dio dio,
    required LogoutController logoutController,
  })  : _storage = storage,
        _dio = dio,
        _logoutController = logoutController;

  final SecureTokenStorage _storage;
  final Dio _dio;
  final LogoutController _logoutController;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final alreadyRetried = err.requestOptions.extra[_kRetried] == true;
    final isRefreshPath =
        err.requestOptions.path.contains('/account/refresh');

    // Prevent infinite loops.
    if (alreadyRetried || isRefreshPath) {
      await _storage.clearTokens();
      _logoutController.emit();
      return handler.next(err);
    }

    final storedRefresh = await _storage.refreshToken;
    if (storedRefresh == null) {
      await _storage.clearTokens();
      _logoutController.emit();
      return handler.next(err);
    }

    try {
      final res = await _dio.post(
        '/account/refresh/',
        data: {'refresh_token': storedRefresh},
        options: Options(extra: {_kRetried: true}),
      );
      final newAccess = res.data['access_token'] as String;
      final newRefresh = res.data['refresh_token'] as String;
      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Retry the original request with the new access token.
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';
      retryOptions.extra[_kRetried] = true;
      final retryResponse = await _dio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } catch (_) {
      await _storage.clearTokens();
      _logoutController.emit();
      return handler.next(err);
    }
  }
}
