import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';
import '../utils/calculator_engine.dart';

class CalculatorKeyboard extends StatelessWidget {
  final String currentExpression;
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onEquals;
  final VoidCallback onDone;
  final VoidCallback? onToggleSystemKeyboard;
  final VoidCallback? onClose;
  final String? currencySymbol;

  const CalculatorKeyboard({
    super.key,
    required this.currentExpression,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onClear,
    required this.onEquals,
    required this.onDone,
    this.onToggleSystemKeyboard,
    this.onClose,
    this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fintech = context.fintech;
    final isDark = theme.brightness == Brightness.dark;

    final livePreview = CalculatorEngine.evaluatePreview(currentExpression);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13141F) : const Color(0xFFE8EEEC),
        border: Border(
          top: BorderSide(
            color: fintech.cardBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Toolbar: Live Calculation Preview & Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.calculate_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  if (livePreview != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: fintech.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '= ${currencySymbol ?? ''}${CalculatorEngine.formatResult(livePreview)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? fintech.accent : Colors.teal.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  else
                    const Expanded(
                      child: Text(
                        'Calculator Keypad',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (onToggleSystemKeyboard != null)
                    IconButton(
                      icon: const Icon(Icons.keyboard_outlined, size: 20),
                      tooltip: 'Switch to standard keyboard',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: onToggleSystemKeyboard,
                    ),
                  if (onClose != null)
                    IconButton(
                      icon: const Icon(Icons.keyboard_hide_outlined, size: 20),
                      tooltip: 'Hide keyboard',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: onClose,
                    ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),

            // Keypad Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: C, ÷, ×, ⌫
                  _buildKeyRow(
                    context,
                    [
                      _KeySpec(
                        label: 'C',
                        type: _KeyType.clear,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onClear();
                        },
                      ),
                      _KeySpec(
                        label: '÷',
                        type: _KeyType.operator,
                        onTap: () => _pressKey('÷'),
                      ),
                      _KeySpec(
                        label: '×',
                        type: _KeyType.operator,
                        onTap: () => _pressKey('×'),
                      ),
                      _KeySpec(
                        icon: Icons.backspace_outlined,
                        type: _KeyType.backspace,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onBackspace();
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          onClear();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Row 2: 7, 8, 9, -
                  _buildKeyRow(
                    context,
                    [
                      _KeySpec(
                        label: '7',
                        type: _KeyType.number,
                        onTap: () => _pressKey('7'),
                      ),
                      _KeySpec(
                        label: '8',
                        type: _KeyType.number,
                        onTap: () => _pressKey('8'),
                      ),
                      _KeySpec(
                        label: '9',
                        type: _KeyType.number,
                        onTap: () => _pressKey('9'),
                      ),
                      _KeySpec(
                        label: '-',
                        type: _KeyType.operator,
                        onTap: () => _pressKey('-'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Row 3: 4, 5, 6, +
                  _buildKeyRow(
                    context,
                    [
                      _KeySpec(
                        label: '4',
                        type: _KeyType.number,
                        onTap: () => _pressKey('4'),
                      ),
                      _KeySpec(
                        label: '5',
                        type: _KeyType.number,
                        onTap: () => _pressKey('5'),
                      ),
                      _KeySpec(
                        label: '6',
                        type: _KeyType.number,
                        onTap: () => _pressKey('6'),
                      ),
                      _KeySpec(
                        label: '+',
                        type: _KeyType.operator,
                        onTap: () => _pressKey('+'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Row 4: 1, 2, 3, =
                  _buildKeyRow(
                    context,
                    [
                      _KeySpec(
                        label: '1',
                        type: _KeyType.number,
                        onTap: () => _pressKey('1'),
                      ),
                      _KeySpec(
                        label: '2',
                        type: _KeyType.number,
                        onTap: () => _pressKey('2'),
                      ),
                      _KeySpec(
                        label: '3',
                        type: _KeyType.number,
                        onTap: () => _pressKey('3'),
                      ),
                      _KeySpec(
                        label: '=',
                        type: _KeyType.equals,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onEquals();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Row 5: 00, 0, ., Done
                  _buildKeyRow(
                    context,
                    [
                      _KeySpec(
                        label: '00',
                        type: _KeyType.number,
                        onTap: () => _pressKey('00'),
                      ),
                      _KeySpec(
                        label: '0',
                        type: _KeyType.number,
                        onTap: () => _pressKey('0'),
                      ),
                      _KeySpec(
                        label: '.',
                        type: _KeyType.number,
                        onTap: () => _pressKey('.'),
                      ),
                      _KeySpec(
                        icon: Icons.check,
                        type: _KeyType.done,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onDone();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pressKey(String key) {
    HapticFeedback.lightImpact();
    onKeyPressed(key);
  }

  Widget _buildKeyRow(BuildContext context, List<_KeySpec> keys) {
    return Row(
      children: keys.map((keySpec) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildKeyButton(context, keySpec),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton(BuildContext context, _KeySpec key) {
    final theme = Theme.of(context);
    final fintech = context.fintech;
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;
    Border? border;

    switch (key.type) {
      case _KeyType.number:
        bgColor = isDark ? const Color(0xFF1C1D2D) : Colors.white;
        fgColor = fintech.primaryText;
        border = Border.all(
          color: isDark ? const Color(0xFF282A3E) : const Color(0xFFD6E0DC),
          width: 0.8,
        );
        break;
      case _KeyType.operator:
        bgColor = isDark
            ? const Color(0xFF23253B)
            : const Color(0xFFDCE7E3);
        fgColor = isDark ? fintech.accent : Colors.teal.shade900;
        border = Border.all(
          color: isDark ? const Color(0xFF333752) : const Color(0xFFC7D9D3),
          width: 0.8,
        );
        break;
      case _KeyType.clear:
        bgColor = isDark
            ? fintech.expense.withValues(alpha: 0.15)
            : Colors.red.shade50;
        fgColor = isDark ? const Color(0xFFFF8B8B) : Colors.red.shade700;
        border = Border.all(
          color: isDark
              ? fintech.expense.withValues(alpha: 0.3)
              : Colors.red.shade200,
          width: 0.8,
        );
        break;
      case _KeyType.backspace:
        bgColor = isDark ? const Color(0xFF1E2030) : const Color(0xFFEDF2F0);
        fgColor = fintech.secondaryText;
        border = Border.all(
          color: isDark ? const Color(0xFF2C2F46) : const Color(0xFFD6E0DC),
          width: 0.8,
        );
        break;
      case _KeyType.equals:
        bgColor = isDark
            ? fintech.accent.withValues(alpha: 0.22)
            : Colors.teal.shade100;
        fgColor = isDark ? fintech.accent : Colors.teal.shade900;
        border = Border.all(
          color: isDark
              ? fintech.accent.withValues(alpha: 0.4)
              : Colors.teal.shade300,
          width: 0.8,
        );
        break;
      case _KeyType.done:
        bgColor = fintech.accent;
        fgColor = isDark ? const Color(0xFF092019) : Colors.white;
        break;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: key.onTap,
        onLongPress: key.onLongPress,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: border,
          ),
          alignment: Alignment.center,
          child: key.icon != null
              ? Icon(
                  key.icon,
                  size: 22,
                  color: fgColor,
                )
              : Text(
                  key.label ?? '',
                  style: TextStyle(
                    fontSize: key.type == _KeyType.operator ||
                            key.type == _KeyType.equals
                        ? 22
                        : 19,
                    fontWeight: key.type == _KeyType.number
                        ? FontWeight.w500
                        : FontWeight.bold,
                    color: fgColor,
                  ),
                ),
        ),
      ),
    );
  }
}

enum _KeyType {
  number,
  operator,
  clear,
  backspace,
  equals,
  done,
}

class _KeySpec {
  final String? label;
  final IconData? icon;
  final _KeyType type;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _KeySpec({
    this.label,
    this.icon,
    required this.type,
    required this.onTap,
    this.onLongPress,
  });
}

