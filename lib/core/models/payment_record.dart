/// Payment method enum — wire values are lowercase strings.
enum PaymentMethodType {
  kaspi,
  cash,
  card,
  bankTransfer,
}

PaymentMethodType paymentMethodFromString(String raw) => switch (raw) {
      'kaspi' => PaymentMethodType.kaspi,
      'cash' => PaymentMethodType.cash,
      'card' => PaymentMethodType.card,
      'bank_transfer' => PaymentMethodType.bankTransfer,
      _ => PaymentMethodType.cash,
    };

String paymentMethodToWire(PaymentMethodType m) => switch (m) {
      PaymentMethodType.kaspi => 'kaspi',
      PaymentMethodType.cash => 'cash',
      PaymentMethodType.card => 'card',
      PaymentMethodType.bankTransfer => 'bank_transfer',
    };

/// Payment record status.
enum PaymentRecordStatus { pending, completed, rejected }

PaymentRecordStatus paymentStatusFromString(String raw) => switch (raw) {
      'completed' => PaymentRecordStatus.completed,
      'rejected' => PaymentRecordStatus.rejected,
      _ => PaymentRecordStatus.pending,
    };

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.note,
    this.rentalId,
    this.fineId,
    this.confirmedAt,
  });

  final String id;
  final int amount;
  final PaymentMethodType method;
  final PaymentRecordStatus status;
  final DateTime createdAt;
  final String? note;
  final String? rentalId;
  final String? fineId;
  final DateTime? confirmedAt;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    final rawMethod = json['method'] as String? ?? 'cash';
    final rawStatus = json['status'] as String? ?? 'pending';
    final createdRaw =
        json['created_at'] as String? ?? json['createdAt'] as String? ?? '';
    final confirmedRaw =
        json['confirmed_at'] as String? ?? json['confirmedAt'] as String?;

    return PaymentRecord(
      id: (json['id'] ?? '').toString(),
      amount: (json['amount'] as num? ?? 0).toInt(),
      method: paymentMethodFromString(rawMethod),
      status: paymentStatusFromString(rawStatus),
      createdAt: DateTime.tryParse(createdRaw) ?? DateTime.now(),
      note: json['note'] as String?,
      rentalId: json['rental_id'] as String? ?? json['rentalId'] as String?,
      fineId: json['fine_id'] as String? ?? json['fineId'] as String?,
      confirmedAt:
          confirmedRaw != null ? DateTime.tryParse(confirmedRaw) : null,
    );
  }
}
