import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/debt_model.dart';

class DebtNotifier extends StateNotifier<List<DebtModel>> {
  final _db = DBHelper();
  DebtNotifier() : super(const []) {
    _load();
  }
  Future<void> _load() async {
    try {
      state = await _db.getAllDebts();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> refresh() => _load();
  Future<void> addDebt(DebtModel debt) async {
    await _db.insertDebt(debt);
    await _load();
  }

  Future<void> updateDebt(DebtModel debt) async {
    await _db.updateDebt(debt);
    await _load();
  }

  Future<void> deleteDebt(int id) async {
    await _db.deleteDebt(id);
    await _load();
  }

  Future<void> addPayment(int debtId, double amount, String note) async {
    await _db.addDebtPayment(debtId, amount, note);
    await _load();
  }
}

final debtProvider = StateNotifierProvider<DebtNotifier, List<DebtModel>>(
  (ref) => DebtNotifier(),
);
