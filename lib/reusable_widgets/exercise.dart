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
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Image.asset(model.name.asExerciseImage(), width: MediaQuery.of(context).size.width / 3)],
                ),
                const SizedBox(width: 16.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.muscles.join(", "),
                        style: Theme.of(context).text.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        model.description,
                        style: Theme.of(context).text.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}