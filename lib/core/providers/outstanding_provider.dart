import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/outstanding.dart';

export '../models/outstanding.dart';

class OutstandingNotifier extends AsyncNotifier<OutstandingResponse> {
  @override
  Future<OutstandingResponse> build() async {
    return _fetch();
  }

  Future<OutstandingResponse> _fetch() async {
    final api = ref.read(mobileClientsApiProvider);
    return api.getOutstanding();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final outstandingProvider =
    AsyncNotifierProvider<OutstandingNotifier, OutstandingResponse>(
        OutstandingNotifier.new);
