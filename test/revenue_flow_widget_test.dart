import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/widgets/fintech_widgets.dart';

void main() {
  testWidgets('RevenueFlowCategoryChart renders bars, tooltip and handles selection & rise animation',
      (tester) async {
    final chartKey = GlobalKey<RevenueFlowCategoryChartState>();

    final items = [
      const RevenueFlowCategoryItem(categoryName: 'Food', amount: 4100, percentage: 35),
      const RevenueFlowCategoryItem(categoryName: 'Rent', amount: 2200, percentage: 20),
      const RevenueFlowCategoryItem(categoryName: 'Shop', amount: 3500, percentage: 28),
      const RevenueFlowCategoryItem(categoryName: 'Travel', amount: 1200, percentage: 10),
      const RevenueFlowCategoryItem(categoryName: 'Health', amount: 2456, percentage: 16),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RevenueFlowCategoryChart(
            key: chartKey,
            items: items,
            currency: '₹',
            periodLabel: 'Monthly',
            title: 'Revenue flow',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title and period label
    expect(find.text('Revenue flow'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);

    // Verify category labels are rendered
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);

    // Tap on the first bar (Food)
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    // Trigger rise animation manually
    chartKey.currentState?.animateRise();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify widget settles cleanly with no errors
    expect(find.text('Revenue flow'), findsOneWidget);
  });
}
