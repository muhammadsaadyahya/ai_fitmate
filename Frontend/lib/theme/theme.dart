import "package:flutter/material.dart";

ThemeData darkMode=ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    // surface: Colors.grey.shade900,
    // surface: Color(0x000b0b0f),
    surface: Colors.black,
    primary: Color(0xFFC9FF3A),
  )
);

ThemeData lightMode=ThemeData(
  brightness: Brightness.light,
);