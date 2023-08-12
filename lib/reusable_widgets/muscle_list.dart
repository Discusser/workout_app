import 'package:flutter/material.dart';
import 'package:workout_app/extensions/theme_helper.dart';

import '../pages/exercise.dart';

class MuscleList extends StatelessWidget {
  const MuscleList({super.key, required this.muscles, required this.detailed, this.style});

  final List<String> muscles;
  final bool detailed;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    var values = detailed ? muscles : Muscles.simplifyMuscleNames(muscles, !detailed).toSet().toList();
    var children = <Widget>[];

    for (int i = 0; i < values.length; i++) {
      children.add(Text(
        "${i + 1}. ${values[i]}",
        style: style ?? Theme.of(context).text.bodyLarge!.apply(fontSizeFactor: 1.2),
      ));
    }

    return Row(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ],
    );
  }
}
