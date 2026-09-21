import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FintechColors {
  static const background = Color(0xFF0C1110);
  static const cardSurface = Color(0xFF141C1A);
  static const cardBorder = Color(0xFF1F2A27);
  static const heroTop = Color(0xFF12382F);
  static const heroBottom = Color(0xFF0F1E1B);
  static const heroBorder = Color(0xFF1E3A34);
  static const accent = Color(0xFF3EE6B0);
  static const income = Color(0xFF3EE6B0);
  static const expense = Color(0xFFFF7A6B);
  static const warning = Color(0xFFFFB020);
  static const primaryText = Color(0xFFE8F1EE);
  static const secondaryText = Color(0xFFA5B8B3);
  static const mutedText = Color(0xFF7D8F8A);
  static const navBg = Color(0xFF0F1614);
  static const navBorder = Color(0xFF1A2421);
  static const navUnselected = Color(0xFF26302D);
}

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
  static const seedColor = FintechColors.accent;

  static const moneyColors = MoneyColors(
    income: FintechColors.income,
    expense: FintechColors.expense,
    warning: FintechColors.warning,
    muted: FintechColors.mutedText,
  );

  static ThemeData dark() {
    return _buildTheme();
  }

  static ThemeData light() {
    return _buildTheme();
  }

  static ThemeData _buildTheme() {
    final scheme = const ColorScheme.dark(
      surface: FintechColors.background,
      onSurface: FintechColors.primaryText,
      primary: FintechColors.accent,
      onPrimary: Color(0xFF06231B),
      secondary: FintechColors.accent,
      onSecondary: Color(0xFF06231B),
      error: FintechColors.expense,
      onError: Colors.white,
      outline: FintechColors.cardBorder,
      outlineVariant: FintechColors.cardBorder,
      surfaceContainerLowest: FintechColors.background,
      surfaceContainerLow: FintechColors.background,
      surfaceContainer: FintechColors.cardSurface,
      surfaceContainerHigh: FintechColors.cardSurface,
      surfaceContainerHighest: Color(0xFF1B2623),
    );

    final rawTextTheme = ThemeData.dark(useMaterial3: true).textTheme;
    final baseTextTheme = GoogleFonts.manropeTextTheme(rawTextTheme);

    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: FintechColors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: FintechColors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: FintechColors.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: FintechColors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: FintechColors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: FintechColors.background,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: FintechColors.cardBorder, width: 1),
        ),
        elevation: 0,
        color: FintechColors.cardSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FintechColors.cardSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: FintechColors.cardBorder, width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: FintechColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          color: FintechColors.primaryText,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: FintechColors.cardSurface,
        modalBackgroundColor: FintechColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          side: BorderSide(color: FintechColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF101715),
        hintStyle: const TextStyle(color: FintechColors.mutedText, fontSize: 13),
        labelStyle: const TextStyle(color: FintechColors.mutedText, fontSize: 13),
        prefixIconColor: FintechColors.mutedText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FintechColors.cardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FintechColors.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FintechColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FintechColors.expense, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FintechColors.accent,
          foregroundColor: const Color(0xFF06231B),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FintechColors.accent,
        foregroundColor: Color(0xFF06231B),
        elevation: 4,
        shape: CircleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: FintechColors.navBg,
        indicatorColor: FintechColors.accent,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: FintechColors.accent,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: FintechColors.mutedText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: 20,
              color: Color(0xFF06231B),
            );
          }
          return const IconThemeData(
            size: 20,
            color: FintechColors.mutedText,
          );
        }),
      ),
      extensions: const [moneyColors],
    );
  }
}

extension MoneyColorsContext on BuildContext {
  MoneyColors get moneyColors => Theme.of(this).extension<MoneyColors>()!;
}
