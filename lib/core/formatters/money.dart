import 'package:intl/intl.dart';

/// Formats a KZT amount (int or double — backend returns decimal strings).
///
/// [symbol] = true  →  "₸ 24,000"
/// [symbol] = false →  "24,000"
String formatKzt(num amount, {bool symbol = true}) {
  final formatted = NumberFormat('#,###', 'en_US').format(amount.truncate());
  return symbol ? '₸ $formatted' : formatted;
}
