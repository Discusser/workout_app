import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/num_helper.dart';
import 'package:workout_app/extensions/string_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/pages/exercise.dart';
import 'package:workout_app/reusable_widgets/exercise.dart';
import 'package:workout_app/reusable_widgets/loading.dart';
import 'package:workout_app/reusable_widgets/muscle_list.dart';
import 'package:workout_app/user_data.dart';

import '../firebase/firestore_types.dart';
import '../reusable_widgets/containers.dart';
import 'generic.dart';
import 'home.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key, required this.model});

  final WorkoutModel model;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late Future<String> _username;
  late Future<List<ExerciseModel>> _exercisesFuture;

  bool _compact = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;

    _exercisesFuture = getExercises();
  }

  Future<List<ExerciseModel>> getExercises() async {
    var username = await _username;
    var result = await FirebaseFirestore.instance.getExercises(username);
    var workoutExercises = widget.model.exercises.map((e) => Muscles.simplifyMuscleName(e.name, false));
    return result.where((element) => workoutExercises.contains(Muscles.simplifyMuscleName(element.name, false))).toList();
  }

  Widget _createLeftAlignedColumn(List<Widget> children) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        )
      ],
    );
  }

  Widget _createMiscInfo() {
    var style = Theme.of(context).text.bodyLarge;

    return _createLeftAlignedColumn([
      Text("Average Duration: ${widget.model.minutes.removeTrailingZeros(2)} minutes", style: style),
      Text("Number of Exercises: ${widget.model.exercises.length}", style: style),
      Text(
        "Number of Sets: ${widget.model.exercises.map((e) => e.sets).reduce((value, element) => value + element)}",
        style: style,
      ),
    ]);
  }

  Widget _createMusclesTargeted() {
    return FutureBuilder(
      future: _exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              const SectionTitle(text: "Muscles Targeted"),
              _createLeftAlignedColumn([
                MuscleList(
                  muscles: snapshot.data!.map((e) => e.targetMuscles).reduce((value, element) => value + element),
                  detailed: false,
                ),
              ]),
            ],
          );
        } else {
          return const LoadingFuture();
        }
      },
    );
  }

  Widget _createExerciseInfo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const SectionTitle(text: "Exercises"),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(!_compact ? "Less" : "More"),
                onPressed: () {
                  setState(() {
                    _compact = !_compact;
                  });
                },
              ),
            ),
          ],
        ),
        _createLeftAlignedColumn(
          widget.model.exercises
              .map((e) => WorkoutExercise(
                    model: e,
                    style: Theme.of(context).text.bodyLarge!.apply(fontSizeFactor: 1.2),
                    secondaryStyle: Theme.of(context).text.bodyLarge,
                    compact: _compact,
                  ))
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GenericPage(
      body: PaddedContainer(
        child: Column(
          children: [
            SectionTitle(text: widget.model.name),
            const SizedBox(height: 8.0),
            const Divider(),
            _createMiscInfo(),
            const Divider(),
            _createMusclesTargeted(),
            const Divider(),
            _createExerciseInfo(),
          ],
        ),
      ),
    );
  }
}
