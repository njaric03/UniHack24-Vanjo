import 'package:flutter/material.dart';

class AppTheme {
  // Define color palette
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFCDDC39);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);

  // Define font styles
  static const String fontFamily = 'Roboto';

  // Define text styles
  static final TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static final TextStyle bodyText1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: textColor,
  );

  // ThemeData for the app
  static ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    hintColor: accentColor,
    fontFamily: fontFamily,
    textTheme: TextTheme(
      displayLarge: headline1,
      bodyLarge: bodyText1,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
    ),
  );
}