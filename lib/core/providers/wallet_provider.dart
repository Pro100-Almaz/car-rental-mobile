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
  // TODO(M5): wire to GET /mobile/clients/me for balance, transactions, payment methods
  WalletNotifier() : super(WalletState.initial());
}

class WalletState {
  const WalletState({
    required this.balance,
    required this.transactions,
    required this.paymentMethods,
    required this.outstandingDebt,
  });

  final int balance;
  final List<Transaction> transactions;
  final List<PaymentMethod> paymentMethods;
  final int outstandingDebt;

  // TODO(M5): populate from GET /mobile/clients/me — empty defaults until then
  factory WalletState.initial() => const WalletState(
    balance: 0,
    outstandingDebt: 0,
    transactions: [],
    paymentMethods: [],
  );

  WalletState copyWith({
    int? balance,
    List<Transaction>? transactions,
    List<PaymentMethod>? paymentMethods,
    int? outstandingDebt,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      outstandingDebt: outstandingDebt ?? this.outstandingDebt,
    );
  }
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((_) => WalletNotifier());
