import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/icon_helper.dart';
import '../../widgets/fintech_widgets.dart';
import '../accounts_screen.dart';
import '../add_transaction_screen.dart';
import '../analysis_screen.dart';
import '../budget_screen.dart';
import '../categories_screen.dart';
import '../debts_screen.dart';
import '../goals_screen.dart';
import '../history_screen.dart';
import '../settings_screen.dart';

/// Full-featured Desktop CRM Dashboard Suite for Web
class WebCrmLayout extends ConsumerStatefulWidget {
  const WebCrmLayout({super.key});

  @override
  ConsumerState<WebCrmLayout> createState() => _WebCrmLayoutState();
}

class _WebCrmLayoutState extends ConsumerState<WebCrmLayout> {
  int _selectedNavIndex = 0;
  String _selectedPeriod = 'Monthly';
  DateTime _selectedDate = DateTime.now();
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  final List<_NavMenuItem> _navItems = const [
    _NavMenuItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavMenuItem(icon: Icons.pie_chart_rounded, label: 'Analytics'),
    _NavMenuItem(icon: Icons.history_rounded, label: 'History'),
    _NavMenuItem(icon: Icons.account_balance_wallet_rounded, label: 'Budgets'),
    _NavMenuItem(icon: Icons.credit_card_rounded, label: 'Accounts'),
    _NavMenuItem(icon: Icons.handshake_outlined, label: 'Debts & Loans'),
    _NavMenuItem(icon: Icons.stars_rounded, label: 'Savings Goals'),
    _NavMenuItem(icon: Icons.category_outlined, label: 'Categories'),
    _NavMenuItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FintechColors.background,
      body: Row(
        children: [
          // 1. Left CRM Sidebar
          _buildSidebar(context),

          // Divider line
          Container(
            width: 1,
            color: FintechColors.cardBorder,
          ),

          // 2. Main Content Area
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      ),
    );
  }

