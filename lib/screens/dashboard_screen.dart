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
import '../models/account_model.dart';
import '../utils/icon_helper.dart';
import '../utils/app_theme.dart';
import '../utils/financial_calculator.dart';
import '../widgets/fintech_widgets.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  FintechThemeColors get fintech => context.fintech;
  final String _selectedPeriod = 'Monthly';
  final DateTime _selectedDate = DateTime.now();

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

    final summary = FinancialCalculator.calculate(
      transactions: transactions,
      accounts: accountState.accounts,
      targetDate: _selectedDate,
      period: _selectedPeriod,
    );

    final totalIncome = summary.totalIncome;
    final totalExpense = summary.totalExpense;
    final totalInvestment = summary.totalInvestment;
    final balance = summary.balance;
    final incomeSubtitle = summary.getIncomeSubtitle(currency);

    final now = DateTime.now();

    // Calculate monthly budget limit for the current month
    final overallBudget = budgets
        .where((b) => b.month == now.month && b.year == now.year && b.categoryId == null)
        .firstOrNull;
    double monthlyBudgetLimit = overallBudget?.limitAmount ?? 0.0;
    if (monthlyBudgetLimit == 0.0) {
      monthlyBudgetLimit = budgets
          .where((b) => b.month == now.month && b.year == now.year && b.categoryId != null)
          .fold(0.0, (sum, b) => sum + b.limitAmount);
    }

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
    final fintech = context.fintech;

    return Scaffold(
      backgroundColor: fintech.background,
      appBar: AppBar(
        backgroundColor: fintech.background,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateHeaderStr,
              style: TextStyle(
                color: fintech.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Dashboard',
              style: TextStyle(
                color: fintech.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: fintech.mutedText),
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
            // 1. Stacked Accounts Card (matching Image 1 with interactive smooth transition)
            EtherealStackedAccountsCard(
              accounts: accountState.accounts,
              balances: accountState.balances,
              currency: currency,
              onAddAccount: () => _showAddAccountDialog(context),
            ),
            const SizedBox(height: 16),

            // 2. Total Balance Card below Account Cards (matching Image 2)
            EtherealTotalBalanceCard(
              balance: balance,
              currency: currency,
              subtitle: summary.carriedForwardFromPrevious > 0
                  ? '+$currency${NumberFormat('#,##0').format(summary.carriedForwardFromPrevious)} revenue from ${summary.carriedForwardFromMonthName}'
                  : (incomeSubtitle ?? 'Available balance'),
              monthlyBudget: monthlyBudgetLimit > 0 ? monthlyBudgetLimit : null,
              spentAmount: totalExpense,
              showActions: false,
            ),
            const SizedBox(height: 14),

            // 3. Income & Expense Cards below Total Balance Card (matching Image 2)
            Row(
              children: [
                Expanded(
                  child: EtherealMetricCard(
                    title: 'Income',
                    amount: totalIncome,
                    currency: currency,
                    subtitle: incomeSubtitle,
                    badgeText: '+15.7%',
                    isIncome: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EtherealMetricCard(
                    title: 'Expense',
                    amount: totalExpense,
                    currency: currency,
                    badgeText: '-10.7%',
                    isIncome: false,
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

            // 5. Recent Transactions Header & List
            Text(
              'Recent',
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
    final fintech = context.fintech;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handshake_outlined, color: fintech.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Debts & Loans',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: fintech.primaryText,
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
                    Text(
                      'Owed to me',
                      style: TextStyle(fontSize: 12, color: fintech.mutedText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency${owedToMe.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: fintech.income,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: fintech.cardBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I Owe',
                        style: TextStyle(fontSize: 12, color: fintech.mutedText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currency${iOwe.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: fintech.expense,
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
          color: fintech.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fintech.cardBorder, width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 36, color: fintech.mutedText),
            const SizedBox(height: 8),
            Text(
              'No transactions for this $_selectedPeriod'.toLowerCase(),
              style: TextStyle(
                color: fintech.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedPeriod == 'Daily'
                  ? 'Use ‹ or › to view other days or add a transaction'
                  : 'Use ‹ or › to browse other dates',
              style: TextStyle(color: fintech.mutedText, fontSize: 12),
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
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: Column(
        children: displayList.map((t) {
          final category = categories.where((c) => c.id == t.categoryId).firstOrNull;
          final title = category?.name ?? (t.note.isNotEmpty ? t.note : 'Transaction');
          final subtitle = t.note.isNotEmpty && category != null
              ? '${t.note} · ${DateFormat('d MMM').format(t.date)}'
              : DateFormat('d MMM, yyyy').format(t.date);
          final catColor = category != null ? Color(category.colorValue) : fintech.accent;
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

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionScreen(),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final fintech = context.fintech;
    final currency = ref.read(settingsProvider).currencySymbol;
    final name = TextEditingController();
    final opening = TextEditingController(text: '0');
    var type = 'bank';
    const cardColorPresets = [
      Color(0xFF312E81), // Deep Indigo Metal
      Color(0xFF047857), // Emerald Fintech
      Color(0xFF18181B), // Obsidian Carbon
      Color(0xFF9F1239), // Crimson Luxury
      Color(0xFF1D4ED8), // Royal Sapphire
      Color(0xFFD97706), // Amber Gold
      Color(0xFF0F766E), // Midnight Teal
      Color(0xFF475569), // Titanium Slate
    ];
    var selectedColor = cardColorPresets[0];

    IconData getIcon(String t) {
      switch (t.toLowerCase()) {
        case 'bank':
          return Icons.account_balance_rounded;
        case 'card':
          return Icons.credit_card_rounded;
        case 'wallet':
          return Icons.account_balance_wallet_rounded;
        case 'cash':
          return Icons.payments_rounded;
        default:
          return Icons.account_balance_wallet_rounded;
      }
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final hsl = HSLColor.fromColor(selectedColor);
          final darker = hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
          final lighter = hsl.withLightness((hsl.lightness + 0.14).clamp(0.0, 1.0)).toColor();
          final isLight = selectedColor.computeLuminance() > 0.52;
          final previewTextColor = isLight ? const Color(0xFF0F172A) : Colors.white;
          final previewSubColor = isLight ? const Color(0xFF334155) : Colors.white.withValues(alpha: 0.85);

          return AlertDialog(
            title: const Text('Add Account Card'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini card preview
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [darker, selectedColor, lighter],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(getIcon(type), size: 14, color: previewTextColor),
                                const SizedBox(width: 6),
                                Text(
                                  name.text.trim().isEmpty ? 'ACCOUNT NAME' : name.text.trim().toUpperCase(),
                                  style: TextStyle(
                                    color: previewTextColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '•••• 0001',
                              style: TextStyle(
                                color: previewSubColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 14,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFE082), Color(0xFFD4AF37)],
                                ),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Colors.amber.shade700, width: 0.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.contactless_rounded, size: 13, color: previewSubColor.withValues(alpha: 0.8)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$currency ${NumberFormat('#,##0.00').format(double.tryParse(opening.text) ?? 0)}',
                              style: TextStyle(
                                color: previewTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                color: previewSubColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    style: TextStyle(color: fintech.primaryText),
                    decoration: const InputDecoration(labelText: 'Account name'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    dropdownColor: fintech.cardSurface,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      DropdownMenuItem(value: 'cash', child: Text('Cash', style: TextStyle(color: fintech.primaryText))),
                      DropdownMenuItem(value: 'bank', child: Text('Bank', style: TextStyle(color: fintech.primaryText))),
                      DropdownMenuItem(value: 'card', child: Text('Credit Card', style: TextStyle(color: fintech.primaryText))),
                      DropdownMenuItem(value: 'wallet', child: Text('Wallet', style: TextStyle(color: fintech.primaryText))),
                      DropdownMenuItem(value: 'other', child: Text('Other', style: TextStyle(color: fintech.primaryText))),
                    ],
                    onChanged: (value) => setState(() => type = value ?? type),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: opening,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: fintech.primaryText),
                    decoration: const InputDecoration(labelText: 'Opening balance'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Card Color',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fintech.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: cardColorPresets.map((c) {
                      final isSelected = c.toARGB32() == selectedColor.toARGB32();
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: c.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel', style: TextStyle(color: fintech.mutedText)),
              ),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(opening.text) ?? 0;
                  if (name.text.trim().isEmpty) return;
                  ref.read(accountProvider.notifier).addAccount(
                        AccountModel(
                          name: name.text.trim(),
                          type: type,
                          openingBalance: amount,
                          colorValue: selectedColor.toARGB32(),
                          iconCode: getIcon(type).codePoint,
                          createdAt: DateTime.now(),
                        ),
                      );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}

