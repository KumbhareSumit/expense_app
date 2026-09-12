import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../utils/icon_helper.dart';
import '../utils/app_theme.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'Monthly';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.currencySymbol;
    final moneyColors = context.moneyColors;

    final filteredTransactions = _filterTransactions(
      transactions,
      _selectedPeriod,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in filteredTransactions) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }
    final balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings (not requested but good to have)
            },
          ),
        ],
      ),
      body: transactions.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(balance, currency),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Income',
                            totalIncome,
                            currency,
                            moneyColors.income,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Expense',
                            totalExpense,
                            currency,
                            moneyColors.expense,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),
                    Text(
                      'Spending Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: _buildChart(filteredTransactions),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionList(
                      filteredTransactions,
                      categories,
                      currency,
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
    String period,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return transactions.where((t) {
      final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);

      if (period == 'Daily') {
        return transactionDate.isAtSameMomentAs(today);
      } else if (period == 'Weekly') {
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return t.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
      } else if (period == 'Monthly') {
        return t.date.year == now.year && t.date.month == now.month;
      } else if (period == 'Yearly') {
        return t.date.year == now.year;
      }
      return true;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: context.moneyColors.muted.withValues(alpha: .55),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(fontSize: 18, color: context.moneyColors.muted),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => _showAddTransaction(context),
            child: const Text('Add your first transaction'),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance, String currency) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary,
              Color.lerp(scheme.primary, scheme.primaryContainer, .28)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: scheme.onPrimary.withValues(alpha: .82),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currency ${balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    String currency,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$currency ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(List<TransactionModel> filteredTransactions) {
    // Basic implementation of trend chart
    // For simplicity, we'll group by day if weekly/monthly, by month if yearly
    Map<int, double> data = {};

    if (_selectedPeriod == 'Yearly') {
      for (var t in filteredTransactions) {
        if (t.type == 'expense') {
          data[t.date.month] = (data[t.date.month] ?? 0) + t.amount;
        }
      }
    } else {
      for (var t in filteredTransactions) {
        if (t.type == 'expense') {
          data[t.date.day] = (data[t.date.day] ?? 0) + t.amount;
        }
      }
    }

    List<BarChartGroupData> barGroups = [];
    final sortedKeys = data.keys.toList()..sort();

    for (int i = 0; i < sortedKeys.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: sortedKeys[i],
          barRods: [
            BarChartRodData(
              toY: data[sortedKeys[i]]!,
              color: Theme.of(context).colorScheme.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    if (barGroups.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Not enough data for chart')),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.values.isEmpty
              ? 100
              : data.values.reduce((a, b) => a > b ? a : b) * 1.2,
          barGroups: barGroups,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    String currency,
  ) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions in this period'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5
          ? 5
          : transactions.length, // Show only recent 5
      itemBuilder: (context, index) {
        final t = transactions[index];
        final category = categories
            .where((c) => c.id == t.categoryId)
            .firstOrNull;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: category != null
                ? Color(category.colorValue).withOpacity(0.2)
                : Colors.grey[200],
            child: Icon(
              category != null
                  ? IconHelper.getIcon(category.iconCode)
                  : Icons.category,
              color: category != null
                  ? Color(category.colorValue)
                  : Colors.grey,
            ),
          ),
          title: Text(category?.name ?? 'Unknown'),
          subtitle: Text(DateFormat('MMM dd, yyyy').format(t.date)),
          trailing: Text(
            '${t.type == 'income' ? '+' : '-'} $currency ${t.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: t.type == 'income'
                  ? context.moneyColors.income
                  : context.moneyColors.expense,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionScreen(),
    );
  }
}
