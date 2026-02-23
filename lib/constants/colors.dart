import 'package:flutter/material.dart';

Color primaryColor = "#003cc5".toColor();
Color backgroundColor = "#F9F9F9".toColor();
Color fontBlack = "#000000".toColor();
Color greyFont = "#616161".toColor();
Color cardColor = Colors.white;
Color shadowColor = Colors.black12;
Color successColor = const Color.fromARGB(255, 57, 145, 60);

class AppGradients {
  AppGradients._();

  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0863f6), Color(0xFF003cc5)],
  );

  static const LinearGradient buttonGradientPrimary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF003cc5), Color(0xFF0863f6)],
  );
}

extension ColorExtension on String {
  Color toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    throw FormatException("Invalid hexadecimal color: $this");
  }
}
