import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/app_theme.dart';

enum AnalysisPeriod { daily, weekly, monthly, yearly }

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  AnalysisPeriod _selectedPeriod = AnalysisPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider);
    final settings = ref.watch(settingsProvider);

    final filteredTransactions = _filterTransactions(transactions);
    final categoryData = _calculateCategoryData(
      filteredTransactions,
      categories,
    );

    final totalIncome = filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final savings = totalIncome - totalExpense;

    final highestCategory = categoryData.isEmpty
        ? null
        : categoryData.entries
              .reduce((a, b) => a.value.amount > b.value.amount ? a : b)
              .value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SegmentedButton<AnalysisPeriod>(
              segments: const [
                ButtonSegment(
                  value: AnalysisPeriod.daily,
                  label: Text('Daily'),
                ),
                ButtonSegment(
                  value: AnalysisPeriod.weekly,
                  label: Text('Weekly'),
                ),
                ButtonSegment(
                  value: AnalysisPeriod.monthly,
                  label: Text('Monthly'),
                ),
                ButtonSegment(
                  value: AnalysisPeriod.yearly,
                  label: Text('Yearly'),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedPeriod = newSelection.first;
                });
              },
            ),
          ),
        ),
      ),
      body: filteredTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insights_outlined,
                    size: 72,
                    color: context.moneyColors.muted.withValues(alpha: .55),
                  ),
                  const SizedBox(height: 16),
                  const Text('No transactions for this period'),
                  const SizedBox(height: 8),
                  Text(
                    'Add transactions to see your spending insights.',
                    style: TextStyle(color: context.moneyColors.muted),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryCards(
                    settings.currencySymbol,
                    savings,
                    highestCategory,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Expense Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: PieChart(
                      PieChartData(
                        sections: _buildChartSections(
                          categoryData,
                          totalExpense,
                        ),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLegend(
                    categoryData,
                    totalExpense,
                    settings.currencySymbol,
                  ),
                ],
              ),
            ),
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    return transactions.where((t) {
      switch (_selectedPeriod) {
        case AnalysisPeriod.daily:
          return t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day;
        case AnalysisPeriod.weekly:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return t.date.isAfter(
            startOfWeek.subtract(const Duration(seconds: 1)),
          );
        case AnalysisPeriod.monthly:
          return t.date.year == now.year && t.date.month == now.month;
        case AnalysisPeriod.yearly:
          return t.date.year == now.year;
      }
    }).toList();
  }

  Map<int, _CategorySummary> _calculateCategoryData(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
  ) {
    final expenseTransactions = transactions.where((t) => t.type == 'expense');
    final Map<int, _CategorySummary> data = {};

    for (var t in expenseTransactions) {
      final category = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => CategoryModel(
          name: 'Unknown',
          iconCode: Icons.help.codePoint,
          colorValue: Colors.grey.value,
          type: 'expense',
        ),
      );

      if (data.containsKey(t.categoryId)) {
        data[t.categoryId]!.amount += t.amount;
      } else {
        data[t.categoryId] = _CategorySummary(
          name: category.name,
          color: Color(category.colorValue),
          amount: t.amount,
        );
      }
    }
    return data;
  }

  List<PieChartSectionData> _buildChartSections(
    Map<int, _CategorySummary> data,
    double totalExpense,
  ) {
    return data.entries.map((entry) {
      final percentage = (entry.value.amount / totalExpense) * 100;
      return PieChartSectionData(
        color: entry.value.color,
        value: entry.value.amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: entry.value.color.computeLuminance() > .5
              ? Colors.black87
              : Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildSummaryCards(
    String currency,
    double savings,
    _CategorySummary? highest,
  ) {
    final moneyColors = context.moneyColors;
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Total Savings',
                    style: TextStyle(color: moneyColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${savings.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: savings >= 0
                          ? moneyColors.income
                          : moneyColors.expense,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Top Category',
                    style: TextStyle(color: moneyColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    highest?.name ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(
    Map<int, _CategorySummary> data,
    double totalExpense,
    String currency,
  ) {
    final sortedList = data.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Column(
      children: sortedList.map((summary) {
        final percentage = (summary.amount / totalExpense) * 100;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: summary.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(summary.name)),
              Text(
                '$currency${summary.amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategorySummary {
  final String name;
  final Color color;
  double amount;

  _CategorySummary({
    required this.name,
    required this.color,
    required this.amount,
  });
}
