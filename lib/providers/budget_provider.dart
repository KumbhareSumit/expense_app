import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/db_helper.dart';
import '../models/budget_model.dart';

class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  final DBHelper _dbHelper = DBHelper();

  BudgetNotifier() : super([]) {
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    final budgets = await _dbHelper.getAllBudgets();
    state = budgets;
  }

  Future<void> addBudget(BudgetModel budget) async {
    final id = await _dbHelper.insertBudget(budget);
    final newBudget = BudgetModel(
      id: id,
      month: budget.month,
      year: budget.year,
      categoryId: budget.categoryId,
      limitAmount: budget.limitAmount,
    );
    state = [...state, newBudget];
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await _dbHelper.updateBudget(budget);
    state = [
      for (final b in state)
        if (b.id == budget.id) budget else b
    ];
  }

  Future<void> deleteBudget(int id) async {
    await _dbHelper.deleteBudget(id);
    state = state.where((b) => b.id != id).toList();
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<BudgetModel>>((ref) {
  return BudgetNotifier();
});
