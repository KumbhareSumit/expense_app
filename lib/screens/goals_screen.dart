import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final currency = ref.watch(settingsProvider).currencySymbol;
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: goals.isEmpty
          ? const Center(child: Text('No savings goals yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: goals
                  .map((goal) => _goalCard(context, ref, goal, currency))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
      ),
    );
  }

  Widget _goalCard(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    String currency,
  ) {
    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showContributionDialog(context, ref, goal, currency),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(goal.colorValue)
                        .withValues(alpha: .15),
                    child: Icon(
                      IconData(goal.iconCode, fontFamily: 'MaterialIcons'),
                      color: Color(goal.colorValue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (goal.isCompleted)
                    Icon(Icons.check_circle, color: context.moneyColors.income),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                color: goal.isCompleted
                    ? context.moneyColors.income
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                '$currency${goal.currentAmount.toStringAsFixed(2)} of $currency${goal.targetAmount.toStringAsFixed(2)}',
              ),
              if (goal.deadline != null)
                Text(
                  _deadlineLabel(goal.deadline!),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _deadlineLabel(DateTime deadline) {
    final days = deadline.difference(DateTime.now()).inDays;
    return days < 0 ? 'Deadline passed' : '$days days remaining';
  }

  void _showGoalDialog(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final target = TextEditingController();
    DateTime? deadline;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New savings goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Goal name'),
              ),
              TextField(
                controller: target,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Target amount'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => deadline = picked);
                },
                icon: const Icon(Icons.event),
                label: Text(
                  deadline == null
                      ? 'Optional deadline'
                      : '${deadline!.day}/${deadline!.month}/${deadline!.year}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(target.text);
                if (name.text.trim().isEmpty || amount == null || amount <= 0)
                  return;
                ref
                    .read(goalProvider.notifier)
                    .addGoal(
                      GoalModel(
                        name: name.text.trim(),
                        targetAmount: amount,
                        currentAmount: 0,
                        deadline: deadline,
                        colorValue: Colors.teal.value,
                        iconCode: Icons.flag.codePoint,
                      ),
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showContributionDialog(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    String currency,
  ) {
    final amount = TextEditingController();
    final note = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add money to ${goal.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$currency ',
              ),
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(amount.text);
              if (value == null || value <= 0) return;
              ref
                  .read(goalProvider.notifier)
                  .addContribution(goal.id!, value, note.text.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
