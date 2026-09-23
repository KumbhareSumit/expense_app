import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

