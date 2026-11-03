import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/utils/app_theme.dart';
import 'package:personal_expense_tracker_app/widgets/calculator_keyboard.dart';

void main() {
  testWidgets('CalculatorKeyboard renders keys and fires callbacks correctly', (
    WidgetTester tester,
  ) async {
    final pressedKeys = <String>[];
    var backspaceFired = false;
    var clearFired = false;
    var equalsFired = false;
    var doneFired = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          extensions: const [FintechColors.darkThemeColors],
        ),
        home: Scaffold(
          body: CalculatorKeyboard(
            currentExpression: '100 + 50',
            currencySymbol: '\$',
            onKeyPressed: (key) => pressedKeys.add(key),
            onBackspace: () => backspaceFired = true,
            onClear: () => clearFired = true,
            onEquals: () => equalsFired = true,
            onDone: () => doneFired = true,
          ),
        ),
      ),
    );

    // Verify preview display
    expect(find.text('= \$150'), findsOneWidget);

    // Tap number 7
    await tester.tap(find.text('7'));
    expect(pressedKeys, contains('7'));

    // Tap plus +
    await tester.tap(find.text('+'));
    expect(pressedKeys, contains('+'));

    // Tap equals =
    await tester.tap(find.text('='));
    expect(equalsFired, isTrue);

    // Tap check / done
    await tester.tap(find.byIcon(Icons.check));
    expect(doneFired, isTrue);

    // Tap backspace
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    expect(backspaceFired, isTrue);

    // Tap clear
    await tester.tap(find.text('C'));
    expect(clearFired, isTrue);
  });
}

