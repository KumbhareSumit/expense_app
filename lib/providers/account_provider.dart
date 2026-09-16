import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/account_model.dart';

class AccountState {
  final List<AccountModel> accounts;
  final Map<int, double> balances;
  const AccountState({this.accounts = const [], this.balances = const {}});
}

class AccountNotifier extends StateNotifier<AccountState> {
  final _db = DBHelper();
  AccountNotifier() : super(const AccountState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = AccountState(
        accounts: await _db.getAllAccounts(),
        balances: await _db.getAccountBalances(),
      );
    } catch (_) {
      state = const AccountState();
    }
  }

  Future<void> refresh() => _load();
  Future<void> addAccount(AccountModel account) async {
    await _db.insertAccount(account);
    await _load();
  }

  Future<void> updateAccount(AccountModel account) async {
    await _db.updateAccount(account);
    await _load();
  }

  Future<void> deleteAccount(int id) async {
    await _db.deleteAccount(id);
    await _load();
  }

  Future<void> transfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    await _db.insertTransfer({
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    });
    await _load();
  }
}

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>(
  (ref) => AccountNotifier(),
);