  /// Left Desktop Navigation Sidebar
  Widget _buildSidebar(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Container(
      width: 250,
      color: FintechColors.navBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand & Logo Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: FintechColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FintechColors.accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: FintechColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atthani',
                      style: TextStyle(
                        color: FintechColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Expense Suite',
                      style: TextStyle(
                        color: FintechColors.mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Action: + Add Transaction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openAddTransaction(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3EE6B0), Color(0xFF22C55E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3EE6B0).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: Color(0xFF0C1110), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'New Transaction',
                        style: TextStyle(
                          color: Color(0xFF0C1110),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Navigation Links
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedNavIndex == index;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedNavIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? FintechColors.accent.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: FintechColors.accent.withValues(alpha: 0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 18,
                            color: isSelected
                                ? FintechColors.accent
                                : FintechColors.mutedText,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? FintechColors.primaryText
                                  : FintechColors.secondaryText,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom System Pill
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: FintechColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FintechColors.cardBorder, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: FintechColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Currency: ${settings.currencySymbol}',
                  style: const TextStyle(
                    color: FintechColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Web CRM',
                  style: TextStyle(
                    color: FintechColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Main Desktop Content Switcher
  Widget _buildMainContent(BuildContext context) {
    switch (_selectedNavIndex) {
      case 0:
        return _buildCrmDashboard(context);
      case 1:
        return const AnalysisScreen();
      case 2:
        return const HistoryScreen();
      case 3:
        return const BudgetScreen();
      case 4:
        return const AccountsScreen();
      case 5:
        return const DebtsScreen();
      case 6:
        return const GoalsScreen();
      case 7:
        return const CategoriesScreen();
      case 8:
        return const SettingsScreen();
      default:
        return _buildCrmDashboard(context);
    }
  }

  /// Rich Multi-Column Desktop CRM Dashboard
  Widget _buildCrmDashboard(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider);
    final settings = ref.watch(settingsProvider);
    final debts = ref.watch(debtProvider);
    final budgets = ref.watch(budgetProvider);
    final goals = ref.watch(goalProvider);
    final accountState = ref.watch(accountProvider);
    final currency = settings.currencySymbol;

    final filteredTransactions = _filterTransactions(
      transactions,
      _selectedPeriod,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in filteredTransactions) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else if (t.type == 'expense') {
        totalExpense += t.amount;
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

    final dateHeaderStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Column(
      children: [
        // Top Header Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: const BoxDecoration(
            color: FintechColors.background,
            border: Border(
              bottom: BorderSide(color: FintechColors.cardBorder, width: 1),
            ),
          ),
          child: Row(
            children: [
              Column(
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
                    'Financial Overview',
                    style: TextStyle(
                      color: FintechColors.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Period Pills Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: FintechColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FintechColors.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _periods.map((period) {
                    final isSelected = _selectedPeriod == period;
                    return InkWell(
                      onTap: () => setState(() => _selectedPeriod = period),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? FintechColors.accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(
                                  color: FintechColors.accent.withValues(alpha: 0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            color: isSelected
                                ? FintechColors.accent
                                : FintechColors.mutedText,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(width: 16),

              // Date Navigator Controls
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: FintechColors.mutedText),
                onPressed: () => _changeDate(-1),
                tooltip: 'Previous',
              ),
              Text(
                _getDateRangeText(),
                style: const TextStyle(
                  color: FintechColors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: FintechColors.mutedText),
                onPressed: () => _changeDate(1),
                tooltip: 'Next',
              ),
            ],
          ),
        ),

        // Scrollable Multi-Column Dashboard Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Metrics 3-Column Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card with Dynamic Animated Wave
                    Expanded(
                      flex: 4,
                      child: BalanceCard(
                        balance: balance,
                        monthlyBudget: currentMonthBudget?.limitAmount,
                        monthlyExpense: currentMonthExpenses,
                        currency: currency,
                      ),
                    ),
                    const SizedBox(width: 18),

                    // Total Income Card
                    Expanded(
                      flex: 3,
                      child: StatCard(
                        title: 'Total Income',
                        amount: totalIncome,
                        color: FintechColors.income,
                        icon: Icons.arrow_upward_rounded,
                        currency: currency,
                      ),
                    ),
                    const SizedBox(width: 18),

                    // Total Expense Card
                    Expanded(
                      flex: 3,
                      child: StatCard(
                        title: 'Total Expense',
                        amount: totalExpense,
                        color: FintechColors.expense,
                        icon: Icons.arrow_downward_rounded,
                        currency: currency,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 2. Account Pills Row
                if (accountState.accounts.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'Accounts',
                        style: TextStyle(
                          color: FintechColors.mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: accountState.accounts.map((account) {
                            final accountBalance =
                                accountState.balances[account.id] ?? account.openingBalance;
                            return AccountPill(
                              name: account.name,
                              balance: accountBalance,
                              color: Color(account.colorValue),
                              currency: currency,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // 3. Multi-Column Grid (Main Left Section & Right Insights Panel)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Main Panel (65% Width)
                    Expanded(
                      flex: 65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Spending Category Breakdown
                          _buildSpendingBreakdownCard(
                            filteredTransactions,
                            categories,
                            currency,
                            totalExpense,
                          ),
                          const SizedBox(height: 22),

                          // Recent Transactions Table
                          _buildRecentTransactionsTable(
                            context,
                            filteredTransactions,
                            categories,
                            accountState,
                            currency,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 22),

                    // Right Insights Panel (35% Width)
                    Expanded(
                      flex: 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Monthly Budget Card
                          _buildBudgetCard(
                            currentMonthBudget?.limitAmount,
                            currentMonthExpenses,
                            currency,
                          ),
                          const SizedBox(height: 20),

                          // Debts Summary Card
                          _buildDebtsSummaryCard(owedToMe, iOwe, currency),
                          const SizedBox(height: 20),

                          // Active Savings Goals Card
                          _buildGoalsCard(goals, currency),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Spending Breakdown Progress List
  Widget _buildSpendingBreakdownCard(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    String currency,
    double totalExpense,
  ) {
    final Map<int, double> categoryTotals = {};
    for (var t in transactions) {
      if (t.type == 'expense') {
        categoryTotals[t.categoryId] =
            (categoryTotals[t.categoryId] ?? 0.0) + t.amount;
      }
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedEntries.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Expense Categories',
                style: TextStyle(
                  color: FintechColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Total: $currency${NumberFormat('#,##0.00').format(totalExpense)}',
                style: const TextStyle(
                  color: FintechColors.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (topCategories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No expenses recorded for this period',
                  style: TextStyle(color: FintechColors.mutedText, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: topCategories.map((entry) {
                final cat = categories.firstWhere(
                  (c) => c.id == entry.key,
                  orElse: () => CategoryModel(
                    name: 'Other',
                    type: 'expense',
                    iconCode: 58941,
                    colorValue: 0xFF808080,
                  ),
                );
                final percentage = totalExpense > 0
                    ? (entry.value / totalExpense).clamp(0.0, 1.0)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            IconHelper.getIcon(cat.iconCode),
                            color: Color(cat.colorValue),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat.name,
                            style: const TextStyle(
                              color: FintechColors.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$currency${NumberFormat('#,##0.00').format(entry.value)}',
                            style: const TextStyle(
                              color: FintechColors.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(percentage * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 5,
                          backgroundColor: FintechColors.navBg,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(cat.colorValue),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Recent Transactions Detailed Desktop Table
  Widget _buildRecentTransactionsTable(
    BuildContext context,
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    dynamic accountState,
    String currency,
  ) {
    final recent = transactions.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  color: FintechColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _selectedNavIndex = 2),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: FintechColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: FintechColors.accent,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'No transactions recorded for this period',
                  style: TextStyle(color: FintechColors.mutedText, fontSize: 13),
                ),
              ),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2.5),
                4: FlexColumnWidth(2),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Table Header
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: FintechColors.cardBorder, width: 1),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Category',
                          style: TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Description / Note',
                          style: TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Account',
                          style: TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Date',
                          style: TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Amount',
                            style: TextStyle(
                                color: FintechColors.mutedText,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                // Table Rows
                ...recent.map((tx) {
                  final cat = categories.firstWhere(
                    (c) => c.id == tx.categoryId,
                    orElse: () => CategoryModel(
                      name: 'Uncategorized',
                      type: tx.type,
                      iconCode: 58941,
                      colorValue: 0xFF808080,
                    ),
                  );
                  final accountName = accountState.getAccountName(tx.accountId);
                  final isIncome = tx.type == 'income';
                  final amountPrefix = isIncome ? '+' : '-';
                  final amountColor =
                      isIncome ? FintechColors.income : FintechColors.expense;

                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: FintechColors.cardBorder.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CategoryIcon(
                              icon: IconHelper.getIcon(cat.iconCode),
                              color: Color(cat.colorValue),
                              size: 32,
                              iconSize: 16,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  color: FintechColors.primaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          tx.note.isNotEmpty ? tx.note : '—',
                          style: const TextStyle(
                            color: FintechColors.secondaryText,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: FintechColors.navBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: FintechColors.cardBorder, width: 1),
                          ),
                          child: Text(
                            accountName,
                            style: const TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          DateFormat('d MMM, HH:mm').format(tx.date),
                          style: const TextStyle(
                            color: FintechColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$amountPrefix$currency${NumberFormat('#,##0.00').format(tx.amount)}',
                            style: TextStyle(
                              color: amountColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  /// Right Panel: Monthly Budget Tracker
  Widget _buildBudgetCard(
    double? monthlyBudget,
    double monthlyExpense,
    String currency,
  ) {
    final hasBudget = monthlyBudget != null && monthlyBudget > 0;
    final remaining = hasBudget ? (monthlyBudget - monthlyExpense) : 0.0;
    final progress =
        hasBudget ? (monthlyExpense / monthlyBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Budget',
                style: TextStyle(
                  color: FintechColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _selectedNavIndex = 3),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: FintechColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasBudget)
            const Text(
              'No overall budget set for this month',
              style: TextStyle(color: FintechColors.mutedText, fontSize: 13),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: $currency${NumberFormat('#,##0').format(monthlyExpense)}',
                  style: const TextStyle(
                    color: FintechColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Limit: $currency${NumberFormat('#,##0').format(monthlyBudget)}',
                  style: const TextStyle(
                    color: FintechColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: FintechColors.navBg,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.85
                      ? FintechColors.expense
                      : (progress > 0.6
                          ? FintechColors.warning
                          : FintechColors.income),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              remaining >= 0
                  ? '$currency${NumberFormat('#,##0').format(remaining)} remaining'
                  : 'Over budget by $currency${NumberFormat('#,##0').format(remaining.abs())}',
              style: TextStyle(
                color: remaining >= 0
                    ? FintechColors.accent
                    : FintechColors.expense,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Right Panel: Debts & Loans Summary
  Widget _buildDebtsSummaryCard(double owedToMe, double iOwe, String currency) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Debts & Loans',
                style: TextStyle(
                  color: FintechColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _selectedNavIndex = 5),
                child: const Text(
                  'Details',
                  style: TextStyle(
                    color: FintechColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FintechColors.navBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FintechColors.income.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Owed to me',
                        style: TextStyle(
                          color: FintechColors.mutedText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currency${NumberFormat('#,##0').format(owedToMe)}',
                        style: const TextStyle(
                          color: FintechColors.income,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FintechColors.navBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FintechColors.expense.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'I owe',
                        style: TextStyle(
                          color: FintechColors.mutedText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currency${NumberFormat('#,##0').format(iOwe)}',
                        style: const TextStyle(
                          color: FintechColors.expense,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
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

  /// Right Panel: Active Savings Goals
  Widget _buildGoalsCard(List<dynamic> goals, String currency) {
    final activeGoals = goals.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Savings Goals',
                style: TextStyle(
                  color: FintechColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _selectedNavIndex = 6),
                child: const Text(
                  'All Goals',
                  style: TextStyle(
                    color: FintechColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (activeGoals.isEmpty)
            const Text(
              'No active savings goals',
              style: TextStyle(color: FintechColors.mutedText, fontSize: 13),
            )
          else
            Column(
              children: activeGoals.map((g) {
                final target = g.targetAmount as double;
                final current = g.currentAmount as double;
                final progress =
                    target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            g.name as String,
                            style: const TextStyle(
                              color: FintechColors.primaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$currency${NumberFormat('#,##0').format(current)} / $currency${NumberFormat('#,##0').format(target)}',
                            style: const TextStyle(
                              color: FintechColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: FintechColors.navBg,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            FintechColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Container(
          width: 540,
          height: 700,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: FintechColors.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: FintechColors.cardBorder, width: 1),
          ),
          child: const AddTransactionScreen(),
        ),
      ),
    );
  }

  void _changeDate(int offset) {
    setState(() {
      if (_selectedPeriod == 'Daily') {
        _selectedDate = _selectedDate.add(Duration(days: offset));
      } else if (_selectedPeriod == 'Weekly') {
        _selectedDate = _selectedDate.add(Duration(days: offset * 7));
      } else if (_selectedPeriod == 'Monthly') {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + offset,
          _selectedDate.day,
        );
      } else if (_selectedPeriod == 'Yearly') {
        _selectedDate = DateTime(
          _selectedDate.year + offset,
          _selectedDate.month,
          _selectedDate.day,
        );
      }
    });
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    if (_selectedPeriod == 'Daily') {
      if (_selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day) {
        return 'Today';
      }
      return DateFormat('EEE, d MMM').format(_selectedDate);
    } else if (_selectedPeriod == 'Weekly') {
      final startOfWeek =
          _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${DateFormat('d MMM').format(startOfWeek)} - ${DateFormat('d MMM').format(endOfWeek)}';
    } else if (_selectedPeriod == 'Monthly') {
      if (_selectedDate.year == now.year && _selectedDate.month == now.month) {
        return DateFormat('MMMM yyyy').format(_selectedDate);
      }
      return DateFormat('MMMM yyyy').format(_selectedDate);
    } else {
      return DateFormat('yyyy').format(_selectedDate);
    }
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
    String period,
  ) {
    return transactions.where((t) {
      if (period == 'Daily') {
        return t.date.year == _selectedDate.year &&
            t.date.month == _selectedDate.month &&
            t.date.day == _selectedDate.day;
      } else if (period == 'Weekly') {
        final startOfWeek =
            _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final start =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = start.add(const Duration(days: 7));
        return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end);
      } else if (period == 'Monthly') {
        return t.date.year == _selectedDate.year &&
            t.date.month == _selectedDate.month;
      } else if (period == 'Yearly') {
        return t.date.year == _selectedDate.year;
      }
      return true;
    }).toList();
  }
}

class _NavMenuItem {
  final IconData icon;
  final String label;

  const _NavMenuItem({
    required this.icon,
    required this.label,
  });
}
