/// Fine statuses as returned by the backend.
enum FineStatus {
  chargedToClient,
  paidPending,
  paidConfirmed,
  disputed,
}

FineStatus fineStatusFromString(String raw) => switch (raw) {
      'charged_to_client' => FineStatus.chargedToClient,
      'paid_pending' => FineStatus.paidPending,
      'paid_confirmed' => FineStatus.paidConfirmed,
      'disputed' => FineStatus.disputed,
      _ => FineStatus.chargedToClient,
    };

String fineStatusToWire(FineStatus s) => switch (s) {
      FineStatus.chargedToClient => 'charged_to_client',
      FineStatus.paidPending => 'paid_pending',
      FineStatus.paidConfirmed => 'paid_confirmed',
      FineStatus.disputed => 'disputed',
    };

class Fine {
  const Fine({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.status,
    this.rentalId,
    this.dueDate,
  });

  final String id;
  final int amount;
  final String description;
  final DateTime createdAt;
  final FineStatus status;
  final String? rentalId;
  final DateTime? dueDate;

  bool get isUnpaid =>
      status == FineStatus.chargedToClient || status == FineStatus.paidPending;

  factory Fine.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        json['status'] as String? ?? 'charged_to_client';
    final createdRaw =
        json['created_at'] as String? ?? json['createdAt'] as String? ?? '';
    final dueRaw =
        json['due_date'] as String? ?? json['dueDate'] as String?;

    return Fine(
      id: (json['id'] ?? '').toString(),
      amount: (json['amount'] as num? ?? 0).toInt(),
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(createdRaw) ?? DateTime.now(),
      status: fineStatusFromString(rawStatus),
      rentalId: json['rental_id'] as String? ?? json['rentalId'] as String?,
      dueDate: dueRaw != null ? DateTime.tryParse(dueRaw) : null,
    );
  }
}
