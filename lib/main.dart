import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/observability/crash_reporter.dart';
import 'core/observability/observability_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/push/push_config.dart';
import 'core/push/push_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error handler — routes to Crashlytics when enabled.
  FlutterError.onError = (details) {
    if (kEnableCrashlytics) {
      CrashReporter.instance.recordFlutterError(details);
    }
    FlutterError.presentError(details);
  };

  // Global platform/isolate error handler.
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kEnableCrashlytics) {
      CrashReporter.instance.recordError(error, stack);
    }
    return false;
  };

  if (kEnablePush) await PushService.instance.init();
  if (kEnableCrashlytics) await CrashReporter.instance.init();

  runApp(const ProviderScope(child: AutoFleetApp()));
}

class AutoFleetApp extends ConsumerWidget {
  const AutoFleetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = AppRouter.buildRouter(ref);
    return MaterialApp.router(
      title: 'AutoFleet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      builder: (context, child) => MediaQuery(
        // M6.E — clamp text scale factor to [1.0, 1.3] for accessibility.
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(context)
              .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
        ),
        child: _BootstrapController(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// Bootstrap widget — placed at the root to call [AuthNotifier.bootstrap]
/// once on app start. Uses a [FutureProvider] pattern so the router fires
/// after the token check completes.
class _BootstrapController extends ConsumerStatefulWidget {
  const _BootstrapController({required this.child});
  final Widget child;

  @override
  ConsumerState<_BootstrapController> createState() =>
      _BootstrapControllerState();
}

class _BootstrapControllerState
    extends ConsumerState<_BootstrapController> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget; AuthNotifier emits state changes that the router
    // observes via _ProviderListenable.
    ref.read(currentUserProvider.notifier).bootstrap();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
