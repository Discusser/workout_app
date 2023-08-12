import 'dart:math';

import 'package:flutter/material.dart';
import 'package:workout_app/extensions/string_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/reusable_widgets/containers.dart';
import 'package:workout_app/route_manager.dart';
import 'package:workout_app/theme/app_theme.dart';

import '../firebase/firestore_types.dart';
import '../pages/exercise.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.model});

  final ExerciseModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: PaddedContainer(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).color.onBackground.withOpacity(0.75)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    model.name,
                    style: Theme.of(context).text.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.unusedBackground)),
                    child: const Text("Learn More"),
                    onPressed: () => RouteManager.push(context, (context) => ExercisePage(model: model)),
                  ),
                ],
              ),
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Image.asset(model.name.asExerciseImage(), width: MediaQuery.of(context).size.width / 2)],
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          () {
                            var maxLines = 4;

                            var muscles = Muscles.simplifyMuscleNames(model.targetMuscles, true);
                            var length = muscles.length;
                            muscles = muscles.sublist(0, min(maxLines, length));
                            if (length > maxLines) {
                              muscles.add("...");
                            }
                            return muscles.toSet().join("\n");
                          }(),
                          style: Theme.of(context).text.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          // maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutExercise extends StatelessWidget {
  const WorkoutExercise({super.key, required this.model, this.style, this.secondaryStyle, bool? compact}) : compact = compact ?? false;

  final WorkoutExerciseModel model;
  final TextStyle? style;
  final TextStyle? secondaryStyle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[Text(model.name, style: style ?? Theme.of(context).text.titleSmall)];

    if (!compact) {
      children.addAll([
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Weight: ${model.kg} kg", style: secondaryStyle),
              Text("Reps: ${model.reps}", style: secondaryStyle),
              Text("Sets: ${model.sets}", style: secondaryStyle),
            ],
          ),
        ),
      ]);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    } else {
      var text = "(";

      if (model.kg != 0) {
        text += "${model.kg} kg, ";
      }

      text += "${model.sets}x${model.reps})";

      children.addAll([
        const SizedBox(width: 4.0),
        Text(text, style: secondaryStyle),
      ]);

      return Row(
        children: children,
      );
    }
  }
}
