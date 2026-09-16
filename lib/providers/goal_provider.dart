import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/goal_model.dart';

class GoalNotifier extends StateNotifier<List<GoalModel>> {
  final _db = DBHelper();
  GoalNotifier() : super(const []) {
    _load();
  }
  Future<void> _load() async {
    try {
      state = await _db.getAllGoals();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> refresh() => _load();
  Future<void> addGoal(GoalModel goal) async {
    await _db.insertGoal(goal);
    await _load();
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _db.updateGoal(goal);
    await _load();
  }

  Future<void> deleteGoal(int id) async {
    await _db.deleteGoal(id);
    await _load();
  }

  Future<void> addContribution(int goalId, double amount, String note) async {
    await _db.addGoalContribution(goalId, amount, note);
    await _load();
  }
}

final goalProvider = StateNotifierProvider<GoalNotifier, List<GoalModel>>(
  (ref) => GoalNotifier(),
);
