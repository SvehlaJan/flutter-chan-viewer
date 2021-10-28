import 'package:flutter/material.dart';

class ThemeHelper {
  static MaterialColor swatchLight = Colors.indigo;

  static MaterialColor swatchDark = MaterialColor(0xff808080, {
    50: Color(0xfff2f2f2),
    100: Color(0xffe6e6e6),
    200: Color(0xffcccccc),
    300: Color(0xffb3b3b3),
    400: Color(0xff999999),
    500: Color(0xff808080),
    600: Color(0xff666666),
    700: Color(0xff4d4d4d),
    800: Color(0xff333333),
    900: Color(0xff191919)
  });

  static ThemeData getThemeLight(BuildContext context) {
    return ThemeData(
      primarySwatch: swatchLight,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
            buttonColor: swatchLight.shade500,
            minWidth: 100.0,
            colorScheme: Theme.of(context)
                .buttonTheme
                .colorScheme!
                .copyWith(primary: swatchLight.shade500),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            textTheme: ButtonTextTheme.primary,
          ),
    );
  }

  static ThemeData getThemeDark(BuildContext context) {
    return ThemeData(
      primarySwatch: swatchDark,
      accentColor: swatchLight.shade500,
      toggleableActiveColor: swatchLight.shade200,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
            buttonColor: swatchLight.shade200,
            minWidth: 100.0,
            colorScheme: Theme.of(context)
                .buttonTheme
                .colorScheme!
                .copyWith(primary: swatchLight.shade200),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            textTheme: ButtonTextTheme.primary,
          ),
      brightness: Brightness.dark,
    );
  }
}
