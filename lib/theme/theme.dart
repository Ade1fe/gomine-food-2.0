import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Theme Colors
  static const Color primary = Color.fromARGB(255, 30, 36, 41);
  static const Color secondary = Color(0xFF212121);
  //   static const Color primary = Color.fromARGB(255, 5, 2, 2);
  // static const Color secondary = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color buttonText = Colors.white;
  static const Color green = Colors.green;
  static const Color brown = Color.fromARGB(237, 190, 122, 97);

  // Dark Theme Colors
  static const Color darkPrimary =
      Color.fromARGB(255, 18, 20, 25); // Dark primary color
  static const Color darkSecondary =
      Color.fromARGB(255, 15, 18, 23); // Dark secondary color
  static const Color darkBackground = Color(0xFF121212); // Dark background
  static const Color darkTextPrimary =
      Colors.white; // White text on dark background
  static const Color darkTextSecondary = Colors.grey; // Secondary text color
  static const Color darkAccent = Color(0xFFFFC107); // Accent remains the same

  // Add more colors as needed
}

class AppTextStyles {
  static final TextStyle _baseStyle = GoogleFonts.roboto();

  static TextStyle getStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return _baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      decoration: decoration,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  static TextStyle headline = getStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle body = getStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle subHeading = getStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = getStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static TextStyle medium = getStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Dark Theme Styles
  static TextStyle darkHeadline = getStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
  );

  static TextStyle darkBody = getStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.darkTextPrimary,
  );

  static TextStyle darkSubHeading = getStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );

  static TextStyle darkCaption = getStyle(
    fontSize: 14,
    color: AppColors.darkTextSecondary,
  );

  static TextStyle darkMedium = getStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.darkTextSecondary,
  );
}

class AppThemes {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      primaryColor: AppColors.primary,
      hintColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 4,
        titleTextStyle: AppTextStyles.headline.copyWith(color: Colors.white),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline,
        bodyLarge: AppTextStyles.body,
        titleMedium: AppTextStyles.subHeading,
        bodySmall: AppTextStyles.caption,
        bodyMedium: AppTextStyles.medium,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown)
          .copyWith(surface: AppColors.background),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      primaryColor: AppColors.darkPrimary,
      hintColor: AppColors.darkAccent,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkPrimary,
        elevation: 4,
        titleTextStyle:
            AppTextStyles.darkHeadline.copyWith(color: Colors.white),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.darkPrimary,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.darkHeadline,
        bodyLarge: AppTextStyles.darkBody,
        titleMedium: AppTextStyles.darkSubHeading,
        bodySmall: AppTextStyles.darkCaption,
        bodyMedium: AppTextStyles.darkMedium,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown)
          .copyWith(surface: AppColors.darkBackground),
    );
  }
}
