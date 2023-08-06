import 'package:flutter/material.dart';

extension TextStyleHelper on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
}

extension ThemeDataHelper on ThemeData {
  ColorScheme get color => colorScheme;
  TextTheme get text => textTheme;
  IconThemeData get icon => iconTheme;
}

extension ColorMath on Color {
  static colorBetween(Color start, Color end, double factor) {
    int computeChannel(int startChannel, int endChannel) {
      return (factor * (endChannel - startChannel) + startChannel).round();
    }

    int r = computeChannel(start.red, end.red);
    int g = computeChannel(start.green, end.green);
    int b = computeChannel(start.blue, end.blue);

    return Color.fromARGB(255, r, g, b);
  }
}