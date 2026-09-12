import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_theme.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetProvider);
    final categories = ref
        .watch(categoryProvider)
        .where((category) => category.type == 'expense')
        .toList();
    final transactions = ref.watch(transactionProvider);
    final currency = ref.watch(settingsProvider).currencySymbol;
    final moneyColors = context.moneyColors;
    final matchingBudgets = budgets.where(
      (item) =>
          item.month == _selectedDate.month &&
          item.year == _selectedDate.year &&
          item.categoryId == null,
    );
    final budget = matchingBudgets.isEmpty ? null : matchingBudgets.first;
    final spent = transactions
        .where(
          (item) =>
              item.type == 'expense' &&
              item.date.month == _selectedDate.month &&
              item.date.year == _selectedDate.year,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
    final progress = budget == null || budget.limitAmount <= 0
        ? 0.0
        : spent / budget.limitAmount;
    final color = progress >= 1
        ? moneyColors.expense
        : progress >= .8
        ? moneyColors.warning
        : moneyColors.income;
    final categoryBudgets = budgets
        .where(
          (item) =>
              item.month == _selectedDate.month &&
              item.year == _selectedDate.year &&
              item.categoryId != null,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budget')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(
                  () => _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month - 1,
                  ),
                ),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => setState(
                  () => _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month + 1,
                  ),
                ),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          if (budget != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '$currency${budget.limitAmount.toStringAsFixed(2)} limit',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$currency${spent.toStringAsFixed(2)} spent',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedProgress, child) =>
                          LinearProgressIndicator(
                            value: animatedProgress,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _usageLabel(progress),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Category budgets',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          if (categoryBudgets.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No category budgets yet. Add limits for Food, Transport, Shopping, and more.',
                ),
              ),
            )
          else
            ...categoryBudgets.map((categoryBudget) {
              final category = categories
                  .where((item) => item.id == categoryBudget.categoryId)
                  .firstOrNull;
              if (category == null) return const SizedBox.shrink();
              final categorySpent = transactions
                  .where(
                    (item) =>
                        item.type == 'expense' &&
                        item.categoryId == category.id &&
                        item.date.month == _selectedDate.month &&
                        item.date.year == _selectedDate.year,
                  )
                  .fold<double>(0, (sum, item) => sum + item.amount);
              return _buildCategoryBudgetCard(
                categoryBudget,
                category,
                categorySpent,
                currency,
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBudgetDialog(null, budget, categories),
        icon: const Icon(Icons.edit),
        label: Text(budget == null ? 'Set budget' : 'Update budget'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
      ),
    );
  }

  Widget _buildCategoryBudgetCard(
    BudgetModel budget,
    CategoryModel category,
    double spent,
    String currency,
  ) {
    final progress = budget.limitAmount <= 0 ? 0.0 : spent / budget.limitAmount;
    final color = progress >= 1
        ? context.moneyColors.expense
        : progress >= .8
        ? context.moneyColors.warning
        : context.moneyColors.income;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(category.colorValue)
                      .withValues(alpha: .15),
                  child: Icon(
                    IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                    color: Color(category.colorValue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Edit budget',
                  onPressed: () => _showBudgetDialog(
                    category.id,
                    budget,
                    ref
                        .read(categoryProvider)
                        .where((item) => item.type == 'expense')
                        .toList(),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete budget',
                  onPressed: () => ref
                      .read(budgetProvider.notifier)
                      .deleteBudget(budget.id!),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$currency${spent.toStringAsFixed(2)} spent of $currency${budget.limitAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0, 1), color: color),
            const SizedBox(height: 6),
            Text(_usageLabel(progress), style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  String _usageLabel(double progress) {
    if (progress >= 1) return 'Over budget';
    return '${(progress * 100).toStringAsFixed(0)}% used';
  }

  void _showBudgetDialog(
    int? initialCategoryId,
    BudgetModel? existing,
    List<CategoryModel> categories,
  ) {
    final controller = TextEditingController(
      text: existing?.limitAmount.toString() ?? '',
    );
    var selectedCategoryId = existing?.categoryId ?? initialCategoryId;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          existing == null ? 'Set monthly budget' : 'Update monthly budget',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int?>(
              initialValue: selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Budget for'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Overall monthly budget'),
                ),
                ...categories.map(
                  (category) => DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
              ],
              onChanged: (value) => selectedCategoryId = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Limit amount'),
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
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              final model = BudgetModel(
                id: existing?.id,
                month: _selectedDate.month,
                year: _selectedDate.year,
                categoryId: selectedCategoryId,
                limitAmount: amount,
              );
              if (existing == null) {
                ref.read(budgetProvider.notifier).addBudget(model);
              } else {
                ref.read(budgetProvider.notifier).updateBudget(model);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
