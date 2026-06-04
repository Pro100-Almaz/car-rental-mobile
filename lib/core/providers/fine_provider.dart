import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/fine.dart';

// Re-export FineStatus so existing import sites keep working.
export '../models/fine.dart' show Fine, FineStatus;

/// AsyncNotifier that fetches fines from GET /mobile/clients/me/fines
class FinesNotifier extends AsyncNotifier<List<Fine>> {
  @override
  Future<List<Fine>> build() async {
    return _fetch();
  }

  Future<List<Fine>> _fetch() async {
    final api = ref.read(mobileClientsApiProvider);
    return api.getFines();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final finesProvider =
    AsyncNotifierProvider<FinesNotifier, List<Fine>>(FinesNotifier.new);

/// Derived count of unpaid fines — used for the badge on the profile screen.
final unpaidFinesCountProvider = Provider<int>((ref) {
  return ref.watch(finesProvider).maybeWhen(
        data: (fines) => fines.where((f) => f.isUnpaid).length,
        orElse: () => 0,
      );
});

final totalUnpaidAmountProvider = Provider<int>((ref) {
  return ref.watch(finesProvider).maybeWhen(
        data: (fines) => fines
            .where((f) => f.isUnpaid)
            .fold(0, (sum, f) => sum + f.amount),
        orElse: () => 0,
      );
});
