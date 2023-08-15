import 'package:flutter/material.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_types.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/reusable_widgets/containers.dart';

import 'home.dart';

class WorkoutSessionPage extends StatelessWidget {
  const WorkoutSessionPage({super.key, required this.session});

  final UserWorkoutSessionStatModel session;

  int get sets => session.session.exercises.fold(0, (previousValue, element) => previousValue + element.sets.length);

  Widget _leftAlignedColumn(List<Widget> children) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        )
      ],
    );
  }

  Widget _createExercisesInfo(BuildContext context) {
    var children = <Widget>[];

    for (var exercise in session.session.exercises) {
      children.add(Text("${exercise.name} (${exercise.sets.length} sets)", style: Theme.of(context).text.bodyLarge));

      var sets = <Widget>[];
      for (var set in exercise.sets) {
        var text = "${set.reps} reps";

        if (set.kg != 0) {
          text += " (${set.kg} kg)";
        }

        sets.add(Text(text));
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _leftAlignedColumn(sets),
        ),
      );
    }

    return _leftAlignedColumn(children);
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    var bodyLarge = Theme.of(context).text.bodyLarge;

    return GenericPage(
      body: PaddedContainer(
        child: Column(
          children: [
            SectionTitle(text: session.session.name),
            _leftAlignedColumn([
              Text("Time elapsed ${_printDuration(Duration(minutes: session.session.minutes))}", style: bodyLarge),
              Text("Sets completed $sets", style: bodyLarge),
              const SizedBox(height: 16.0),
              _createExercisesInfo(context),
            ]),
          ],
        ),
      ),
    );
  }
}
