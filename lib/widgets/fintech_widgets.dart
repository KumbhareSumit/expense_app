import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account_model.dart';
import '../utils/app_theme.dart';

/// Clean, reusable Category Icon chip with tint container background
class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color tint = color.withValues(alpha: isDark ? 0.16 : 0.12);

    if (isDark) {
      if (color.toARGB32() == 0xFF3EA8FF) {
        tint = const Color(0xFF12283A);
      } else if (color.toARGB32() == 0xFFFF7A6B) {
        tint = const Color(0xFF2E1815);
      } else if (color.toARGB32() == 0xFFB58CFF) {
        tint = const Color(0xFF241838);
      } else if (color.toARGB32() == 0xFF3EE6B0) {
        tint = const Color(0xFF0E2922);
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

/// Hero balance card with dynamic financial health theme, animated gentle wave, and monthly budget tracker
class BalanceCard extends StatefulWidget {
  final double balance;
  final double? monthlyBudget;
  final double? monthlyExpense;
  final String currency;

  const BalanceCard({
    super.key,
    required this.balance,
    this.monthlyBudget,
    this.monthlyExpense,
    this.currency = '₹',
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0.00');
    final formattedBalance = currencyFormat.format(widget.balance);
    final fintech = context.fintech;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    Color topGradient;
    Color bottomGradient;
    Color borderColor;

    if (widget.monthlyBudget != null && widget.monthlyBudget! > 0) {
      final remaining = (widget.monthlyBudget! - (widget.monthlyExpense ?? 0));
      final ratio = remaining / widget.monthlyBudget!;

      if (ratio >= 0.40 && widget.balance > 0) {
        // Healthy - Green
        statusColor = isDark ? fintech.income : const Color(0xFF059669);
        topGradient = isDark ? const Color(0xFF12382F) : const Color(0xFFE8F8F2);
        bottomGradient = isDark ? const Color(0xFF0F1E1B) : const Color(0xFFFFFFFF);
        borderColor = isDark ? const Color(0xFF1E3A34) : const Color(0xFFC7EEDB);
      } else if (ratio >= 0.15 && widget.balance > 0) {
        // Warning / Moderate - Yellow
        statusColor = isDark ? fintech.warning : const Color(0xFFD97706);
        topGradient = isDark ? const Color(0xFF382F12) : const Color(0xFFFFF7E6);
        bottomGradient = isDark ? const Color(0xFF1E1A0F) : const Color(0xFFFFFFFF);
        borderColor = isDark ? const Color(0xFF3A321E) : const Color(0xFFFFE5B3);
      } else {
        // Critical / Low - Red
        statusColor = isDark ? fintech.expense : const Color(0xFFDC2626);
        topGradient = isDark ? const Color(0xFF381515) : const Color(0xFFFFECEC);
        bottomGradient = isDark ? const Color(0xFF1E0F0F) : const Color(0xFFFFFFFF);
        borderColor = isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFFD1D1);
      }
    } else {
      if (widget.balance > 5000) {
        statusColor = isDark ? fintech.income : const Color(0xFF059669);
        topGradient = isDark ? const Color(0xFF12382F) : const Color(0xFFE8F8F2);
        bottomGradient = isDark ? const Color(0xFF0F1E1B) : const Color(0xFFFFFFFF);
        borderColor = isDark ? const Color(0xFF1E3A34) : const Color(0xFFC7EEDB);
      } else if (widget.balance >= 1500) {
        statusColor = isDark ? fintech.warning : const Color(0xFFD97706);
        topGradient = isDark ? const Color(0xFF382F12) : const Color(0xFFFFF7E6);
        bottomGradient = isDark ? const Color(0xFF1E1A0F) : const Color(0xFFFFFFFF);
        borderColor = isDark ? const Color(0xFF3A321E) : const Color(0xFFFFE5B3);
      } else {
        statusColor = isDark ? fintech.expense : const Color(0xFFDC2626);
        topGradient = isDark ? const Color(0xFF381515) : const Color(0xFFFFECEC);
        bottomGradient = isDark ? const Color(0xFF1E0F0F) : const Color(0xFFFFFFFF);
        borderColor = isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFFD1D1);
      }
    }

    String? budgetLeftText;
    if (widget.monthlyBudget != null && widget.monthlyBudget! > 0) {
      final left = (widget.monthlyBudget! - (widget.monthlyExpense ?? 0)).clamp(0.0, double.infinity);
      budgetLeftText = '${widget.currency}${NumberFormat('#,##0').format(left)} left this month';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0C1A14).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
        gradient: RadialGradient(
          center: const Alignment(0.85, -0.65),
          radius: 1.25,
          colors: [
            topGradient,
            bottomGradient,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated gentle flowing wave background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _AnimatedWavePainter(
                      progress: _waveController.value,
                      color: statusColor,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total balance',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFA5B8B3) : fintech.mutedText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (budgetLeftText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF141C1A).withValues(alpha: 0.8)
                              : statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: statusColor.withValues(alpha: isDark ? 0.35 : 0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          budgetLeftText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.currency}$formattedBalance',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE8F1EE) : fintech.primaryText,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _AnimatedWavePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final baseHeight = h * 0.78;
    final amplitude = 6.0;
    final phase = progress * 2 * math.pi;

    // 1. Secondary subtle ambient wave for depth
    final secondaryPath = Path();
    secondaryPath.moveTo(0, baseHeight);
    for (double x = 0; x <= w; x += 4) {
      final y = baseHeight +
          amplitude * 0.7 * math.sin((x / w) * 2 * math.pi * 1.2 - phase * 0.8 + math.pi / 4);
      secondaryPath.lineTo(x, y);
    }
    final secondaryPaint = Paint()
      ..color = color.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(secondaryPath, secondaryPaint);

    // 2. Primary glowing smooth flowing wave
    final mainPath = Path();
    mainPath.moveTo(0, baseHeight);
    for (double x = 0; x <= w; x += 3) {
      final y = baseHeight +
          amplitude * math.sin((x / w) * 2 * math.pi * 1.0 - phase) +
          (amplitude * 0.3) * math.sin((x / w) * 4 * math.pi * 1.0 - phase * 1.4);
      mainPath.lineTo(x, y);
    }

    // Glowing main stroke
    final mainStrokePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(mainPath, mainStrokePaint);

    // Soft gradient fill underneath wave
    final fillPath = Path.from(mainPath)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.16),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, baseHeight - amplitude * 1.5, w, h - (baseHeight - amplitude * 1.5)));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Compact account pill for the accounts row
class AccountPill extends StatelessWidget {
  final String name;
  final double balance;
  final Color color;
  final String currency;
  final VoidCallback? onTap;
  final bool isExpanded;

  const AccountPill({
    super.key,
    required this.name,
    required this.balance,
    required this.color,
    this.currency = '₹',
    this.onTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final roundedAmount = NumberFormat('#,##0').format(balance.abs());
    final sign = balance < 0 ? '-' : '';
    final fintech = context.fintech;

    Widget nameWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        isExpanded
            ? Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fintech.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Text(
                name,
                style: TextStyle(
                  color: fintech.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: fintech.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fintech.cardBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            isExpanded ? Flexible(child: nameWidget) : nameWidget,
            const SizedBox(width: 10),
            Text(
              '$sign$currency$roundedAmount',
              style: TextStyle(
                color: fintech.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat card for Income / Expense / Savings metrics
class StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData? icon;
  final String currency;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    this.icon,
    this.currency = '₹',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat('#,##0.00').format(amount);
    final fintech = context.fintech;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  color: fintech.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currency$formattedAmount',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: fintech.mutedText,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern fintech transaction tile
class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final String type;
  final Color categoryColor;
  final IconData icon;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.categoryColor,
    required this.icon,
    this.currency = '₹',
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final fintech = context.fintech;
    final isIncome = type == 'income';
    final isExpense = type == 'expense';
    final sign = isIncome ? '+' : (isExpense ? '-' : '');
    final amountColor = isIncome
        ? fintech.income
        : (isExpense ? fintech.expense : fintech.primaryText);
    final formattedAmount = NumberFormat('#,##0.00').format(amount);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CategoryIcon(icon: icon, color: categoryColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: fintech.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: fintech.mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$sign$currency$formattedAmount',
              style: TextStyle(
                color: amountColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date group section header with daily net total
class DateHeader extends StatelessWidget {
  final String dateTitle;
  final double netAmount;
  final String currency;

  const DateHeader({
    super.key,
    required this.dateTitle,
    required this.netAmount,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final fintech = context.fintech;
    final formattedNet = NumberFormat('#,##0.00').format(netAmount.abs());
    final isPositive = netAmount > 0;
    final isNegative = netAmount < 0;
    final sign = isPositive ? '+' : (isNegative ? '-' : '');
    final color = isPositive
        ? fintech.income
        : (isNegative ? fintech.expense : fintech.mutedText);

    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateTitle,
            style: TextStyle(
              color: fintech.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$sign$currency$formattedNet',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Category budget card with progress bar
class BudgetCategoryCard extends StatelessWidget {
  final String name;
  final double spent;
  final double limit;
  final Color color;
  final IconData icon;
  final String currency;
  final VoidCallback? onEdit;

  const BudgetCategoryCard({
    super.key,
    required this.name,
    required this.spent,
    required this.limit,
    required this.color,
    required this.icon,
    this.currency = '₹',
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final fintech = context.fintech;
    final progress = limit <= 0 ? 0.0 : (spent / limit);
    final isExceeded = progress >= 1.0;
    final isNearLimit = progress >= 0.9;
    final progressColor = isExceeded || isNearLimit ? fintech.expense : fintech.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryIcon(icon: icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: fintech.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currency${NumberFormat('#,##0').format(spent)} of $currency${NumberFormat('#,##0').format(limit)}',
                      style: TextStyle(
                        color: fintech.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 18, color: fintech.mutedText),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: fintech.cardBorder,
              color: progressColor,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned primary action button for screen bottoms
class PrimaryBottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const PrimaryBottomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fintech = context.fintech;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnTextColor = isDark ? const Color(0xFF06231B) : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: fintech.accent,
          foregroundColor: btnTextColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: btnTextColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: btnTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ethereal Stacked Accounts Widget matching Image 1
/// Allows tapping any background card to smoothly transition it to the front
class EtherealStackedAccountsCard extends StatefulWidget {
  final List<AccountModel> accounts;
  final Map<int, double> balances;
  final String currency;
  final VoidCallback onAddAccount;
  final ValueChanged<AccountModel>? onTapAccount;

  const EtherealStackedAccountsCard({
    super.key,
    required this.accounts,
    required this.balances,
    required this.currency,
    required this.onAddAccount,
    this.onTapAccount,
  });

  @override
  State<EtherealStackedAccountsCard> createState() =>
      _EtherealStackedAccountsCardState();
}

class _EtherealStackedAccountsCardState
    extends State<EtherealStackedAccountsCard> {
  late List<int> _cardOrder;

  static const List<List<Color>> _cardGradients = [
    [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)], // Deep Indigo Metal
    [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)], // Emerald Fintech
    [Color(0xFF18181B), Color(0xFF27272A), Color(0xFF3F3F46)], // Obsidian Carbon
    [Color(0xFF881337), Color(0xFF9F1239), Color(0xFFBE123C)], // Crimson Luxury
    [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF3B82F6)], // Royal Sapphire
    [Color(0xFF78350F), Color(0xFF92400E), Color(0xFFD97706)], // Amber Gold
    [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF2DD4BF)], // Midnight Teal
    [Color(0xFF334155), Color(0xFF475569), Color(0xFF64748B)], // Titanium Slate
  ];

  List<Color> _getAccountGradient(AccountModel account, int fallbackIndex) {
    if (account.colorValue != 0) {
      final base = Color(account.colorValue);
      final hsl = HSLColor.fromColor(base);
      final darker = hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
      final lighter = hsl.withLightness((hsl.lightness + 0.14).clamp(0.0, 1.0)).toColor();
      return [darker, base, lighter];
    }
    return _cardGradients[fallbackIndex % _cardGradients.length];
  }

  @override
  void initState() {
    super.initState();
    _initOrder();
  }

  @override
  void didUpdateWidget(covariant EtherealStackedAccountsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.accounts.length != oldWidget.accounts.length) {
      _initOrder();
    }
  }

  void _initOrder() {
    _cardOrder = List.generate(widget.accounts.length, (i) => i);
  }

  void _bringToFront(int rank) {
    if (rank <= 0 || rank >= _cardOrder.length) return;
    setState(() {
      final selected = _cardOrder.removeAt(rank);
      _cardOrder.insert(0, selected);
    });
  }

  void _nextCard() {
    if (_cardOrder.length <= 1) return;
    setState(() {
      final front = _cardOrder.removeAt(0);
      _cardOrder.add(front);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fintech = context.fintech;

    return Container(
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "My accounts" with count & "Add +" pill button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My accounts',
                    style: TextStyle(
                      color: fintech.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.accounts.length}',
                    style: TextStyle(
                      color: fintech.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onAddAccount,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Color(0xFF0F1016),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.add_rounded,
                          color: Color(0xFF0F1016), size: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stack of Cards
          if (widget.accounts.isEmpty)
            _buildEmptyCard(fintech)
          else
            _buildStackedDeck(fintech),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(FintechThemeColors fintech) {
    return InkWell(
      onTap: widget.onAddAccount,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card_rounded,
                size: 38, color: Colors.white),
            const SizedBox(height: 10),
            const Text(
              'No Accounts Added Yet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap here to add Cash, Bank, or Wallet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedDeck(FintechThemeColors fintech) {
    final visibleCount = math.min(widget.accounts.length, 3);
    const containerHeight = 250.0;
    const cardHeight = 180.0;

    // We render cards in reverse order (rank visibleCount-1 down to 0)
    // so rank 0 is at the top of the Flutter stack painting order
    final stackChildren = <Widget>[];

    for (int rank = visibleCount - 1; rank >= 0; rank--) {
      final accountIndex = _cardOrder[rank];
      final account = widget.accounts[accountIndex];
      final balance =
          widget.balances[account.id] ?? account.openingBalance;
      final gradient = _getAccountGradient(account, accountIndex);

      double topOffset;
      double horizontalMargin;
      double shadowOpacity;

      if (rank == 0) {
        // Front Card
        topOffset = visibleCount == 1 ? 0 : 54.0;
        horizontalMargin = 0.0;
        shadowOpacity = 0.40;
      } else if (rank == 1) {
        // Middle Card
        topOffset = visibleCount == 2 ? 0 : 27.0;
        horizontalMargin = 12.0;
        shadowOpacity = 0.22;
      } else {
        // Back Card
        topOffset = 0.0;
        horizontalMargin = 24.0;
        shadowOpacity = 0.14;
      }

      stackChildren.add(
        AnimatedPositioned(
          key: ValueKey(account.id ?? account.name),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          top: topOffset,
          left: horizontalMargin,
          right: horizontalMargin,
          height: cardHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (rank == 0) {
                _nextCard();
              } else {
                _bringToFront(rank);
              }
            },
            onVerticalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() > 50) {
                _nextCard();
              }
            },
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() > 50) {
                _nextCard();
              }
            },
            child: _buildCardItem(
              account: account,
              balance: balance,
              gradient: gradient,
              shadowOpacity: shadowOpacity,
              isFront: rank == 0,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() > 50) {
          _nextCard();
        }
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() > 50) {
          _nextCard();
        }
      },
      child: SizedBox(
        height: visibleCount == 1 ? cardHeight : containerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: stackChildren,
        ),
      ),
    );
  }

  Widget _buildCardItem({
    required AccountModel account,
    required double balance,
    required List<Color> gradient,
    required double shadowOpacity,
    required bool isFront,
  }) {
    final formattedBalance =
        NumberFormat('#,##0.00').format(balance.abs());
    final sign = balance < 0 ? '-' : '';

    // Calculate background brightness to ensure 100% crystal-clear contrast
    final avgLuminance = (gradient.first.computeLuminance() * 0.4 +
            gradient[gradient.length ~/ 2].computeLuminance() * 0.3 +
            gradient.last.computeLuminance() * 0.3);
    final isLight = avgLuminance > 0.52;

    final primaryTextColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final secondaryTextColor = isLight
        ? const Color(0xFF334155)
        : Colors.white.withValues(alpha: 0.85);
    final iconBgColor = isLight
        ? Colors.black.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.22);
    final chipBorderColor = isLight
        ? const Color(0xFFB8860B).withValues(alpha: 0.8)
        : const Color(0xFFFFE082).withValues(alpha: 0.9);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: isFront ? 18 : 10,
            offset: Offset(0, isFront ? 8 : 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle realistic specular diagonal sheen
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: isLight ? 0.20 : 0.12),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: isLight ? 0.04 : 0.15),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Top Row: Account Name, Real EMV Chip, NFC & masked card number
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getAccountIcon(account.type),
                            size: 15,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          account.name.toUpperCase(),
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '•••• ${(account.id ?? 1).toString().padLeft(4, '0')}',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Realistic EMV Chip & Contactless NFC icon
                Row(
                  children: [
                    // Metallic Gold EMV Chip
                    Container(
                      width: 28,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFE082),
                            Color(0xFFD4AF37),
                            Color(0xFFA67C00),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: chipBorderColor,
                          width: 0.6,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              width: 14,
                              height: 10,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Contactless NFC Symbol
                    Icon(
                      Icons.contactless_rounded,
                      size: 16,
                      color: secondaryTextColor.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Frosted Glass Pocket (as shown in fintech design)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isLight
                          ? [
                              Colors.black.withValues(alpha: 0.10),
                              Colors.black.withValues(alpha: 0.04),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.28),
                              Colors.white.withValues(alpha: 0.12),
                            ],
                    ),
                    border: Border(
                      top: BorderSide(
                        color: isLight
                            ? Colors.black.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount in place of card number (User requested)
                      Text(
                        '$sign${widget.currency} $formattedBalance',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Holder name & Type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            account.type.toUpperCase(),
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            isFront ? 'SWIPE / TAP FOR NEXT' : 'TAP TO SELECT',
                            style: TextStyle(
                              color: secondaryTextColor.withValues(alpha: 0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return Icons.account_balance_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'cash':
        return Icons.payments_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }
}

/// Vibrant Ethereal Total Balance Card matching Image 2
class EtherealTotalBalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final String? subtitle;
  final double? monthlyBudget;
  final double? spentAmount;
  final VoidCallback? onTransfer;
  final VoidCallback? onTopUp;
  final bool showActions;

  const EtherealTotalBalanceCard({
    super.key,
    required this.balance,
    this.currency = '₹',
    this.subtitle,
    this.monthlyBudget,
    this.spentAmount,
    this.onTransfer,
    this.onTopUp,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final formattedBalance =
        NumberFormat('#,##0.00').format(balance.abs());
    final sign = balance < 0 ? '-' : '';
    final bool hasActions =
        showActions && onTransfer != null && onTopUp != null;

    // Determine budget status & dynamic color indicator
    Widget? budgetBadge;
    if (monthlyBudget != null && monthlyBudget! > 0) {
      final spent = spentAmount ?? 0.0;
      final ratio = spent / monthlyBudget!;

      Color dotColor;
      Color statusTextColor;
      String budgetText;

      if (ratio <= 0.60) {
        // Green: Healthy / Full / Plenty remaining (spent <= 60%)
        dotColor = const Color(0xFF059669);
        statusTextColor = const Color(0xFF065F46);
        budgetText = '$currency${NumberFormat('#,##0').format(monthlyBudget)}';
      } else if (ratio <= 0.85) {
        // Yellow/Amber: Moderate / Warning (60% - 85% spent)
        dotColor = const Color(0xFFD97706);
        statusTextColor = const Color(0xFF92400E);
        budgetText = '$currency${NumberFormat('#,##0').format(monthlyBudget)}';
      } else {
        // Red: Critical / Near Limit or Exceeded (> 85% spent)
        dotColor = const Color(0xFFDC2626);
        statusTextColor = const Color(0xFF991B1B);
        final remaining = monthlyBudget! - spent;
        budgetText = remaining >= 0
            ? '$currency${NumberFormat('#,##0').format(monthlyBudget)}'
            : 'Over $currency${NumberFormat('#,##0').format(remaining.abs())}';
      }

      budgetBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dotColor.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Budget: $budgetText',
              style: TextStyle(
                color: statusTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB8F58E),
            Color(0xFF96F2AC),
            Color(0xFF72EEA5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF72EEA5).withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        hasActions ? 20 : 16,
        20,
        hasActions ? 20 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title on the left, Dynamic Budget badge in top-right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Total balance',
                style: TextStyle(
                  color: Color(0xFF0F1E13),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ?budgetBadge,
            ],
          ),
          const SizedBox(height: 6),

          // Main Big Balance
          Text(
            '$sign$currency$formattedBalance',
            style: const TextStyle(
              color: Color(0xFF0F1E13),
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle / Revenue info
          Text(
            subtitle ?? 'Available balance',
            style: const TextStyle(
              color: Color(0xFF1B3D23),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Action Pills Row: Transfer (black pill) & Add (white pill)
          if (hasActions) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                InkWell(
                  onTap: onTransfer,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1015),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Transfer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.swap_horiz_rounded,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: onTopUp,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xFF0E1015),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.add_rounded,
                            color: Color(0xFF0E1015), size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Ethereal Metric Card for Income & Expense matching Image 2
class EtherealMetricCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final String? subtitle;
  final String badgeText;
  final bool isIncome;
  final VoidCallback? onTap;

  const EtherealMetricCard({
    super.key,
    required this.title,
    required this.amount,
    this.currency = '₹',
    this.subtitle,
    required this.badgeText,
    required this.isIncome,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fintech = context.fintech;
    final formattedAmount =
        NumberFormat('#,##0.00').format(amount.abs());
    final badgeColor = isIncome ? fintech.income : fintech.expense;
    final badgeBg = isIncome
        ? const Color(0xFF1E3319)
        : const Color(0xFF331919);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fintech.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: fintech.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title & Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: fintech.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amount
            Text(
              '${isIncome ? '+' : '-'}$currency$formattedAmount',
              style: TextStyle(
                color: fintech.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle ??
                  (isIncome ? "This month's income" : "This month's expense"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fintech.mutedText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data model for an item in the Revenue Flow category chart
class RevenueFlowCategoryItem {
  final String categoryName;
  final double amount;
  final double percentage;
  final Color? color;
  final IconData? icon;

  const RevenueFlowCategoryItem({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    this.color,
    this.icon,
  });
}

/// Ethereal Revenue Flow bar chart matching high-end fintech aesthetics:
/// - Pill-shaped vertical bars
/// - Luminous lilac active bar with top ring indicator
/// - Floating dark glass tooltip with diagonal arrow badge & percentage
/// - Down-to-up rise transition on swipe up or interaction
class RevenueFlowCategoryChart extends StatefulWidget {
  final List<RevenueFlowCategoryItem> items;
  final String currency;
  final String periodLabel;
  final VoidCallback? onPeriodTap;
  final VoidCallback? onHeaderActionTap;
  final String title;

  const RevenueFlowCategoryChart({
    super.key,
    required this.items,
    this.currency = '₹',
    this.periodLabel = 'Monthly',
    this.onPeriodTap,
    this.onHeaderActionTap,
    this.title = 'Revenue flow',
  });

  @override
  State<RevenueFlowCategoryChart> createState() => RevenueFlowCategoryChartState();
}

class RevenueFlowCategoryChartState extends State<RevenueFlowCategoryChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    if (widget.items.isNotEmpty) {
      // Default to the last item or item with highest amount
      _selectedIndex = widget.items.length - 1;
    }
    _controller.forward();
  }

  @override
  void didUpdateWidget(RevenueFlowCategoryChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.periodLabel != widget.periodLabel) {
      if (widget.items.isNotEmpty) {
        if (_selectedIndex >= widget.items.length || _selectedIndex < 0) {
          _selectedIndex = widget.items.length - 1;
        }
      } else {
        _selectedIndex = -1;
      }
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers the smooth down-to-up rise transition animation
  void animateRise() {
    if (mounted) {
      _controller.forward(from: 0.0);
    }
  }

  String _formatShortAmount(double amount, String currency) {
    if (amount >= 1000000) {
      return '+$currency${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '+$currency${(amount / 1000).toStringAsFixed(1)}K';
    } else if (amount > 0) {
      return '+$currency${amount.toInt()}';
    } else {
      return '$currency 0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fintech = context.fintech;
    final items = widget.items;

    // Calculate max amount for scaling
    double maxAmt = 0.0;
    for (final it in items) {
      if (it.amount > maxAmt) maxAmt = it.amount;
    }
    if (maxAmt <= 0) maxAmt = 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF13141F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF232536), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Title, Period pill chip, and circular arrow button
          Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFFF2F2F7),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              // Period Pill
              InkWell(
                onTap: widget.onPeriodTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232536),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.periodLabel,
                    style: const TextStyle(
                      color: Color(0xFFD6D6E0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Circular Top-Right Action Button
              InkWell(
                onTap: widget.onHeaderActionTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.north_east_rounded,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Chart Area with Staggered Down-to-Up Pill Bars and Floating Tooltip
          if (items.isEmpty)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: Text(
                'No category data available',
                style: TextStyle(color: fintech.mutedText, fontSize: 13),
              ),
            )
          else
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    const double chartHeight = 210.0;
                    const double maxBarHeight = 150.0;
                    const double minBarHeight = 45.0;

                    final count = items.length;
                    final slotWidth = constraints.maxWidth / count;

                    // Tooltip geometry calculation
                    final selectedIndex = (_selectedIndex >= 0 &&
                            _selectedIndex < items.length)
                        ? _selectedIndex
                        : (items.length - 1);
                    final selectedItem = items[selectedIndex];

                    final selectedAmtRatio =
                        (selectedItem.amount / maxAmt).clamp(0.0, 1.0);
                    final selectedTargetBarHeight = minBarHeight +
                        selectedAmtRatio * (maxBarHeight - minBarHeight);

                    final selectedBarInterval = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        (selectedIndex * 0.08).clamp(0.0, 0.4),
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                    final selectedAnimHeight =
                        selectedTargetBarHeight * selectedBarInterval.value;

                    // Tooltip horizontal center alignment
                    final barCenterX = (selectedIndex + 0.5) * slotWidth;
                    double tooltipLeft = barCenterX -
                        (selectedIndex >= count / 2 ? 100 : 35);
                    tooltipLeft = tooltipLeft.clamp(4.0, constraints.maxWidth - 145.0);

                    final tooltipTop = (chartHeight - selectedAnimHeight - 52)
                        .clamp(0.0, chartHeight - 55.0);

                    return SizedBox(
                      height: chartHeight + 28, // includes category labels
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Bars & Labels Row
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(count, (index) {
                                final item = items[index];
                                final isSelected = index == _selectedIndex;

                                final amtRatio =
                                    (item.amount / maxAmt).clamp(0.0, 1.0);
                                final targetBarHeight = minBarHeight +
                                    amtRatio * (maxBarHeight - minBarHeight);

                                final barInterval = CurvedAnimation(
                                  parent: _controller,
                                  curve: Interval(
                                    (index * 0.08).clamp(0.0, 0.4),
                                    1.0,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );
                                final animHeight =
                                    targetBarHeight * barInterval.value;

                                final barWidth = (slotWidth * 0.72)
                                    .clamp(42.0, 58.0);

                                return SizedBox(
                                  width: slotWidth,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = index;
                                      });
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // The Pill Bar (Rising from bottom to top)
                                        SizedBox(
                                          height: maxBarHeight + 10,
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: barWidth,
                                              height: animHeight,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFFD6BAFD)
                                                    : const Color(0xFF6B5885),
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: const Color(
                                                                  0xFFD6BAFD)
                                                              .withValues(
                                                                  alpha: 0.35),
                                                          blurRadius: 16,
                                                          offset:
                                                              const Offset(0, 4),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Stack(
                                                children: [
                                                  // Top Ring indicator for active bar
                                                  if (isSelected)
                                                    Positioned(
                                                      top: 8,
                                                      left: 0,
                                                      right: 0,
                                                      child: Center(
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            border: Border.all(
                                                              color: Colors.white,
                                                              width: 3.2,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  // Bottom Amount inside bar
                                                  Positioned(
                                                    bottom: 8,
                                                    left: 2,
                                                    right: 2,
                                                    child: Text(
                                                      _formatShortAmount(
                                                          item.amount,
                                                          widget.currency),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B112B)
                                                            : const Color(
                                                                0xFFE6DEFA),
                                                        fontSize: 10.5,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w800
                                                            : FontWeight.w700,
                                                        letterSpacing: -0.2,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Category Name below bar
                                        Text(
                                          item.categoryName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF8E8EA2),
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          // Floating Glass Tooltip Badge above active bar
                          Positioned(
                            left: tooltipLeft,
                            top: tooltipTop,
                            child: AnimatedOpacity(
                              opacity: _controller.value > 0.4 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1F2F),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.45),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Circular Icon with diagonal arrow
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.north_east_rounded,
                                        size: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${widget.currency}${NumberFormat('#,##0.00').format(selectedItem.amount)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3,
                                            fontFeatures: [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '+${selectedItem.percentage.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.72),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}


