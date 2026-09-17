import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/app_theme.dart';
import 'add_transaction_screen.dart';

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

    final now = DateTime.now();
    int daysElapsed = 1;
    switch (_selectedPeriod) {
      case AnalysisPeriod.daily:
        daysElapsed = 1;
        break;
      case AnalysisPeriod.weekly:
        daysElapsed = now.weekday;
        break;
      case AnalysisPeriod.monthly:
        daysElapsed = now.day;
        break;
      case AnalysisPeriod.yearly:
        daysElapsed = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
        break;
    }
    
    final dailyAverage = totalExpense / daysElapsed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildPeriodSelector(),
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
                    dailyAverage,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Expense Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfographicChart(
                    filteredTransactions.where((t) => t.type == 'expense').toList(),
                    categories,
                    settings.currencySymbol,
                    totalExpense,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTransactionList(
                    filteredTransactions,
                    categories,
                    settings.currencySymbol,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      (AnalysisPeriod.daily, 'Daily'),
      (AnalysisPeriod.weekly, 'Weekly'),
      (AnalysisPeriod.monthly, 'Monthly'),
      (AnalysisPeriod.yearly, 'Yearly'),
    ];
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period.$1;
          final index = periods.indexOf(period);

          return Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected ? scheme.primaryContainer : scheme.surface,
                border: index == 0
                    ? null
                    : Border(left: BorderSide(color: scheme.outline)),
              ),
              child: Semantics(
                button: true,
                selected: isSelected,
                label: period.$2,
                child: InkWell(
                  onTap: () => setState(() => _selectedPeriod = period.$1),
                  child: Center(
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          period.$2,
                          style: const TextStyle(height: 1.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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

  Widget _buildInfographicChart(
    List<TransactionModel> expenses,
    List<CategoryModel> categories,
    String currency,
    double totalExpense,
  ) {
    if (expenses.isEmpty || totalExpense <= 0) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No expenses to breakdown')),
      );
    }

    Map<int, double> categoryTotals = {};
    for (var t in expenses) {
      categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<PieChartSectionData> sections = [];
    for (var entry in sortedEntries) {
      final cat = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => CategoryModel(name: 'Unknown', type: 'expense', colorValue: Colors.grey.value, iconCode: Icons.help.codePoint, isCustom: false),
      );
      sections.add(
        PieChartSectionData(
          value: entry.value,
          color: Color(cat.colorValue),
          radius: 20,
          showTitle: false,
        ),
      );
    }

    List<Widget> stackChildren = [];

    // Central Donut
    stackChildren.add(
      Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 140,
          width: 140,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 3,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$currency${totalExpense.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Satellites
    final leftItems = <MapEntry<int, double>>[];
    final rightItems = <MapEntry<int, double>>[];
    for (int i = 0; i < (sortedEntries.length > 6 ? 6 : sortedEntries.length); i++) {
      if (i % 2 == 0) leftItems.add(sortedEntries[i]);
      else rightItems.add(sortedEntries[i]);
    }

    Alignment getAlignment(int count, int index, bool isLeft) {
      final x = isLeft ? -0.95 : 0.95;
      if (count == 1) return Alignment(x, 0.0);
      if (count == 2) return Alignment(x, index == 0 ? -0.6 : 0.6);
      return Alignment(x, index == 0 ? -0.85 : (index == 1 ? 0.0 : 0.85));
    }

    void buildSatellites(List<MapEntry<int, double>> items, bool isLeft) {
      for (int i = 0; i < items.length; i++) {
        final entry = items[i];
        final cat = categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => CategoryModel(name: 'Unknown', type: 'expense', colorValue: Colors.grey.value, iconCode: Icons.help.codePoint, isCustom: false),
        );
        final percent = entry.value / totalExpense;

        stackChildren.add(
          Align(
            alignment: getAlignment(items.length, i, isLeft),
            child: SizedBox(
              width: 80, // Constrain width for tight mobile layout
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniDonut(percent, Color(cat.colorValue)),
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '$currency${entry.value.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    buildSatellites(leftItems, true);
    buildSatellites(rightItems, false);

    return Container(
      height: 340,
      width: double.infinity,
      child: CustomPaint(
        painter: _InfographicLinesPainter(
          leftCount: leftItems.length,
          rightCount: rightItems.length,
          lineColor: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }

  Widget _buildMiniDonut(double percent, Color color) {
    return SizedBox(
      width: 40, // Smaller satellite donuts
      height: 40,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent,
            strokeWidth: 5, // Thinner stroke
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    String currency,
    double savings,
    double dailyAverage,
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
                    'Daily Average',
                    style: TextStyle(color: moneyColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${dailyAverage.toStringAsFixed(2)} / day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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
    return const SizedBox.shrink(); // Disabled because we use _buildInfographicChart now
  }

  Widget _buildTransactionList(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    String currency,
  ) {
    return Column(
      children: transactions.map((transaction) {
        final category = categories.firstWhere(
          (item) => item.id == transaction.categoryId,
          orElse: () => CategoryModel(
            name: 'Unknown',
            iconCode: Icons.help.codePoint,
            colorValue: Colors.grey.value,
            type: transaction.type,
            isCustom: false,
          ),
        );

        return ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => _editTransaction(transaction),
          leading: CircleAvatar(
            backgroundColor: Color(category.colorValue).withValues(alpha: .15),
            child: Icon(Icons.category, color: Color(category.colorValue)),
          ),
          title: Text(category.name),
          subtitle: Text(DateFormat('MMM dd, yyyy').format(transaction.date)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${transaction.type == 'income' ? '+' : '-'}$currency${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.type == 'income'
                      ? context.moneyColors.income
                      : context.moneyColors.expense,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Transaction actions',
                onSelected: (action) {
                  if (action == 'edit') {
                    _editTransaction(transaction);
                  } else {
                    _confirmDeleteTransaction(transaction);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _editTransaction(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionScreen(transaction: transaction),
    );
  }

  Future<void> _confirmDeleteTransaction(TransactionModel transaction) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && transaction.id != null) {
      await ref
          .read(transactionProvider.notifier)
          .deleteTransaction(transaction.id!);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      }
    }
  }
}

class _InfographicLinesPainter extends CustomPainter {
  final int leftCount;
  final int rightCount;
  final Color lineColor;

  _InfographicLinesPainter({
    required this.leftCount,
    required this.rightCount,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 65.0; // Starts line at the outer edge of the main donut

    double getAlignY(int count, int index) {
      if (count == 1) return 0.0;
      if (count == 2) return index == 0 ? -0.6 : 0.6;
      return index == 0 ? -0.85 : (index == 1 ? 0.0 : 0.85);
    }

    void drawLines(int count, bool isLeft) {
      final targetX = isLeft ? size.width * 0.15 : size.width * 0.85;
      final midX = isLeft ? size.width * 0.32 : size.width * 0.68;
      
      for (int i = 0; i < count; i++) {
        final alignY = getAlignY(count, i);
        final y = center.dy + (size.height / 2) * alignY;
        
        final deltaY = y - center.dy;
        final deltaX = midX - center.dx;
        final angle = math.atan2(deltaY, deltaX);
        
        final startX = center.dx + radius * math.cos(angle);
        final startY = center.dy + radius * math.sin(angle);
        
        final path = Path();
        path.moveTo(startX, startY);
        path.lineTo(midX, y); // Diagonal part
        path.lineTo(targetX, y); // Horizontal part pointing to satellite
        
        canvas.drawPath(path, paint);
      }
    }
    
    drawLines(leftCount, true);
    drawLines(rightCount, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

