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
import '../utils/icon_helper.dart';
import '../widgets/fintech_widgets.dart';
import 'add_transaction_screen.dart';

enum AnalysisPeriod { daily, weekly, monthly, yearly }

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  AnalysisPeriod _selectedPeriod = AnalysisPeriod.monthly;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider);
    final settings = ref.watch(settingsProvider);

    final filteredTransactions = _filterTransactions(transactions);

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
        daysElapsed = 7;
        break;
      case AnalysisPeriod.monthly:
        final isCurrentMonth = _selectedDate.year == now.year && _selectedDate.month == now.month;
        daysElapsed = isCurrentMonth ? now.day : DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
        break;
      case AnalysisPeriod.yearly:
        final isCurrentYear = _selectedDate.year == now.year;
        daysElapsed = isCurrentYear ? (now.difference(DateTime(now.year, 1, 1)).inDays + 1) : 365;
        break;
    }
    
    final dailyAverage = totalExpense / (daysElapsed > 0 ? daysElapsed : 1);
    final fintech = context.fintech;

    return Scaffold(
      backgroundColor: fintech.background,
      appBar: AppBar(
        backgroundColor: fintech.background,
        elevation: 0,
        title: Text(
          'Analysis',
          style: TextStyle(
            color: fintech.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Period Selector Segmented Bar & Date Navigator
            _buildPeriodSelector(),
            _buildDateNavigator(),
            const SizedBox(height: 16),

            // 2. Summary Stats Cards Row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total savings',
                    amount: savings,
                    color: savings >= 0 ? fintech.income : fintech.expense,
                    currency: settings.currencySymbol,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Daily average',
                    amount: dailyAverage,
                    color: fintech.primaryText,
                    currency: settings.currencySymbol,
                    subtitle: '/ day',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Expense Breakdown Header
            Text(
              'Expense Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: fintech.primaryText,
              ),
            ),
            const SizedBox(height: 14),

            // 4. Preserved Circular Infographic Chart in Fintech Container
            _buildInfographicChart(
              filteredTransactions.where((t) => t.type == 'expense').toList(),
              categories,
              settings.currencySymbol,
              totalExpense,
            ),
            const SizedBox(height: 24),

            // 5. Transactions Section
            Text(
              'Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: fintech.primaryText,
              ),
            ),
            const SizedBox(height: 12),

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
    final fintech = context.fintech;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final periods = [
      (AnalysisPeriod.daily, 'Daily'),
      (AnalysisPeriod.weekly, 'Weekly'),
      (AnalysisPeriod.monthly, 'Monthly'),
      (AnalysisPeriod.yearly, 'Yearly'),
    ];

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period.$1;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _selectedPeriod = period.$1;
                _selectedDate = DateTime.now();
              }),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF12382F) : fintech.accent.withValues(alpha: 0.15))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  period.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? fintech.accent : fintech.mutedText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateNavigator() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    String label = '';
    switch (_selectedPeriod) {
      case AnalysisPeriod.daily:
        if (target.isAtSameMomentAs(today)) {
          label = 'Today, ${DateFormat('d MMM yyyy').format(_selectedDate)}';
        } else if (target.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
          label = 'Yesterday, ${DateFormat('d MMM yyyy').format(_selectedDate)}';
        } else {
          label = DateFormat('EEE, d MMM yyyy').format(_selectedDate);
        }
        break;
      case AnalysisPeriod.weekly:
        final startOfWeek = target.subtract(Duration(days: target.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final isCurrentWeek = !today.isBefore(startOfWeek) && !today.isAfter(endOfWeek);
        if (isCurrentWeek) {
          final rolling7Start = today.subtract(const Duration(days: 6));
          label = 'Past 7 Days (${DateFormat('d MMM').format(rolling7Start)} - ${DateFormat('d MMM').format(today)})';
        } else {
          label = '${DateFormat('d MMM').format(startOfWeek)} - ${DateFormat('d MMM yyyy').format(endOfWeek)}';
        }
        break;
      case AnalysisPeriod.monthly:
        label = DateFormat('MMMM yyyy').format(_selectedDate);
        break;
      case AnalysisPeriod.yearly:
        label = DateFormat('yyyy').format(_selectedDate);
        break;
    }

    final fintech = context.fintech;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, size: 22, color: fintech.mutedText),
            onPressed: () => _navigatePeriod(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 32),
            splashRadius: 18,
          ),
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 13, color: fintech.accent),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: fintech.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, size: 22, color: fintech.mutedText),
            onPressed: () => _navigatePeriod(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 32),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  void _navigatePeriod(int direction) {
    setState(() {
      switch (_selectedPeriod) {
        case AnalysisPeriod.daily:
          _selectedDate = _selectedDate.add(Duration(days: direction));
          break;
        case AnalysisPeriod.weekly:
          _selectedDate = _selectedDate.add(Duration(days: direction * 7));
          break;
        case AnalysisPeriod.monthly:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + direction,
            _selectedDate.day.clamp(1, 28),
          );
          break;
        case AnalysisPeriod.yearly:
          _selectedDate = DateTime(
            _selectedDate.year + direction,
            _selectedDate.month,
            _selectedDate.day.clamp(1, 28),
          );
          break;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    final target = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return transactions.where((t) {
      final localDate = t.date.toLocal();
      final tDate = DateTime(localDate.year, localDate.month, localDate.day);

      switch (_selectedPeriod) {
        case AnalysisPeriod.daily:
          return tDate.year == target.year &&
              tDate.month == target.month &&
              tDate.day == target.day;
        case AnalysisPeriod.weekly:
          final startOfWeek = target.subtract(Duration(days: target.weekday - 1));
          final endOfWeek = DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day + 6,
            23, 59, 59, 999,
          );
          final isCurrentWeek = !today.isBefore(startOfWeek) && !today.isAfter(endOfWeek);
          final rolling7Start = today.subtract(const Duration(days: 6));
          final effectiveStart = (isCurrentWeek && rolling7Start.isBefore(startOfWeek))
            ? rolling7Start
            : startOfWeek;

          return !localDate.isBefore(effectiveStart) && !localDate.isAfter(endOfWeek);
        case AnalysisPeriod.monthly:
          return localDate.year == _selectedDate.year &&
              localDate.month == _selectedDate.month;
        case AnalysisPeriod.yearly:
          return localDate.year == _selectedDate.year;
      }
    }).toList();
  }

  Widget _buildInfographicChart(
    List<TransactionModel> expenses,
    List<CategoryModel> categories,
    String currency,
    double totalExpense,
  ) {
    final fintech = context.fintech;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (expenses.isEmpty || totalExpense <= 0) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: fintech.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fintech.cardBorder, width: 1),
        ),
        child: Center(
          child: Text(
            'No expenses in this period',
            style: TextStyle(color: fintech.mutedText, fontSize: 13),
          ),
        ),
      );
    }

    final Map<int, double> categoryTotals = {};
    for (var t in expenses) {
      categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<PieChartSectionData> sections = [];
    for (var entry in sortedEntries) {
      final cat = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => CategoryModel(
          name: 'Unknown',
          type: 'expense',
          colorValue: Colors.grey.toARGB32(),
          iconCode: Icons.help.codePoint,
          isCustom: false,
        ),
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

    final List<Widget> stackChildren = [];

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
                        fontSize: 11,
                        color: fintech.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$currency${NumberFormat('#,##0').format(totalExpense)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: fintech.primaryText,
                        fontFeatures: const [FontFeature.tabularFigures()],
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
      if (i % 2 == 0) {
        leftItems.add(sortedEntries[i]);
      } else {
        rightItems.add(sortedEntries[i]);
      }
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
          orElse: () => CategoryModel(
            name: 'Unknown',
            type: 'expense',
            colorValue: Colors.grey.toARGB32(),
            iconCode: Icons.help.codePoint,
            isCustom: false,
          ),
        );
        final percent = entry.value / totalExpense;

        stackChildren.add(
          Align(
            alignment: getAlignment(items.length, i, isLeft),
            child: SizedBox(
              width: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniDonut(percent, Color(cat.colorValue)),
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: fintech.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '$currency${NumberFormat('#,##0').format(entry.value)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: fintech.mutedText,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: CustomPaint(
        painter: _InfographicLinesPainter(
          leftCount: leftItems.length,
          rightCount: rightItems.length,
          lineColor: isDark ? const Color(0xFF263531) : fintech.cardBorder,
        ),
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }

  Widget _buildMiniDonut(double percent, Color color) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent,
            strokeWidth: 4,
            backgroundColor: color.withValues(alpha: 0.16),
            color: color,
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    String currency,
  ) {
    final fintech = context.fintech;

    if (transactions.isEmpty) {
      final periodName = switch (_selectedPeriod) {
        AnalysisPeriod.daily => 'day',
        AnalysisPeriod.weekly => 'week',
        AnalysisPeriod.monthly => 'month',
        AnalysisPeriod.yearly => 'year',
      };
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: fintech.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fintech.cardBorder, width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 36, color: fintech.mutedText),
            const SizedBox(height: 8),
            Text(
              'No transactions for this $periodName',
              style: TextStyle(
                color: fintech.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedPeriod == AnalysisPeriod.daily
                  ? 'Use ‹ or › to view other days or add a transaction'
                  : 'Use ‹ or › to browse other dates',
              style: TextStyle(color: fintech.mutedText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: Column(
        children: transactions.map((t) {
          final category = categories.firstWhere(
            (item) => item.id == t.categoryId,
            orElse: () => CategoryModel(
              name: 'Unknown',
              iconCode: Icons.help.codePoint,
              colorValue: Colors.grey.toARGB32(),
              type: t.type,
              isCustom: false,
            ),
          );

          final title = category.name.isNotEmpty ? category.name : (t.note.isNotEmpty ? t.note : 'Transaction');
          final subtitle = t.note.isNotEmpty
              ? '${t.note} · ${DateFormat('MMM dd, yyyy').format(t.date)}'
              : DateFormat('MMM dd, yyyy').format(t.date);

          return TransactionTile(
            title: title,
            subtitle: subtitle,
            amount: t.amount,
            type: t.type,
            categoryColor: Color(category.colorValue),
            icon: IconHelper.getIcon(category.iconCode),
            currency: currency,
            onTap: () => _editTransaction(t),
            onLongPress: () => _confirmDeleteTransaction(t),
          );
        }).toList(),
      ),
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
    final fintech = context.fintech;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: fintech.mutedText)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: fintech.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && transaction.id != null) {
      await ref.read(transactionProvider.notifier).deleteTransaction(transaction.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
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
    final radius = 65.0; // Starts line at outer edge of main donut

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
        path.lineTo(midX, y);
        path.lineTo(targetX, y);
        
        canvas.drawPath(path, paint);
      }
    }
    
    drawLines(leftCount, true);
    drawLines(rightCount, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
