import 'package:flutter/material.dart';

class AppTheme {
  // Define color palette
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFCDDC39);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color teacherColor = Colors.blue;
  static const Color learnerColor = Colors.orange;
  static const Color networkColor = primaryColor;

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

  static ThemeData darkThemeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    hintColor: Colors.cyan,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        color: Colors.white,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blueGrey,
      textTheme: ButtonTextTheme.primary,
    ),
    scaffoldBackgroundColor: Colors.black,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.cyan,
    ).copyWith(surface: Colors.black),
  );
}
