import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/models/account_model.dart';
import 'package:personal_expense_tracker_app/models/transaction_model.dart';
import 'package:personal_expense_tracker_app/utils/financial_calculator.dart';

void main() {
  group('FinancialCalculator Tests', () {
    final fixedNow = DateTime(2026, 10, 15); // Current month: October 2026

    test('Created accounts total amount is added to income in the active month', () {
      final accounts = [
        AccountModel(
          id: 1,
          name: 'Home',
          type: 'cash',
          openingBalance: 5000.0,
          colorValue: 0,
          iconCode: 0,
          createdAt: DateTime(2026, 10, 1),
        ),
        AccountModel(
          id: 2,
          name: 'Bank',
          type: 'bank',
          openingBalance: 10000.0,
          colorValue: 0,
          iconCode: 0,
          createdAt: DateTime(2026, 10, 5),
        ),
      ];

      final summary = FinancialCalculator.calculate(
        transactions: [],
        accounts: accounts,
        targetDate: DateTime(2026, 10, 15),
        period: 'Monthly',
        now: fixedNow,
      );

      expect(summary.totalIncome, 15000.0);
      expect(summary.totalExpense, 0.0);
      expect(summary.balance, 15000.0);
      expect(summary.accountOpeningIncome, 15000.0);
      expect(summary.carriedForwardFromPrevious, 0.0);
      expect(summary.getIncomeSubtitle('₹'), 'Incl. ₹15,000 from accounts');
    });

    test('Remaining balance of October transfers to November automatically', () {
      final accounts = [
        AccountModel(
          id: 1,
          name: 'Home',
          type: 'cash',
          openingBalance: 5000.0,
          colorValue: 0,
          iconCode: 0,
          createdAt: DateTime(2026, 10, 1),
        ),
        AccountModel(
          id: 2,
          name: 'Bank',
          type: 'bank',
          openingBalance: 10000.0,
          colorValue: 0,
          iconCode: 0,
          createdAt: DateTime(2026, 10, 1),
        ),
      ];

      // October expense of 3,000
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 3000.0,
          type: 'expense',
          categoryId: 1,
          date: DateTime(2026, 10, 20),
          paymentMode: 'Cash',
        ),
      ];

      // View October
      final octSummary = FinancialCalculator.calculate(
        transactions: transactions,
        accounts: accounts,
        targetDate: DateTime(2026, 10, 1),
        period: 'Monthly',
        now: fixedNow,
      );

      expect(octSummary.totalIncome, 15000.0);
      expect(octSummary.totalExpense, 3000.0);
      expect(octSummary.balance, 12000.0);

      // Shift to November (the immediate next month)
      final novSummary = FinancialCalculator.calculate(
        transactions: transactions,
        accounts: accounts,
        targetDate: DateTime(2026, 11, 1),
        period: 'Monthly',
        now: fixedNow,
      );

      // November should receive October remaining balance (12,000)
      expect(novSummary.totalIncome, 12000.0);
      expect(novSummary.totalExpense, 0.0);
      expect(novSummary.balance, 12000.0);
      expect(novSummary.carriedForwardFromPrevious, 12000.0);
      expect(novSummary.carriedForwardFromMonthName, 'Oct');
      expect(novSummary.getIncomeSubtitle('₹'), 'Incl. ₹12,000 from Oct');
    });

    test('Condition: amount does NOT automatically propagate to all future months beyond next month', () {
      final accounts = [
        AccountModel(
          id: 1,
          name: 'Home',
          type: 'cash',
          openingBalance: 15000.0,
          colorValue: 0,
          iconCode: 0,
          createdAt: DateTime(2026, 10, 1),
        ),
      ];

      // Fixed current month is October 2026
      // November 2026 is next month (shows rollover 15,000)
      final novSummary = FinancialCalculator.calculate(
        transactions: [],
        accounts: accounts,
        targetDate: DateTime(2026, 11, 1),
        period: 'Monthly',
        now: fixedNow,
      );
      expect(novSummary.totalIncome, 15000.0);

      // December 2026 is 2 months away (beyond next month): it must NOT automatically show rollover
      final decSummary = FinancialCalculator.calculate(
        transactions: [],
        accounts: accounts,
        targetDate: DateTime(2026, 12, 1),
        period: 'Monthly',
        now: fixedNow,
      );
      expect(decSummary.totalIncome, 0.0);
      expect(decSummary.balance, 0.0);
      expect(decSummary.carriedForwardFromPrevious, 0.0);
    });

    test('Past months before account creation do not show rollover or accounts income', () {
      final accounts = [
        AccountModel(
          id: 1,
          name: 'Home',
          type: 'cash',
          openingBalance: 15000.0,
          colorValue: 0,
          iconCode: 0,
          createdAt: DateTime(2026, 10, 1),
        ),
      ];

      final sepSummary = FinancialCalculator.calculate(
        transactions: [],
        accounts: accounts,
        targetDate: DateTime(2026, 9, 1),
        period: 'Monthly',
        now: fixedNow,
      );
      expect(sepSummary.totalIncome, 0.0);
      expect(sepSummary.balance, 0.0);
    });
  });
}
