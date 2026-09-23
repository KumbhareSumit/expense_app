import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class FintechThemeColors extends ThemeExtension<FintechThemeColors> {
  final Color background;
  final Color cardSurface;
  final Color cardBorder;
  final Color heroTop;
  final Color heroBottom;
  final Color heroBorder;
  final Color accent;
  final Color income;
  final Color expense;
  final Color warning;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color navBg;
  final Color navBorder;
  final Color navUnselected;
  final Color inputFill;

  const FintechThemeColors({
    required this.background,
    required this.cardSurface,
    required this.cardBorder,
    required this.heroTop,
    required this.heroBottom,
    required this.heroBorder,
    required this.accent,
    required this.income,
    required this.expense,
    required this.warning,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.navBg,
    required this.navBorder,
    required this.navUnselected,
    required this.inputFill,
  });

  @override
  FintechThemeColors copyWith({
    Color? background,
    Color? cardSurface,
    Color? cardBorder,
    Color? heroTop,
    Color? heroBottom,
    Color? heroBorder,
    Color? accent,
    Color? income,
    Color? expense,
    Color? warning,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? navBg,
    Color? navBorder,
    Color? navUnselected,
    Color? inputFill,
  }) {
    return FintechThemeColors(
      background: background ?? this.background,
      cardSurface: cardSurface ?? this.cardSurface,
      cardBorder: cardBorder ?? this.cardBorder,
      heroTop: heroTop ?? this.heroTop,
      heroBottom: heroBottom ?? this.heroBottom,
      heroBorder: heroBorder ?? this.heroBorder,
      accent: accent ?? this.accent,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      navBg: navBg ?? this.navBg,
      navBorder: navBorder ?? this.navBorder,
      navUnselected: navUnselected ?? this.navUnselected,
      inputFill: inputFill ?? this.inputFill,
    );
  }

  @override
  FintechThemeColors lerp(covariant FintechThemeColors? other, double t) {
    if (other == null) return this;
    return FintechThemeColors(
      background: Color.lerp(background, other.background, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      heroTop: Color.lerp(heroTop, other.heroTop, t)!,
      heroBottom: Color.lerp(heroBottom, other.heroBottom, t)!,
      heroBorder: Color.lerp(heroBorder, other.heroBorder, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      navBg: Color.lerp(navBg, other.navBg, t)!,
      navBorder: Color.lerp(navBorder, other.navBorder, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
    );
  }
}

class FintechColors {
  // Dark mode constants (for fallback & legacy references)
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

  static const darkThemeColors = FintechThemeColors(
    background: Color(0xFF0C1110),
    cardSurface: Color(0xFF141C1A),
    cardBorder: Color(0xFF1F2A27),
    heroTop: Color(0xFF12382F),
    heroBottom: Color(0xFF0F1E1B),
    heroBorder: Color(0xFF1E3A34),
    accent: Color(0xFF3EE6B0),
    income: Color(0xFF3EE6B0),
    expense: Color(0xFFFF7A6B),
    warning: Color(0xFFFFB020),
    primaryText: Color(0xFFE8F1EE),
    secondaryText: Color(0xFFA5B8B3),
    mutedText: Color(0xFF7D8F8A),
    navBg: Color(0xFF0F1614),
    navBorder: Color(0xFF1A2421),
    navUnselected: Color(0xFF26302D),
    inputFill: Color(0xFF101715),
  );

  static const lightThemeColors = FintechThemeColors(
    background: Color(0xFFF3F7F5),
    cardSurface: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE0EBE6),
    heroTop: Color(0xFF0E5042),
    heroBottom: Color(0xFF072C24),
    heroBorder: Color(0xFF146A58),
    accent: Color(0xFF0D9468),
    income: Color(0xFF059669),
    expense: Color(0xFFE11D48),
    warning: Color(0xFFD97706),
    primaryText: Color(0xFF0F1715),
    secondaryText: Color(0xFF435A54),
    mutedText: Color(0xFF718782),
    navBg: Color(0xFFFFFFFF),
    navBorder: Color(0xFFE2EBE7),
    navUnselected: Color(0xFF8B9E99),
    inputFill: Color(0xFFEDF3F0),
  );

  /// Helper to get current context's theme colors
  static FintechThemeColors of(BuildContext context) {
    return Theme.of(context).extension<FintechThemeColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? darkThemeColors
            : lightThemeColors);
  }
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
  static const darkMoneyColors = MoneyColors(
    income: FintechColors.income,
    expense: FintechColors.expense,
    warning: FintechColors.warning,
    muted: FintechColors.mutedText,
  );

  static const lightMoneyColors = MoneyColors(
    income: Color(0xFF059669),
    expense: Color(0xFFE11D48),
    warning: Color(0xFFD97706),
    muted: Color(0xFF718782),
  );

  static ThemeData dark() {
    return _buildTheme(
      brightness: Brightness.dark,
      colors: FintechColors.darkThemeColors,
      moneyColors: darkMoneyColors,
    );
  }

  static ThemeData light() {
    return _buildTheme(
      brightness: Brightness.light,
      colors: FintechColors.lightThemeColors,
      moneyColors: lightMoneyColors,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required FintechThemeColors colors,
    required MoneyColors moneyColors,
  }) {
    final isDark = brightness == Brightness.dark;

    final scheme = isDark
        ? ColorScheme.dark(
            surface: colors.background,
            onSurface: colors.primaryText,
            primary: colors.accent,
            onPrimary: const Color(0xFF06231B),
            secondary: colors.accent,
            onSecondary: const Color(0xFF06231B),
            error: colors.expense,
            onError: Colors.white,
            outline: colors.cardBorder,
            outlineVariant: colors.cardBorder,
            surfaceContainerLowest: colors.background,
            surfaceContainerLow: colors.background,
            surfaceContainer: colors.cardSurface,
            surfaceContainerHigh: colors.cardSurface,
            surfaceContainerHighest: const Color(0xFF1B2623),
          )
        : ColorScheme.light(
            surface: colors.background,
            onSurface: colors.primaryText,
            primary: colors.accent,
            onPrimary: Colors.white,
            secondary: colors.accent,
            onSecondary: Colors.white,
            error: colors.expense,
            onError: Colors.white,
            outline: colors.cardBorder,
            outlineVariant: colors.cardBorder,
            surfaceContainerLowest: Colors.white,
            surfaceContainerLow: colors.background,
            surfaceContainer: colors.cardSurface,
            surfaceContainerHigh: const Color(0xFFFAFCFB),
            surfaceContainerHighest: colors.cardBorder,
          );

    final rawTextTheme = isDark
        ? ThemeData.dark(useMaterial3: true).textTheme
        : ThemeData.light(useMaterial3: true).textTheme;
    final baseTextTheme = GoogleFonts.manropeTextTheme(rawTextTheme);

    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: colors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: colors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: colors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: colors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: colors.cardBorder,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: colors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.cardBorder, width: 1),
        ),
        elevation: 0,
        color: colors.cardSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.cardSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.cardBorder, width: 1),
        ),
        titleTextStyle: TextStyle(
          color: colors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: TextStyle(
          color: colors.primaryText,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardSurface,
        modalBackgroundColor: colors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          side: BorderSide(color: colors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        hintStyle: TextStyle(color: colors.mutedText, fontSize: 13),
        labelStyle: TextStyle(color: colors.mutedText, fontSize: 13),
        prefixIconColor: colors.mutedText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.cardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.expense, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: isDark ? const Color(0xFF06231B) : Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: isDark ? const Color(0xFF06231B) : Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colors.navBg,
        indicatorColor: isDark ? colors.accent : colors.accent.withValues(alpha: 0.16),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.accent,
            );
          }
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.mutedText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              size: 20,
              color: isDark ? const Color(0xFF06231B) : colors.accent,
            );
          }
          return IconThemeData(
            size: 20,
            color: colors.mutedText,
          );
        }),
      ),
      extensions: [moneyColors, colors],
    );
  }
}

extension MoneyColorsContext on BuildContext {
  MoneyColors get moneyColors =>
      Theme.of(this).extension<MoneyColors>() ?? AppTheme.darkMoneyColors;
}

extension FintechContext on BuildContext {
  FintechThemeColors get fintech =>
      Theme.of(this).extension<FintechThemeColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? FintechColors.darkThemeColors
          : FintechColors.lightThemeColors);
}

