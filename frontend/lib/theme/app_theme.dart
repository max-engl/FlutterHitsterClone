import 'package:flutter/material.dart';

class AppTheme {
  static final TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 3.0,
    color: Colors.black,
  );

  static final TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    color: Colors.black,
  );

  static final TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    color: Colors.white,
  );

  static final TextStyle countdownStyle = TextStyle(
    fontSize: 120,
    fontWeight: FontWeight.w900,
    color: Colors.black,
  );

  static final TextStyle scoreStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: Colors.black,
  );

  static const double kDefaultPadding = 10.0;
  static const double kLargePadding = 40.0;
  static const double kSmallPadding = 16.0;
  static const double kDefaultSpacing = 15.0;
  static const double kLargeSpacing = 50.0;
  static const double kSmallSpacing = 20.0;

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Color.fromRGBO(93, 202, 151, 1),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(17)),
    ),
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.4),
    minimumSize: const Size(double.infinity, 60),
  );
  static final ButtonStyle secondaryButtonStyle = primaryButtonStyle;

  static BoxDecoration containerDecoration({
    bool isHighlighted = false,
    bool isDark = false,
  }) {
    return BoxDecoration(
      border: Border.all(color: Colors.black, width: isHighlighted ? 2 : 1),
      color: isDark ? Colors.black : Colors.white,
    );
  }

  static ThemeData getTheme() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.white,
        onSecondary: Colors.black,
        surface: Colors.white,
        background: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
          color: Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.black),
      ),
    );
  }
}
