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
import '../utils/icon_helper.dart';
import '../widgets/fintech_widgets.dart';

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

    final remaining = budget == null ? 0.0 : (budget.limitAmount - spent);
    final isExceeded = remaining < 0;

    final categoryBudgets = budgets
        .where(
          (item) =>
              item.month == _selectedDate.month &&
              item.year == _selectedDate.year &&
              item.categoryId != null,
        )
        .toList();

    return Scaffold(
      backgroundColor: FintechColors.background,
      appBar: AppBar(
        backgroundColor: FintechColors.background,
        elevation: 0,
        title: const Text(
          'Monthly Budget',
          style: TextStyle(
            color: FintechColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              // 1. Month Switcher
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: FintechColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FintechColors.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(
                        () => _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                        ),
                      ),
                      icon: const Icon(Icons.chevron_left_rounded, color: FintechColors.mutedText),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(
                        color: FintechColors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(
                        () => _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                        ),
                      ),
                      icon: const Icon(Icons.chevron_right_rounded, color: FintechColors.mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Main Budget Overview Card
              if (budget != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: FintechColors.cardSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: FintechColors.cardBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isExceeded ? 'Over budget' : 'Remaining budget',
                            style: const TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          InkWell(
                            onTap: () => _showBudgetDialog(null, budget, categories),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text(
                                'Edit Limit',
                                style: TextStyle(
                                  color: FintechColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currency${NumberFormat('#,##0.00').format(remaining.abs())} ${isExceeded ? 'over' : 'left'}',
                        style: TextStyle(
                          color: isExceeded ? FintechColors.expense : FintechColors.primaryText,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFF1F2A27),
                          color: isExceeded || progress >= 0.9
                              ? FintechColors.expense
                              : FintechColors.accent,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$currency${NumberFormat('#,##0').format(spent)} spent',
                            style: const TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}% of $currency${NumberFormat('#,##0').format(budget.limitAmount)}',
                            style: TextStyle(
                              color: isExceeded ? FintechColors.expense : FintechColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FintechColors.cardSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: FintechColors.cardBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 42, color: FintechColors.mutedText),
                      const SizedBox(height: 10),
                      const Text(
                        'No overall limit set for this month',
                        style: TextStyle(color: FintechColors.mutedText, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showBudgetDialog(null, budget, categories),
                        icon: const Icon(Icons.add_rounded, size: 16, color: FintechColors.accent),
                        label: const Text('Set Monthly Limit', style: TextStyle(color: FintechColors.accent, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: FintechColors.accent, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // 3. Category Budgets Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category budgets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: FintechColors.primaryText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showBudgetDialog(null, null, categories),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: FintechColors.accent, size: 20),
                    tooltip: 'Add category budget',
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 4. Category Budget Cards
              if (categoryBudgets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: FintechColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FintechColors.cardBorder, width: 1),
                  ),
                  child: const Center(
                    child: Text(
                      'No category budgets yet. Add limits for Food, Transport, etc.',
                      style: TextStyle(color: FintechColors.mutedText, fontSize: 13),
                      textAlign: TextAlign.center,
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

                  return BudgetCategoryCard(
                    name: category.name,
                    spent: categorySpent,
                    limit: categoryBudget.limitAmount,
                    color: Color(category.colorValue),
                    icon: IconHelper.getIcon(category.iconCode),
                    currency: currency,
                    onEdit: () => _showBudgetDialog(
                      category.id,
                      categoryBudget,
                      categories,
                    ),
                  );
                }),
            ],
          ),

          // Pinned bottom primary action button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: PrimaryBottomButton(
              label: budget == null ? 'Set Monthly Budget' : 'Update Budget',
              icon: Icons.tune_rounded,
              onPressed: () => _showBudgetDialog(null, budget, categories),
            ),
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog(
    int? initialCategoryId,
    BudgetModel? existing,
    List<CategoryModel> categories,
  ) {
    final controller = TextEditingController(
      text: existing != null ? existing.limitAmount.toStringAsFixed(0) : '',
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
              dropdownColor: FintechColors.cardSurface,
              decoration: const InputDecoration(labelText: 'Budget for'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Overall monthly budget', style: TextStyle(color: FintechColors.primaryText)),
                ),
                ...categories.map(
                  (category) => DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name, style: const TextStyle(color: FintechColors.primaryText)),
                  ),
                ),
              ],
              onChanged: (value) => selectedCategoryId = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: FintechColors.primaryText),
              decoration: const InputDecoration(labelText: 'Limit amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: FintechColors.mutedText)),
          ),
          if (existing != null && existing.id != null)
            TextButton(
              onPressed: () {
                ref.read(budgetProvider.notifier).deleteBudget(existing.id!);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete', style: TextStyle(color: FintechColors.expense)),
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
