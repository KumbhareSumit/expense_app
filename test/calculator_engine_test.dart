import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/utils/calculator_engine.dart';

void main() {
  group('CalculatorEngine - Evaluation', () {
    test('Basic numbers', () {
      expect(CalculatorEngine.evaluate('150'), 150.0);
      expect(CalculatorEngine.evaluate('150.50'), 150.5);
      expect(CalculatorEngine.evaluate('0'), 0.0);
    });

    test('Addition & Subtraction', () {
      expect(CalculatorEngine.evaluate('100 + 50'), 150.0);
      expect(CalculatorEngine.evaluate('100 - 30'), 70.0);
      expect(CalculatorEngine.evaluate('100 + 50 - 25'), 125.0);
    });

    test('Multiplication & Division', () {
      expect(CalculatorEngine.evaluate('10 * 5'), 50.0);
      expect(CalculatorEngine.evaluate('10 × 5'), 50.0);
      expect(CalculatorEngine.evaluate('100 / 4'), 25.0);
      expect(CalculatorEngine.evaluate('100 ÷ 4'), 25.0);
    });

    test('Operator Precedence (PEMDAS)', () {
      expect(CalculatorEngine.evaluate('10 + 5 * 2'), 20.0);
      expect(CalculatorEngine.evaluate('10 + 5 × 2'), 20.0);
      expect(CalculatorEngine.evaluate('20 - 10 / 2'), 15.0);
      expect(CalculatorEngine.evaluate('20 - 10 ÷ 2'), 15.0);
    });

    test('Decimals with operators', () {
      expect(CalculatorEngine.evaluate('10.5 + 4.5 * 2'), 19.5);
      expect(CalculatorEngine.evaluate('2.5 * 4'), 10.0);
    });

    test('Trailing operators', () {
      expect(CalculatorEngine.evaluate('100 + '), 100.0);
      expect(CalculatorEngine.evaluate('100 × '), 100.0);
    });

    test('Negative numbers', () {
      expect(CalculatorEngine.evaluate('-50 + 100'), 50.0);
    });

    test('Division by zero', () {
      expect(CalculatorEngine.evaluate('100 / 0'), isNull);
    });

    test('Empty or invalid expressions', () {
      expect(CalculatorEngine.evaluate(''), isNull);
      expect(CalculatorEngine.evaluate('   '), isNull);
      expect(CalculatorEngine.evaluate('+'), isNull);
    });
  });

  group('CalculatorEngine - Formatting', () {
    test('Formats integer results without decimal point', () {
      expect(CalculatorEngine.formatResult(150.0), '150');
      expect(CalculatorEngine.formatResult(0.0), '0');
    });

    test('Formats decimal results cleanly', () {
      expect(CalculatorEngine.formatResult(150.5), '150.5');
      expect(CalculatorEngine.formatResult(150.25), '150.25');
    });
  });

  group('CalculatorEngine - Key Press Handling', () {
    test('Typing digits', () {
      String expr = '';
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '1');
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '2');
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '0');
      expect(expr, '120');
    });

    test('Typing operations', () {
      String expr = '100';
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '+');
      expect(expr, '100 + ');
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '5');
      expect(expr, '100 + 5');
    });

    test('Replacing operator', () {
      String expr = '100 + ';
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '×');
      expect(expr, '100 × ');
    });

    test('Decimal point handling', () {
      String expr = '12';
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '.');
      expect(expr, '12.');
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '.');
      expect(expr, '12.'); // does not duplicate decimal point
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '5');
      expect(expr, '12.5');
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '+');
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '.');
      expect(expr, '12.5 + 0.');
    });

    test('Backspace and Clear', () {
      String expr = '120';
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '⌫');
      expect(expr, '12');
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: 'C');
      expect(expr, '');
    });

    test('Equals key evaluates formula', () {
      String expr = '100 + 50';
      expr = CalculatorEngine.handleKeyPress(currentExpression: expr, key: '=');
      expect(expr, '150');
    });
  });
}

