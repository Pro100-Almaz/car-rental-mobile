import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Logout event stream — screens/providers listen to navigate to /login.
// ---------------------------------------------------------------------------

/// Broadcast stream that emits when the session is invalidated (401 received).
/// Wire this in a [ProviderScope] listener to redirect to /login.
final logoutStreamProvider = Provider<Stream<void>>((ref) {
  return ref.watch(logoutControllerProvider).stream;
});

final logoutControllerProvider =
    Provider<_LogoutController>((_) => _LogoutController());

class _LogoutController {
  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;
  void emit() => _controller.add(null);
}

// NOTE: AuthInterceptor (Bearer + refresh) has been removed.
// Cookie-based auth is handled automatically by CookieManager in api_client.dart.
// The auth_token cookie is set by the FastAPI backend on POST /account/login/
// and cleared server-side on DELETE /account/logout/.
// A 401 response means the cookie has expired — bootstrap() will detect it
// and emit AuthUnauthenticated to redirect the user to /login.
