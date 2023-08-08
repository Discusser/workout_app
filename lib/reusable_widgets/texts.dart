import 'package:flutter/material.dart';
import 'package:workout_app/extensions/theme_helper.dart';

import '../theme/app_theme.dart';

class ProgressColor {
  static const up = ProgressColor(color: AppColors.success, sign: "+");
  static const down = ProgressColor(color: AppColors.error, sign: "-");
  static const none = ProgressColor(color: AppColors.unusedText, sign: "");

  static progressive(ProgressColor color, double current, double? goal, double maxDistance) {
    final difference = goal != null ? (current - goal).abs() : 0.0;
    final percent = 1 - ((difference) / maxDistance).clamp(0, 1).toDouble();
    final secondaryColor = ColorMath.colorBetween(AppColors.error, AppColors.success, percent);
    return ProgressColor(color: color.color, sign: color.sign, secondaryColor: secondaryColor, difference: difference, goal: goal);
  }

  const ProgressColor({required this.color, this.secondaryColor, this.sign, this.difference, this.goal});

  final Color color;
  final Color? secondaryColor;
  final String? sign;
  final double? difference;
  final double? goal;
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

      var colorStyle = style?.copyWith(color: progress?.color);

      children.add(
        TextSpan(text: coloredText, style: colorStyle),
      );

      if (progress?.difference != null && progress?.goal != null) {
        var secondaryColorStyle = style?.copyWith(color: progress?.secondaryColor ?? progress?.color);

        children.addAll([
          TextSpan(text: ", ", style: style),
          TextSpan(text: "${(progress!.difference!).toStringAsFixed(1)} kg", style: secondaryColorStyle),
          TextSpan(text: " from goal ", style: style),
          TextSpan(text: "${progress!.goal!.toStringAsFixed(1)} kg", style: secondaryColorStyle)
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