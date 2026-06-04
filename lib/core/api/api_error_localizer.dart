import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import 'api_exception.dart';

/// Maps a typed [ApiException] to a user-facing localized string.
String localizeApiError(BuildContext context, ApiException error) {
  final l10n = AppL10n.of(context);
  return switch (error.code) {
    'network_offline' => l10n.errorNetworkOffline,
    'unauthorized' => l10n.errorUnauthorized,
    'rate_limited' => l10n.errorRateLimited,
    'server' => l10n.errorServer,
    _ => error.serverMessage ?? l10n.errorUnknown,
  };
}
