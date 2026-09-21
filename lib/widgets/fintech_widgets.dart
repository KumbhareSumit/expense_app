import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';

/// Clean, reusable Category Icon chip with dark tint container background
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
    // Specific custom fintech tints
    Color tint = color.withValues(alpha: 0.16);
    if (color.toARGB32() == 0xFF3EA8FF) {
      tint = const Color(0xFF12283A);
    } else if (color.toARGB32() == 0xFFFF7A6B) {
      tint = const Color(0xFF2E1815);
    } else if (color.toARGB32() == 0xFFB58CFF) {
      tint = const Color(0xFF241838);
    } else if (color.toARGB32() == 0xFF3EE6B0) {
      tint = const Color(0xFF0E2922);
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

/// Hero balance card with radial dark teal gradient, sparkline, and month chip
class BalanceCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0.00');
    final formattedBalance = currencyFormat.format(balance);

    String? budgetLeftText;
    if (monthlyBudget != null && monthlyBudget! > 0) {
      final left = (monthlyBudget! - (monthlyExpense ?? 0)).clamp(0.0, double.infinity);
      budgetLeftText = '$currency${NumberFormat('#,##0').format(left)} left this month';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FintechColors.heroBorder, width: 1.0),
        gradient: const RadialGradient(
          center: Alignment(0.85, -0.65),
          radius: 1.25,
          colors: [
            FintechColors.heroTop,
            FintechColors.heroBottom,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Sparkline background illustration
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CustomPaint(
                painter: _SparklinePainter(color: FintechColors.accent),
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
                    const Text(
                      'Total balance',
                      style: TextStyle(
                        color: FintechColors.mutedText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (budgetLeftText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: FintechColors.cardSurface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: FintechColors.cardBorder, width: 1),
                        ),
                        child: Text(
                          budgetLeftText,
                          style: const TextStyle(
                            color: FintechColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$currency$formattedBalance',
                  style: const TextStyle(
                    color: FintechColors.primaryText,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontFeatures: [FontFeature.tabularFigures()],
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

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(0, h * 0.85);
    path.cubicTo(w * 0.25, h * 0.80, w * 0.4, h * 0.95, w * 0.65, h * 0.60);
    path.cubicTo(w * 0.80, h * 0.40, w * 0.90, h * 0.50, w, h * 0.35);

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.35, w, h * 0.65));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Compact account pill for the accounts row
class AccountPill extends StatelessWidget {
  final String name;
  final double balance;
  final Color color;
  final String currency;
  final VoidCallback? onTap;

  const AccountPill({
    super.key,
    required this.name,
    required this.balance,
    required this.color,
    this.currency = '₹',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final roundedAmount = NumberFormat('#,##0').format(balance.abs());
    final sign = balance < 0 ? '-' : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: FintechColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FintechColors.cardBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                color: FintechColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign$currency$roundedAmount',
              style: const TextStyle(
                color: FintechColors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
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
                style: const TextStyle(
                  color: FintechColors.mutedText,
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
              style: const TextStyle(
                color: FintechColors.mutedText,
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
    final isIncome = type == 'income';
    final isExpense = type == 'expense';
    final sign = isIncome ? '+' : (isExpense ? '-' : '');
    final amountColor = isIncome
        ? FintechColors.income
        : (isExpense ? FintechColors.expense : FintechColors.primaryText);
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
                    style: const TextStyle(
                      color: FintechColors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: FintechColors.mutedText,
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
    final formattedNet = NumberFormat('#,##0.00').format(netAmount.abs());
    final isPositive = netAmount > 0;
    final isNegative = netAmount < 0;
    final sign = isPositive ? '+' : (isNegative ? '-' : '');
    final color = isPositive
        ? FintechColors.income
        : (isNegative ? FintechColors.expense : FintechColors.mutedText);

    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateTitle,
            style: const TextStyle(
              color: FintechColors.mutedText,
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
    final progress = limit <= 0 ? 0.0 : (spent / limit);
    final isExceeded = progress >= 1.0;
    final isNearLimit = progress >= 0.9;
    final progressColor = isExceeded || isNearLimit ? FintechColors.expense : FintechColors.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FintechColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FintechColors.cardBorder, width: 1),
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
                      style: const TextStyle(
                        color: FintechColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currency${NumberFormat('#,##0').format(spent)} of $currency${NumberFormat('#,##0').format(limit)}',
                      style: const TextStyle(
                        color: FintechColors.mutedText,
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
                  icon: const Icon(Icons.edit_outlined, size: 18, color: FintechColors.mutedText),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF1F2A27),
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
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: FintechColors.accent,
          foregroundColor: const Color(0xFF06231B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: const Color(0xFF06231B)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF06231B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
