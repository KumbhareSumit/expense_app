import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:personal_expense_tracker_app/utils/app_theme.dart';
import 'package:personal_expense_tracker_app/widgets/fintech_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final utf8String = String.fromCharCodes(
        message?.buffer.asUint8List() ?? <int>[],
      );
      if (utf8String.contains('.ttf') || utf8String.contains('fonts/')) {
        // Return minimal valid TTF font
        return ByteData(12);
      }
      return null;
    });
  });

  test('AppTheme produces valid distinct light and dark theme data', () {
    final lightColors = FintechColors.lightThemeColors;
    final darkColors = FintechColors.darkThemeColors;

    expect(lightColors.background, isNot(darkColors.background));
    expect(lightColors.cardSurface, isNot(darkColors.cardSurface));
    expect(lightColors.primaryText, isNot(darkColors.primaryText));
    expect(lightColors.mutedText, isNot(darkColors.mutedText));
    expect(lightColors.navBg, isNot(darkColors.navBg));
  });

  testWidgets('Fintech widgets render dynamically with light theme', (
    WidgetTester tester,
  ) async {
    final lightColors = FintechColors.lightThemeColors;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: lightColors.background,
          extensions: [lightColors],
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final fintech = context.fintech;
              return Container(
                color: fintech.background,
                child: Column(
                  children: [
                    StatCard(
                      title: 'Income',
                      amount: 5000,
                      currency: '\$',
                      icon: Icons.arrow_downward,
                      color: FintechColors.income,
                    ),
                    const DateHeader(dateTitle: 'TODAY', netAmount: 5000, currency: '\$'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Income'), findsOneWidget);
    expect(find.text('\$5,000.00'), findsWidgets);
    expect(find.text('TODAY'), findsOneWidget);
  });

  testWidgets('Fintech widgets render dynamically with dark theme', (
    WidgetTester tester,
  ) async {
    final darkColors = FintechColors.darkThemeColors;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: darkColors.background,
          extensions: [darkColors],
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final fintech = context.fintech;
              return Container(
                color: fintech.background,
                child: Column(
                  children: [
                    StatCard(
                      title: 'Expense',
                      amount: 1250,
                      currency: '\$',
                      icon: Icons.arrow_upward,
                      color: FintechColors.expense,
                    ),
                    const DateHeader(dateTitle: 'YESTERDAY', netAmount: -1250, currency: '\$'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('\$1,250.00'), findsWidgets);
    expect(find.text('YESTERDAY'), findsOneWidget);
  });
}
