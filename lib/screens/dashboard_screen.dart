import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../providers/debt_provider.dart';
import '../providers/budget_provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../utils/icon_helper.dart';
import '../utils/app_theme.dart';
import '../widgets/fintech_widgets.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'Monthly';
  DateTime _selectedDate = DateTime.now();
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider);
    final settings = ref.watch(settingsProvider);
    final debts = ref.watch(debtProvider);
    final budgets = ref.watch(budgetProvider);
    final currency = settings.currencySymbol;
    final accountState = ref.watch(accountProvider);

    final filteredTransactions = _filterTransactions(
      transactions,
      _selectedPeriod,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    double totalInvestment = 0;
    for (var t in filteredTransactions) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else if (t.type == 'expense') {
        totalExpense += t.amount;
      } else if (t.type == 'investment') {
        totalInvestment += t.amount;
      }
    }
    final balance = totalIncome - totalExpense;

    final now = DateTime.now();
    final currentMonthBudget = budgets
        .where((b) => b.month == now.month && b.year == now.year && b.categoryId == null)
        .firstOrNull;

    final currentMonthExpenses = transactions
        .where((t) => t.type == 'expense' && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);

    double owedToMe = 0;
    double iOwe = 0;
    for (var d in debts) {
      if (!d.isSettled) {
        final remaining = d.totalAmount - d.paidAmount;
        if (d.type == 'lent') {
          owedToMe += remaining;
        } else {
          iOwe += remaining;
        }
      }
    }

    final dateHeaderStr = DateFormat('EEEE, d MMM').format(now);

    return Scaffold(
      backgroundColor: FintechColors.background,
      appBar: AppBar(
        backgroundColor: FintechColors.background,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateHeaderStr,
              style: const TextStyle(
                color: FintechColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Dashboard',
              style: TextStyle(
                color: FintechColors.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: FintechColors.mutedText),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Balance Card
            BalanceCard(
              balance: balance,
              monthlyBudget: currentMonthBudget?.limitAmount,
              monthlyExpense: currentMonthExpenses,
              currency: currency,
            ),
            const SizedBox(height: 16),

            // 2. Account Pills Row
            if (accountState.accounts.isNotEmpty) ...[
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: accountState.accounts.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final account = accountState.accounts[index];
                    final accountBalance = accountState.balances[account.id] ?? account.openingBalance;
                    return AccountPill(
                      name: account.name,
                      balance: accountBalance,
                      color: Color(account.colorValue),
                      currency: currency,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 3. Stat Cards Row (Income & Expense)
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Income',
                    amount: totalIncome,
                    color: FintechColors.income,
                    icon: Icons.arrow_upward_rounded,
                    currency: currency,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Expense',
                    amount: totalExpense,
                    color: FintechColors.expense,
                    icon: Icons.arrow_downward_rounded,
                    currency: currency,
                  ),
                ),
              ],
            ),

            // 4. Investment / Debt Cards if applicable
            if (totalInvestment > 0) ...[
              const SizedBox(height: 12),
              StatCard(
                title: 'Investment',
                amount: totalInvestment,
                color: const Color(0xFFB58CFF),
                icon: Icons.trending_up_rounded,
                currency: currency,
              ),
            ],

            if (owedToMe > 0 || iOwe > 0) ...[
              const SizedBox(height: 12),
              _buildDebtsLoansCard(owedToMe, iOwe, currency),
            ],

            const SizedBox(height: 20),

            // 5. Period Selector & Date Navigator
            _buildPeriodSelector(),
            _buildDateNavigator(),
            const SizedBox(height: 20),

            // 6. Recent Transactions Header & List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: FintechColors.primaryText,
                  ),
                ),
                Text(
                  _selectedPeriod,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FintechColors.mutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildTransactionList(
              filteredTransactions,
              categories,
              currency,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransaction(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildDebtsLoansCard(double owedToMe, double iOwe, String currency) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.handshake_outlined, color: FintechColors.accent, size: 18),
              SizedBox(width: 8),
              Text(
                'Debts & Loans',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: FintechColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Owed to me',
                      style: TextStyle(fontSize: 12, color: FintechColors.mutedText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency${owedToMe.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: FintechColors.income,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: FintechColors.cardBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'I Owe',
                        style: TextStyle(fontSize: 12, color: FintechColors.mutedText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currency${iOwe.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FintechColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _selectedPeriod = period;
                _selectedDate = DateTime.now();
              }),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF12382F) : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? FintechColors.accent : FintechColors.mutedText,
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
    if (_selectedPeriod == 'Daily') {
      if (target.isAtSameMomentAs(today)) {
        label = 'Today, ${DateFormat('d MMM yyyy').format(_selectedDate)}';
      } else if (target.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
        label = 'Yesterday, ${DateFormat('d MMM yyyy').format(_selectedDate)}';
      } else {
        label = DateFormat('EEE, d MMM yyyy').format(_selectedDate);
      }
    } else if (_selectedPeriod == 'Weekly') {
      final startOfWeek = target.subtract(Duration(days: target.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final isCurrentWeek = !today.isBefore(startOfWeek) && !today.isAfter(endOfWeek);
      if (isCurrentWeek) {
        final rolling7Start = today.subtract(const Duration(days: 6));
        label = 'Past 7 Days (${DateFormat('d MMM').format(rolling7Start)} - ${DateFormat('d MMM').format(today)})';
      } else {
        label = '${DateFormat('d MMM').format(startOfWeek)} - ${DateFormat('d MMM yyyy').format(endOfWeek)}';
      }
    } else if (_selectedPeriod == 'Monthly') {
      label = DateFormat('MMMM yyyy').format(_selectedDate);
    } else if (_selectedPeriod == 'Yearly') {
      label = DateFormat('yyyy').format(_selectedDate);
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 22, color: FintechColors.mutedText),
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
                    const Icon(Icons.calendar_today_outlined, size: 13, color: FintechColors.accent),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FintechColors.primaryText,
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
            icon: const Icon(Icons.chevron_right_rounded, size: 22, color: FintechColors.mutedText),
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
      if (_selectedPeriod == 'Daily') {
        _selectedDate = _selectedDate.add(Duration(days: direction));
      } else if (_selectedPeriod == 'Weekly') {
        _selectedDate = _selectedDate.add(Duration(days: direction * 7));
      } else if (_selectedPeriod == 'Monthly') {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + direction,
          _selectedDate.day.clamp(1, 28),
        );
      } else if (_selectedPeriod == 'Yearly') {
        _selectedDate = DateTime(
          _selectedDate.year + direction,
          _selectedDate.month,
          _selectedDate.day.clamp(1, 28),
        );
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: FintechColors.accent,
              onPrimary: Color(0xFF0C1110),
              surface: FintechColors.cardSurface,
              onSurface: FintechColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildTransactionList(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    String currency,
  ) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: FintechColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FintechColors.cardBorder, width: 1),
        ),
        child: Column(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 36, color: FintechColors.mutedText),
            const SizedBox(height: 8),
            Text(
              'No transactions for this $_selectedPeriod'.toLowerCase(),
              style: const TextStyle(
                color: FintechColors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedPeriod == 'Daily'
                  ? 'Use ‹ or › to view other days or add a transaction'
                  : 'Use ‹ or › to browse other dates',
              style: const TextStyle(color: FintechColors.mutedText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final displayList = transactions.take(6).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Column(
        children: displayList.map((t) {
          final category = categories.where((c) => c.id == t.categoryId).firstOrNull;
          final title = category?.name ?? (t.note.isNotEmpty ? t.note : 'Transaction');
          final subtitle = t.note.isNotEmpty && category != null
              ? '${t.note} · ${DateFormat('d MMM').format(t.date)}'
              : DateFormat('d MMM, yyyy').format(t.date);
          final catColor = category != null ? Color(category.colorValue) : FintechColors.accent;
          final iconData = category != null ? IconHelper.getIcon(category.iconCode) : Icons.category;

          return TransactionTile(
            title: title,
            subtitle: subtitle,
            amount: t.amount,
            type: t.type,
            categoryColor: catColor,
            icon: iconData,
            currency: currency,
            onTap: () => _editTransaction(t),
            onLongPress: () => _confirmDeleteTransaction(t),
          );
        }).toList(),
      ),
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
    String period,
  ) {
    final target = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return transactions.where((t) {
      final localDate = t.date.toLocal();
      final tDate = DateTime(localDate.year, localDate.month, localDate.day);

      if (period == 'Daily') {
        return tDate.year == target.year &&
            tDate.month == target.month &&
            tDate.day == target.day;
      } else if (period == 'Weekly') {
        // Monday of selected week
        final startOfWeek = target.subtract(Duration(days: target.weekday - 1));
        final endOfWeek = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day + 6,
          23, 59, 59, 999,
        );
        // If viewing current week, include past 7 days (rolling window) as well
        final isCurrentWeek = !today.isBefore(startOfWeek) && !today.isAfter(endOfWeek);
        final rolling7Start = today.subtract(const Duration(days: 6));
        final effectiveStart = (isCurrentWeek && rolling7Start.isBefore(startOfWeek))
            ? rolling7Start
            : startOfWeek;

        return !localDate.isBefore(effectiveStart) && !localDate.isAfter(endOfWeek);
      } else if (period == 'Monthly') {
        return localDate.year == _selectedDate.year &&
            localDate.month == _selectedDate.month;
      } else if (period == 'Yearly') {
        return localDate.year == _selectedDate.year;
      }
      return true;
    }).toList();
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
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: FintechColors.mutedText)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: FintechColors.expense),
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

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionScreen(),
    );
  }
}
