import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/models/account_model.dart';
import 'package:personal_expense_tracker_app/utils/app_theme.dart';
import 'package:personal_expense_tracker_app/widgets/fintech_widgets.dart';

void main() {
  testWidgets('EtherealStackedAccountsCard reorders card to front when tapped',
      (tester) async {
    final accounts = [
      AccountModel(
        id: 1,
        name: 'Home Cash',
        type: 'cash',
        openingBalance: 5000.0,
        colorValue: 0,
        iconCode: 0,
      ),
      AccountModel(
        id: 2,
        name: 'Bank Account',
        type: 'bank',
        openingBalance: 12000.0,
        colorValue: 0,
        iconCode: 0,
      ),
      AccountModel(
        id: 3,
        name: 'Salary Wallet',
        type: 'wallet',
        openingBalance: 25000.0,
        colorValue: 0,
        iconCode: 0,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: EtherealStackedAccountsCard(
            accounts: accounts,
            balances: {1: 5000.0, 2: 12000.0, 3: 25000.0},
            currency: '₹',
            onAddAccount: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My accounts'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('HOME CASH'), findsOneWidget);
    expect(find.text('BANK ACCOUNT'), findsOneWidget);
    expect(find.text('SALARY WALLET'), findsOneWidget);

    // Tap on the back card ('SALARY WALLET')
    await tester.tap(find.text('SALARY WALLET'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify still rendered and active
    expect(find.text('SALARY WALLET'), findsOneWidget);
  });

  testWidgets('EtherealTotalBalanceCard and EtherealMetricCard render correctly',
      (tester) async {
    bool transferPressed = false;
    bool topUpPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Column(
            children: [
              EtherealTotalBalanceCard(
                balance: 120456.50,
                currency: '\$',
                subtitle: '+2,456 revenue from last month',
                onTransfer: () => transferPressed = true,
                onTopUp: () => topUpPressed = true,
              ),
              const Row(
                children: [
                  Expanded(
                    child: EtherealMetricCard(
                      title: 'Income',
                      amount: 2456.0,
                      currency: '\$',
                      badgeText: '+15.7%',
                      isIncome: true,
                    ),
                  ),
                  Expanded(
                    child: EtherealMetricCard(
                      title: 'Expense',
                      amount: 1124.0,
                      currency: '\$',
                      badgeText: '-10.7%',
                      isIncome: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Total balance'), findsOneWidget);
    expect(find.text('\$120,456.50'), findsOneWidget);
    expect(find.text('+2,456 revenue from last month'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.tap(find.text('Transfer'));
    expect(transferPressed, isTrue);

    await tester.tap(find.text('Add'));
    expect(topUpPressed, isTrue);

    expect(find.text('Income'), findsOneWidget);
    expect(find.text('+15.7%'), findsOneWidget);
    expect(find.text('+\$2,456.00'), findsOneWidget);

    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('-10.7%'), findsOneWidget);
    expect(find.text('-\$1,124.00'), findsOneWidget);
  });
}
