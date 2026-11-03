class CalculatorEngine {
  /// Evaluates an arithmetic expression containing +, -, *, ×, /, ÷, and numbers with decimals.
  /// Returns null if the expression cannot be evaluated.
  static double? evaluate(String expression) {
    if (expression.trim().isEmpty) return null;

    // Normalize operators
    String clean = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(',', '.')
        .replaceAll(' ', '');

    // Remove any trailing operator (e.g. "120 +" -> "120")
    while (clean.isNotEmpty && _isOperator(clean[clean.length - 1])) {
      clean = clean.substring(0, clean.length - 1);
    }

    if (clean.isEmpty) return null;

    try {
      final parser = _MathParser(clean);
      final result = parser.parse();
      if (result.isInfinite || result.isNaN) return null;
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Evaluates the expression for live preview.
  /// If the expression does not contain any operations, returns null (no preview needed).
  static double? evaluatePreview(String expression) {
    if (!containsOperation(expression)) return null;
    return evaluate(expression);
  }

  /// Checks if the expression contains mathematical operations.
  static bool containsOperation(String expression) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return false;

    // Check for +, *, ×, /, ÷ anywhere, or - not at the beginning
    if (trimmed.contains('+') ||
        trimmed.contains('×') ||
        trimmed.contains('*') ||
        trimmed.contains('÷') ||
        trimmed.contains('/')) {
      return true;
    }

    // Check for minus that is not just leading unary minus
    final afterUnary = trimmed.startsWith('-') ? trimmed.substring(1) : trimmed;
    return afterUnary.contains('-');
  }

  static bool _isOperator(String ch) {
    return ch == '+' ||
        ch == '-' ||
        ch == '*' ||
        ch == '×' ||
        ch == '/' ||
        ch == '÷';
  }

  /// Formats a double to a clean string without floating-point artifacts.
  static String formatResult(double value) {
    if (value.isInfinite || value.isNaN) return '0';

    // Round to 4 decimal places to prevent precision artifacts (e.g., 0.1 + 0.2)
    final rounded = (value * 10000).roundToDouble() / 10000;
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toInt().toString();
    }

    String formatted = rounded.toStringAsFixed(2);
    if (formatted.endsWith('.00')) {
      return formatted.substring(0, formatted.length - 3);
    } else if (formatted.endsWith('0') && formatted.contains('.')) {
      return formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  /// Appends or updates the expression when a key is pressed.
  static String handleKeyPress({
    required String currentExpression,
    required String key,
  }) {
    if (key == 'C') {
      return '';
    }

    if (key == '⌫') {
      if (currentExpression.isEmpty) return '';
      final trimmed = currentExpression.trimRight();
      if (trimmed.isEmpty) return '';
      if (_isOperator(trimmed[trimmed.length - 1])) {
        return trimmed.substring(0, trimmed.length - 1).trimRight();
      }
      return currentExpression.substring(0, currentExpression.length - 1);
    }

    if (key == '=') {
      final res = evaluate(currentExpression);
      if (res != null) {
        return formatResult(res);
      }
      return currentExpression;
    }

    // Math Operators: +, -, ×, ÷
    if (key == '+' || key == '-' || key == '×' || key == '÷') {
      if (currentExpression.trim().isEmpty) {
        if (key == '-') return '-';
        return '';
      }

      final trimmed = currentExpression.trimRight();
      final lastChar = trimmed[trimmed.length - 1];
      if (_isOperator(lastChar)) {
        // If replacing operator at the beginning (unary minus)
        if (trimmed == '-') {
          return key == '-' ? '-' : '';
        }
        return '${trimmed.substring(0, trimmed.length - 1)} $key ';
      }
      return '$trimmed $key ';
    }

    // Decimal Point
    if (key == '.') {
      if (currentExpression.isEmpty) {
        return '0.';
      }
      final tokens = currentExpression.split(RegExp(r'[\s\+\-\×\*\÷\/]+'));
      final lastToken = tokens.isNotEmpty ? tokens.last : '';
      if (lastToken.contains('.')) {
        return currentExpression; // Only one decimal per number token
      }
      if (currentExpression.endsWith(' ')) {
        return '${currentExpression}0.';
      }
      return '$currentExpression.';
    }

    // '00'
    if (key == '00') {
      if (currentExpression.isEmpty || currentExpression.endsWith(' ')) {
        return '${currentExpression}0';
      }
      final tokens = currentExpression.split(RegExp(r'[\s\+\-\×\*\÷\/]+'));
      final lastToken = tokens.isNotEmpty ? tokens.last : '';
      if (lastToken == '0') {
        return currentExpression; // Don't allow multiple leading zeros
      }
      return '$currentExpression$key';
    }

    // Digits: '0'-'9'
    if (currentExpression == '0') {
      return key;
    }
    if (currentExpression.endsWith(' 0')) {
      return '${currentExpression.substring(0, currentExpression.length - 1)}$key';
    }

    return '$currentExpression$key';
  }
}

class _MathParser {
  final String text;
  int _pos = 0;

  _MathParser(this.text);

  int get _currentChar => _pos < text.length ? text.codeUnitAt(_pos) : -1;

  void _nextChar() {
    _pos++;
  }

  bool _eat(int charToEat) {
    while (_currentChar == 32) {
      _nextChar();
    }
    if (_currentChar == charToEat) {
      _nextChar();
      return true;
    }
    return false;
  }

  double parse() {
    final x = _parseExpression();
    while (_currentChar == 32) {
      _nextChar();
    }
    if (_pos < text.length) {
      throw FormatException('Unexpected: ${text[_pos]}');
    }
    return x;
  }

  double _parseExpression() {
    double x = _parseTerm();
    while (true) {
      if (_eat(43)) {
        // '+'
        x += _parseTerm();
      } else if (_eat(45)) {
        // '-'
        x -= _parseTerm();
      } else {
        return x;
      }
    }
  }

  double _parseTerm() {
    double x = _parseFactor();
    while (true) {
      if (_eat(42)) {
        // '*'
        x *= _parseFactor();
      } else if (_eat(47)) {
        // '/'
        final divisor = _parseFactor();
        if (divisor == 0) throw Exception('Division by zero');
        x /= divisor;
      } else {
        return x;
      }
    }
  }

  double _parseFactor() {
    if (_eat(43)) return _parseFactor(); // unary '+'
    if (_eat(45)) return -_parseFactor(); // unary '-'

    double x;
    final startPos = _pos;
    if (_eat(40)) {
      // '('
      x = _parseExpression();
      _eat(41); // ')'
    } else if ((_currentChar >= 48 && _currentChar <= 57) ||
        _currentChar == 46) {
      // 0-9 or .
      while ((_currentChar >= 48 && _currentChar <= 57) ||
          _currentChar == 46) {
        _nextChar();
      }
      x = double.parse(text.substring(startPos, _pos));
    } else {
      throw FormatException(
        'Unexpected: ${_currentChar == -1 ? 'EOF' : String.fromCharCode(_currentChar)}',
      );
    }

    return x;
  }
}

