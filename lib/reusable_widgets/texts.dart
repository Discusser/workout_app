import 'package:flutter/material.dart';
import 'package:workout_app/extensions/theme_helper.dart';

import '../theme/app_theme.dart';

class ProgressColor {
  static const up = ProgressColor(color: AppColors.success, sign: "+");
  static const down = ProgressColor(color: AppColors.error, sign: "-");

  static progressive(double progress) {
    final color = ColorMath.colorBetween(AppColors.error, AppColors.success, (progress / 100));
    return ProgressColor(color: color, progress: progress);
  }

  const ProgressColor({required this.color, this.sign, this.progress});

  final Color color;
  final String? sign;
  final double? progress;
}

class StatisticText extends StatelessWidget {
  const StatisticText({super.key, required this.text, this.progress, this.value});

  final String text;
  final ProgressColor? progress;
  final String? value;

  @override
  Widget build(BuildContext context) {
    String displayText = text;
    var children = <TextSpan>[];
    var style = Theme.of(context).text.bodyLarge;

    if (progress != null && value != null) {
      displayText += " (";

      var coloredText = "";
      if (progress?.sign != null) {
        coloredText += progress!.sign!;
      }
      if (value != null) {
        coloredText += value!;
      }

      children.add(
        TextSpan(text: coloredText, style: style?.copyWith(color: progress?.color)),
      );

      if (progress?.progress != null) {
        var optionalColoredText = "${progress!.progress.toString()}%";

        children.addAll([
          TextSpan(text: ", ", style: style),
          TextSpan(text: optionalColoredText, style: style?.copyWith(color: progress?.color)),
          TextSpan(text: " to goal", style: style)
        ]);
      }

      children.add(
        TextSpan(text: ")", style: style),
      );
    }

    return RichText(
        text: TextSpan(text: displayText, style: style?.copyWith(color: Theme.of(context).color.onBackground), children: children));
  }
}