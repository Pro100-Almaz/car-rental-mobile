/// An item in the outstanding-debts list.
class OutstandingItem {
  const OutstandingItem({
    required this.id,
    required this.label,
    required this.amount,
    this.rentalId,
    this.fineId,
  });

  final String id;
  final String label;
  final int amount;
  final String? rentalId;
  final String? fineId;

  factory OutstandingItem.fromJson(Map<String, dynamic> json) {
    return OutstandingItem(
      id: (json['id'] ?? '').toString(),
      label: json['label'] as String? ??
          json['description'] as String? ??
          json['reason'] as String? ??
          '',
      amount: (json['amount'] as num? ?? 0).toInt(),
      rentalId: json['rental_id'] as String? ?? json['rentalId'] as String?,
      fineId: json['fine_id'] as String? ?? json['fineId'] as String?,
    );
  }
}

/// Response from GET /mobile/clients/me/outstanding
class OutstandingResponse {
  const OutstandingResponse({
    required this.rentals,
    required this.fines,
    required this.debts,
    required this.total,
  });

  final List<OutstandingItem> rentals;
  final List<OutstandingItem> fines;
  final List<OutstandingItem> debts;
  final int total;

  bool get isEmpty => rentals.isEmpty && fines.isEmpty && debts.isEmpty;

  factory OutstandingResponse.fromJson(Map<String, dynamic> json) {
    List<OutstandingItem> parseList(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(OutstandingItem.fromJson)
          .toList();
    }

    return OutstandingResponse(
      rentals: parseList(json['rentals']),
      fines: parseList(json['fines']),
      debts: parseList(json['debts']),
      total: (json['total'] as num? ?? 0).toInt(),
    );
  }

  static const empty = OutstandingResponse(
    rentals: [],
    fines: [],
    debts: [],
    total: 0,
  );
}
