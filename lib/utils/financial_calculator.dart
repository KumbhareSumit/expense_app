import 'package:intl/intl.dart';

import '../models/account_model.dart';
import '../models/transaction_model.dart';

class MonthlyFinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double accountOpeningIncome;
  final double carriedForwardFromPrevious;
  final String? carriedForwardFromMonthName;
  final double regularIncome;

  const MonthlyFinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.accountOpeningIncome = 0.0,
    this.carriedForwardFromPrevious = 0.0,
    this.carriedForwardFromMonthName,
    this.regularIncome = 0.0,
  });

  bool get hasRollover => carriedForwardFromPrevious > 0;
  bool get hasAccountIncome => accountOpeningIncome > 0;

  String? getIncomeSubtitle(String currency) {
    if (carriedForwardFromPrevious > 0) {
      final formatted = NumberFormat('#,##0').format(carriedForwardFromPrevious);
      final from = carriedForwardFromMonthName ?? 'prev month';
      return 'Incl. $currency$formatted from $from';
    } else if (accountOpeningIncome > 0) {
      final formatted = NumberFormat('#,##0').format(accountOpeningIncome);
      return 'Incl. $currency$formatted from accounts';
    }
    return null;
  }
}

class FinancialCalculator {
  /// Calculates income, expense, and balance for the given period.
  ///
  /// Key rules:
  /// 1. When accounts are created, their opening balances are added to that month's income.
  /// 2. Each month strictly reflects its own transactions and opening balances (no rollover).
  static MonthlyFinancialSummary calculate({
    required List<TransactionModel> transactions,
    required List<AccountModel> accounts,
    required DateTime targetDate,
    required String period,
    DateTime? now,
  }) {
    final currentNow = now ?? DateTime.now();

    if (period == 'Daily') {
      return _calculateDaily(transactions, accounts, targetDate);
    } else if (period == 'Weekly') {
      return _calculateWeekly(transactions, accounts, targetDate, currentNow);
    } else if (period == 'Yearly') {
      return _calculateYearly(transactions, accounts, targetDate, currentNow);
    } else {
      // Default: 'Monthly'
      return _calculateMonthly(transactions, accounts, targetDate, currentNow);
    }
  }

  static MonthlyFinancialSummary _calculateDaily(
    List<TransactionModel> transactions,
    List<AccountModel> accounts,
    DateTime targetDate,
  ) {
    double txIncome = 0;
    double txExpense = 0;

    for (final t in transactions) {
      final local = t.date.toLocal();
      if (local.year == targetDate.year &&
          local.month == targetDate.month &&
          local.day == targetDate.day) {
        if (t.type == 'income') {
          txIncome += t.amount;
        } else if (t.type == 'expense') {
          txExpense += t.amount;
        }
      }
    }

    double acctIncome = 0;
    for (final a in accounts) {
      final created = a.createdAt?.toLocal();
      if (created != null &&
          created.year == targetDate.year &&
          created.month == targetDate.month &&
          created.day == targetDate.day) {
        acctIncome += a.openingBalance;
      }
    }

    final totalIncome = txIncome + acctIncome;
    final balance = totalIncome - txExpense;

    return MonthlyFinancialSummary(
      totalIncome: totalIncome,
      totalExpense: txExpense,
      balance: balance,
      accountOpeningIncome: acctIncome,
      regularIncome: txIncome,
    );
  }

  static MonthlyFinancialSummary _calculateWeekly(
    List<TransactionModel> transactions,
    List<AccountModel> accounts,
    DateTime targetDate,
    DateTime now,
  ) {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final startOfWeek = target.subtract(Duration(days: target.weekday - 1));
    final endOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day + 6,
      23,
      59,
      59,
      999,
    );

    double txIncome = 0;
    double txExpense = 0;

    for (final t in transactions) {
      final local = t.date.toLocal();
      if (!local.isBefore(startOfWeek) && !local.isAfter(endOfWeek)) {
        if (t.type == 'income') {
          txIncome += t.amount;
        } else if (t.type == 'expense') {
          txExpense += t.amount;
        }
      }
    }

    double acctIncome = 0;
    for (final a in accounts) {
      final created = a.createdAt?.toLocal();
      if (created != null &&
          !created.isBefore(startOfWeek) &&
          !created.isAfter(endOfWeek)) {
        acctIncome += a.openingBalance;
      }
    }

    final totalIncome = txIncome + acctIncome;
    final balance = totalIncome - txExpense;

    return MonthlyFinancialSummary(
      totalIncome: totalIncome,
      totalExpense: txExpense,
      balance: balance,
      accountOpeningIncome: acctIncome,
      regularIncome: txIncome,
    );
  }

  static MonthlyFinancialSummary _calculateMonthly(
    List<TransactionModel> transactions,
    List<AccountModel> accounts,
    DateTime targetDate,
    DateTime now,
  ) {
    // Determine earliest month for fallback if account createdAt is null
    DateTime earliest = DateTime(now.year, now.month, 1);

    for (final a in accounts) {
      if (a.createdAt != null && a.createdAt!.isBefore(earliest)) {
        earliest = DateTime(a.createdAt!.year, a.createdAt!.month, 1);
      }
    }
    for (final t in transactions) {
      if (t.date.isBefore(earliest)) {
        earliest = DateTime(t.date.year, t.date.month, 1);
      }
    }

    // Transactions in target month
    double txIncome = 0.0;
    double txExpense = 0.0;

    for (final t in transactions) {
      if (t.date.year == targetDate.year && t.date.month == targetDate.month) {
        if (t.type == 'income') {
          txIncome += t.amount;
        } else if (t.type == 'expense') {
          txExpense += t.amount;
        }
      }
    }

    // Account opening balances created in target month
    // If account has no createdAt, assign it to earliest month
    double acctIncome = 0.0;
    for (final a in accounts) {
      final acctCreated = a.createdAt != null
          ? DateTime(a.createdAt!.year, a.createdAt!.month, 1)
          : earliest;
      if (acctCreated.year == targetDate.year && acctCreated.month == targetDate.month) {
        acctIncome += a.openingBalance;
      }
    }

    final monthIncome = acctIncome + txIncome;
    final monthExpense = txExpense;
    final monthBalance = monthIncome - monthExpense;

    return MonthlyFinancialSummary(
      totalIncome: monthIncome,
      totalExpense: monthExpense,
      balance: monthBalance,
      accountOpeningIncome: acctIncome,
      carriedForwardFromPrevious: 0.0,
      carriedForwardFromMonthName: null,
      regularIncome: txIncome,
    );
  }

  static MonthlyFinancialSummary _calculateYearly(
    List<TransactionModel> transactions,
    List<AccountModel> accounts,
    DateTime targetDate,
    DateTime now,
  ) {
    double txIncome = 0;
    double txExpense = 0;

    for (final t in transactions) {
      if (t.date.year == targetDate.year) {
        if (t.type == 'income') {
          txIncome += t.amount;
        } else if (t.type == 'expense') {
          txExpense += t.amount;
        }
      }
    }

    double acctIncome = 0;
    for (final a in accounts) {
      final created = a.createdAt;
      if (created == null || created.year == targetDate.year) {
        acctIncome += a.openingBalance;
      }
    }

    final totalIncome = txIncome + acctIncome;
    final balance = totalIncome - txExpense;

    return MonthlyFinancialSummary(
      totalIncome: totalIncome,
      totalExpense: txExpense,
      balance: balance,
      accountOpeningIncome: acctIncome,
      regularIncome: txIncome,
    );
  }
}
