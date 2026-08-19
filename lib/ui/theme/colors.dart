import 'package:flutter/material.dart';

Map<int, Color> primaryColor = {
  50: Color.fromRGBO(61, 154, 107, .1),
  100: Color.fromRGBO(61, 154, 107, .2),
  200: Color.fromRGBO(61, 154, 107, .3),
  300: Color.fromRGBO(61, 154, 107, .4),
  400: Color.fromRGBO(61, 154, 107, .5),
  500: Color.fromRGBO(61, 154, 107, .6),
  600: Color.fromRGBO(61, 154, 107, .7),
  700: Color.fromRGBO(61, 154, 107, .8),
  800: Color.fromRGBO(47, 122, 85, .9),
  900: Color.fromRGBO(47, 122, 85, 1),
};

Map<int, Color> secondaryColor = {
  50: Color.fromRGBO(107, 114, 128, .1),
  100: Color.fromRGBO(107, 114, 128, .2),
  200: Color.fromRGBO(107, 114, 128, .3),
  300: Color.fromRGBO(107, 114, 128, .4),
  400: Color.fromRGBO(107, 114, 128, .5),
  500: Color.fromRGBO(107, 114, 128, .6),
  600: Color.fromRGBO(107, 114, 128, .7),
  700: Color.fromRGBO(107, 114, 128, .8),
  800: Color.fromRGBO(107, 114, 128, .9),
  900: Color.fromRGBO(107, 114, 128, 1),
};

MaterialColor primaryThemeColor = MaterialColor(0xFF3D9A6B, primaryColor);
MaterialColor secondaryThemeColor = MaterialColor(0xFF6B7280, secondaryColor);
