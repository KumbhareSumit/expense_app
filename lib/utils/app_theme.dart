import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class MoneyColors extends ThemeExtension<MoneyColors> {
  final Color income;
  final Color expense;
  final Color warning;
  final Color muted;

  const MoneyColors({
    required this.income,
    required this.expense,
    required this.warning,
    required this.muted,
  });

  @override
  MoneyColors copyWith({
    Color? income,
    Color? expense,
    Color? warning,
    Color? muted,
  }) {
    return MoneyColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
      muted: muted ?? this.muted,
    );
  }

  @override
  MoneyColors lerp(covariant MoneyColors? other, double t) {
    if (other == null) return this;
    return MoneyColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

class AppTheme {
  static const seedColor = Color(0xFF176B5B);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    return _buildTheme(
      scheme,
      const MoneyColors(
        income: Color(0xFF16734A), // ~5.85:1 on white — solid AA pass
        expense: Color(0xFFB3261E), // ~6.54:1 on white — solid AA pass
        warning: Color(
          0xFF7A5200,
        ), // ~6.20:1 on white — fixed from 0xFF9A6700 (was borderline 4.86:1)
        muted: Color(0xFF68716D), // ~5.04:1 on white — good for secondary text
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return _buildTheme(
      scheme,
      const MoneyColors(
        income: Color(0xFF63D79B), // ~7.33:1 on dark surface — excellent
        expense: Color(0xFFFF8A80), // ~5.75:1 on dark surface — good
        warning: Color(0xFFFFC857), // ~8.53:1 on dark surface — excellent
        muted: Color(0xFFB5C0BA), // ~7.01:1 on dark surface — excellent
      ),
    );
  }

  static ThemeData _buildTheme(ColorScheme scheme, MoneyColors moneyColors) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: baseTextTheme.copyWith(
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontFamily: null),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontFamily: null),
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontFamily: null),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        surfaceTintColor: scheme.surfaceTint,
        shadowColor: scheme.shadow.withValues(alpha: .18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          baseTextTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      extensions: [moneyColors],
    );
  }
}

extension MoneyColorsContext on BuildContext {
  MoneyColors get moneyColors => Theme.of(this).extension<MoneyColors>()!;
}
