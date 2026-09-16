import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/transaction_model.dart';
import 'account_provider.dart';

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final DBHelper _dbHelper = DBHelper();
  final Ref? _ref;

  TransactionNotifier([this._ref]) : super([]) {
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final transactions = await _dbHelper.getAllTransactions();
      state = transactions;
    } catch (e) {
      state = [];
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final id = await _dbHelper.insertTransaction(transaction);
      final newTransaction = TransactionModel(
        id: id,
        amount: transaction.amount,
        type: transaction.type,
        categoryId: transaction.categoryId,
        date: transaction.date,
        note: transaction.note,
        paymentMode: transaction.paymentMode,
        isRecurring: transaction.isRecurring,
        accountId: transaction.accountId,
      );
      state = [newTransaction, ...state];
      await _ref?.read(accountProvider.notifier).refresh();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _dbHelper.updateTransaction(transaction);
      state = [
        for (final t in state)
          if (t.id == transaction.id) transaction else t,
      ];
      await _ref?.read(accountProvider.notifier).refresh();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      state = state.where((t) => t.id != id).toList();
      await _ref?.read(accountProvider.notifier).refresh();
    } catch (e) {
      // Handle error
    }
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
      return TransactionNotifier(ref);
    });
