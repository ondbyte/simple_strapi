import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'themestore.g.dart';

class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store {
  ///default theme, false means light theme
  bool _flipped = false;
  @observable
  ThemeData selectedThemeData = getLightThemeData();

  ///call this to change the theme to alternate one
  @action
  void flipTheme() {
    _flipped = !_flipped;
    _flipped
        ? selectedThemeData = getDarkThemeData()
        : selectedThemeData = getLightThemeData();
  }

  ///changes to the light theme should be done here
  static ThemeData getLightThemeData() {
    return ThemeData(
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      // scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.teal,
      accentColor: Colors.tealAccent[700],
      primaryColorLight: Colors.white,
      secondaryHeaderColor: Colors.white,
      primaryColorDark: Colors.black,

      ///changes
      //buttonColor: Colors.teal,
      canvasColor: Colors.black,
      cardColor: Color(0xFFF0F8F7),
      disabledColor: Colors.grey[500],
      bottomAppBarColor: Colors.white,

      //  textSelectionColor: Colors.indigo[100],
      dividerColor: Colors.grey[500],
      iconTheme: IconThemeData(
        color: Colors.grey[900],
      ),
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: 22,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.1,
          fontWeight: FontWeight.w900,
          fontFamily: 'Lato',
        ),
        headline2: TextStyle(
          fontSize: 22,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.1,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        headline3: TextStyle(
          fontSize: 20,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w700,
          fontFamily: 'Lato',
        ),
        headline4: TextStyle(
          fontSize: 20,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lato',
        ),
        headline5: TextStyle(
          fontSize: 18,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        headline6: TextStyle(
          fontSize: 18,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.2,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        subtitle1: TextStyle(
          fontSize: 16,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w700,
          fontFamily: 'Gilmer',
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w400,
          fontFamily: 'Gilmer',
        ),
        bodyText1: TextStyle(
          fontSize: 14,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.normal,
          fontFamily: 'Lato',
        ),
        bodyText2: TextStyle(
          fontSize: 13,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.normal,
          fontFamily: 'Lato',
        ),
        overline: TextStyle(
          fontSize: 12,
          color: Colors.grey[900],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.normal,
          fontFamily: 'Lato',
        ),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        elevation: 10,
        color: Colors.white,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: Colors.grey[100],
      ),
      // ),
      appBarTheme: AppBarTheme(
        brightness: Brightness.light,
        color: Colors.white,
        // color: Colors.white,
        elevation: 0,
        textTheme: TextTheme(
          headline6: TextStyle(
              fontSize: 16,
              letterSpacing: 0,
              height: 1,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
              color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.teal,
        ),
      ),
      cardTheme: CardTheme(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 0,
        shadowColor: Color(0xFFFFFFF5),
      ),
      snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(color: Colors.white)),

      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        hintStyle: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Lato'),
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1,
          fontFamily: 'Lato',
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
        helperStyle: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1,
          fontFamily: 'Lato',
        ),
      ),
    );
  }

  ///changes to the dark theme should be done here
  static ThemeData getDarkThemeData() {
    return ThemeData(
      backgroundColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.teal,
      accentColor: Colors.tealAccent[700],
      primaryColorLight: Colors.white,
      primaryColorDark: Colors.black,

      ///changes
      //buttonColor: Colors.teal,
      canvasColor: Colors.white,
      cardColor: Color(0xFF212524),
      disabledColor: Colors.grey[700],
      bottomAppBarColor: Colors.black,
      secondaryHeaderColor: Colors.grey[900],
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Color(0xFF101225),
      ),
      dividerColor: Colors.white24,
      textSelectionColor: Colors.indigo[500],
      iconTheme: IconThemeData(color: Colors.grey[500], opacity: 0.9),
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: 24,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.1,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        headline2: TextStyle(
          fontSize: 24,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.1,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        headline3: TextStyle(
          fontSize: 22,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        headline4: TextStyle(
          fontSize: 22,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        headline5: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        headline6: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.2,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lato',
        ),
        subtitle1: TextStyle(
          fontSize: 16,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w700,
          fontFamily: 'Gilmer',
        ),
        subtitle2: TextStyle(
          fontSize: 16,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.w400,
          fontFamily: 'Gilmer',
        ),
        bodyText1: TextStyle(
          fontSize: 16,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.4,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gilmer',
        ),
        bodyText2: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            letterSpacing: 0,
            height: 1.4,
            fontWeight: FontWeight.normal,
            fontFamily: 'Gilmer'),
        overline: TextStyle(
          fontSize: 13,
          color: Colors.grey[400],
          letterSpacing: 0,
          height: 1.2,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gilmer',
        ),
      ),
      bottomAppBarTheme: BottomAppBarTheme(elevation: 10, color: Colors.black),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.grey[900],
      ),
      appBarTheme: AppBarTheme(
        brightness: Brightness.dark,
        color: Colors.black,
        // color: Colors.white,
        elevation: 0,
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 16,
            letterSpacing: 0,
            height: 1,
            fontWeight: FontWeight.w800,
            fontFamily: 'Lato',
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: TextStyle(color: Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo, width: 1),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
        labelStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1,
          fontFamily: 'Lato',
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
        helperStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1,
          fontFamily: 'Lato',
        ),
      ),
    );
  }
}
