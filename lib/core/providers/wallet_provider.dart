import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isDebit,
    required this.date,
  });
  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final bool isDebit;
  final DateTime date;
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isDefault = false,
  });
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDefault;
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(WalletState.initial());

  void topUp(int amount) {
    state = state.copyWith(
      balance: state.balance + amount,
      transactions: [
        Transaction(
          id: 't${DateTime.now().millisecondsSinceEpoch}',
          title: 'Top Up',
          subtitle: _formatDate(DateTime.now()),
          amount: amount,
          isDebit: false,
          date: DateTime.now(),
        ),
        ...state.transactions,
      ],
    );
  }

  void addPaymentMethod(PaymentMethod method) {
    state = state.copyWith(
      paymentMethods: [...state.paymentMethods, method],
    );
  }

  void setDefaultPaymentMethod(String id) {
    state = state.copyWith(
      paymentMethods: state.paymentMethods.map((m) {
        return PaymentMethod(
          id: m.id,
          type: m.type,
          title: m.title,
          subtitle: m.subtitle,
          icon: m.icon,
          isDefault: m.id == id,
        );
      }).toList(),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class WalletState {
  const WalletState({
    required this.balance,
    required this.transactions,
    required this.paymentMethods,
  });

  final int balance;
  final List<Transaction> transactions;
  final List<PaymentMethod> paymentMethods;

  factory WalletState.initial() => WalletState(
    balance: 15000,
    transactions: [
      Transaction(
        id: 't1',
        title: 'Toyota Camry',
        subtitle: '12 – 15 Oct',
        amount: 24000,
        isDebit: true,
        date: DateTime(2024, 10, 15),
      ),
      Transaction(
        id: 't2',
        title: 'Top Up',
        subtitle: '10 Oct',
        amount: 30000,
        isDebit: false,
        date: DateTime(2024, 10, 10),
      ),
      Transaction(
        id: 't3',
        title: 'Deposit Refund',
        subtitle: '8 Oct',
        amount: 10000,
        isDebit: false,
        date: DateTime(2024, 10, 8),
      ),
    ],
    paymentMethods: [
      PaymentMethod(
        id: 'pm1',
        type: 'kaspi',
        title: 'Kaspi Pay',
        subtitle: '•••• 4821',
        icon: Icons.account_balance_wallet_rounded,
        isDefault: true,
      ),
      PaymentMethod(
        id: 'pm2',
        type: 'card',
        title: 'Bank Card',
        subtitle: 'Visa •••• 3156',
        icon: Icons.credit_card_rounded,
        isDefault: false,
      ),
    ],
  );

  WalletState copyWith({
    int? balance,
    List<Transaction>? transactions,
    List<PaymentMethod>? paymentMethods,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((_) => WalletNotifier());
