import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/string_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/firebase/firestore_types.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/reusable_widgets/containers.dart';
import 'package:workout_app/theme/app_theme.dart';
import 'package:workout_app/user_data.dart';

import 'home.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key, required this.model});

  final ExerciseModel model;

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late Future<String> _username;
  late Future<List<String>> _workoutsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context, listen: false).username;
    _workoutsFuture = getWorkouts();
  }

  Future<List<String>> getWorkouts() async {
    var username = await _username;
    return FirebaseFirestore.instance.getWorkoutsWithExercise(widget.model.name, username);
  }

  Widget _createOrderedList(List<String> values) {
    var children = <Widget>[];

    for (int i = 0; i < values.length; i++) {
      children.add(Text(
        "${i + 1}. ${values[i]}",
        style: Theme.of(context).text.bodyLarge!.apply(fontSizeFactor: 1.2),
      ));
    }

    return Row(
      children: [
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ],
    );
  }

  Widget _createExerciseMusclesWorked() {
    return Column(
      children: [
        const SectionTitle(text: "Muscles Targeted"),
        const SizedBox(height: 8.0),
        _createOrderedList(widget.model.muscles),
      ],
    );
  }

  Widget _createExerciseDescription() {
    return Column(
      children: [
        const SectionTitle(text: "Description"),
        const SizedBox(height: 8.0),
        Text(widget.model.description, style: Theme.of(context).text.bodyLarge),
      ],
    );
  }

  Widget _createExerciseHeader() {
    return Column(
      children: [
        SectionTitle(text: widget.model.name),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).color.onBackground.withOpacity(0.75))),
          child: Image.asset(widget.model.name.asExerciseImage()),
        ),
      ],
    );
  }

  Widget _createMiscInfo() {
    var futureBuilder = FutureBuilder(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          var textStyle = Theme.of(context).text.bodyLarge;
          var children = <Widget>[Text("In workouts: ", style: textStyle)];

          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              children.add(Text("None", style: textStyle));
            }
            for (var value in snapshot.data!) {
              children.add(Chip(
                label: Text(value),
                backgroundColor: AppColors.unusedBackground.withOpacity(0.25),
                elevation: 4.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              ));
            }
          } else {
            children.add(Text("Getting workouts", style: textStyle));
          }

          return Row(children: children);
        });

    return Column(
      children: [
        const SectionTitle(text: "More"),
        const SizedBox(height: 8.0),
        futureBuilder,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GenericPage(
      body: PaddedContainer(
        child: Column(
          children: [
            _createExerciseHeader(),
            const Divider(),
            _createExerciseMusclesWorked(),
            const Divider(),
            _createExerciseDescription(),
            const Divider(),
            _createMiscInfo(),
          ],
        ),
      ),
    );
  }
}
