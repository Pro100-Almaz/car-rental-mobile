import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simplified connectivity status.
enum ConnectivityStatus { online, offline }

/// StreamProvider that emits [ConnectivityStatus] changes.
///
/// Starts with an optimistic [online] emission; subsequent values come from
/// the device connectivity stream. The shell uses this to show/hide the
/// offline banner.
final connectivityStatusProvider =
    StreamProvider<ConnectivityStatus>((ref) async* {
  // Check initial state
  final initial = await Connectivity().checkConnectivity();
  yield _fromResults(initial);

  // Listen for changes
  yield* Connectivity()
      .onConnectivityChanged
      .map((results) => _fromResults(results));
});

ConnectivityStatus _fromResults(List<ConnectivityResult> results) {
  if (results.isEmpty) return ConnectivityStatus.offline;
  final hasConnection = results.any(
    (r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet,
  );
  return hasConnection
      ? ConnectivityStatus.online
      : ConnectivityStatus.offline;
}
