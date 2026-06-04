import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/payment_record.dart';

export '../models/payment_record.dart';

class PaymentsNotifier extends AsyncNotifier<List<PaymentRecord>> {
  @override
  Future<List<PaymentRecord>> build() async {
    return _fetch();
  }

  Future<List<PaymentRecord>> _fetch() async {
    final api = ref.read(mobileClientsApiProvider);
    return api.getPayments();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final paymentsProvider =
    AsyncNotifierProvider<PaymentsNotifier, List<PaymentRecord>>(
        PaymentsNotifier.new);
