import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/reusable_widgets/containers.dart';

import '../firebase/firestore_types.dart';
import '../user_data.dart';
import 'exercise.dart';

class WorkoutCreationForm extends StatefulWidget {
  const WorkoutCreationForm({super.key});

  @override
  State<WorkoutCreationForm> createState() => _WorkoutCreationFormState();
}

class _WorkoutCreationFormState extends State<WorkoutCreationForm> {
  final _workoutForm = GlobalKey<FormState>();
  final _exercisesForm = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _duration = TextEditingController();
  final _weight = TextEditingController();
  final _sets = TextEditingController();
  final _reps = TextEditingController();

  late Future<List<String>> _exercisesFuture;
  late Future<String> _username;

  var _exercises = <WorkoutExerciseModel>[];

  String? _exerciseSearchValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;

    _exercisesFuture = getExercises();
  }

  Future<List<String>> getExercises() async {
    var username = await _username;
    var result = await FirebaseFirestore.instance.getExercises(username);
    return result.map((e) => e.name).toList();
  }

  String? validateNonNull(String? value) {
    if (value == null || value.isEmpty) {
      return "Value must not be null";
    }

    return null;
  }

  String? validateNumber(String? value) {
    var error = validateNonNull(value);
    if (error != null) {
      return error;
    }

    if (double.tryParse(value!) == null) {
      return "Not a valid number";
    }

    return null;
  }

  String? validateInt(String? value) {
    var error = validateNonNull(value);
    if (error != null) {
      return error;
    }

    if (int.tryParse(value!) == null) {
      return "Not a valid integer";
    }

    return null;
  }

  void addExercise() {
    if (_exercisesForm.currentState!.validate()) {
      if (_exerciseSearchValue == null || _exerciseSearchValue!.isEmpty) {
        context.showError("Invalid exercise");
        return;
      }

      _exercises.add(WorkoutExerciseModel(
        kg: int.parse(_weight.text),
        name: _exerciseSearchValue!,
        reps: int.parse(_reps.text),
        sets: int.parse(_sets.text),
      ));

      _exerciseSearchValue = null;

      _resetExerciseForm();

      setState(() {});
    }
  }

  Future<bool> _addWorkoutToFirestore(WorkoutModel model) async {
    var username = await _username;
    var workoutNames = await FirebaseFirestore.instance.getWorkoutNames(username);

    if (workoutNames.map((e) => e.toLowerCase()).contains(model.name.toLowerCase())) {
      return false;
    }

    FirebaseFirestore.instance
        .colWorkouts(username)
        .withConverter(fromFirestore: WorkoutModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .add(model);
    return true;
  }

  Future<void> _createWorkoutAsync() async {
    if (_exercises.isEmpty) {
      context.showAlert("There are no exercises in this workout. Please add at least one exercise");
      setState(() {});
      return;
    }

    var result = await _addWorkoutToFirestore(WorkoutModel(
      exercises: _exercises,
      name: _name.text,
      minutes: double.parse(_duration.text),
    ));

    if (!mounted) {
      return;
    }

    context.showAlert("Creating this workout will override another one with the same name. Please choose another name");

    if (result) {
      // The commented lines only reset to the previous values
      // _workoutForm.currentState!.reset();
      // _exercisesForm.currentState!.reset();

      _resetWorkoutForm();
      _resetExerciseForm();

      context.succesSnackbar("Successfully created workout!");
    }
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _resetWorkoutForm() {
    _name.text = "";
    _duration.text = "";
    _exercises = <WorkoutExerciseModel>[];
  }

  void _resetExerciseForm() {
    _exerciseSearchValue = null;
    _weight.text = "";
    _sets.text = "";
    _reps.text = "";
  }

  void createWorkout() {
    if (_workoutForm.currentState!.validate()) {
      context.loadingSnackbar("Creating workout...");
      _createWorkoutAsync();
    }
  }

  @override
  Widget build(BuildContext context) {
    var exerciseDropdownFuture = FutureBuilder(
      future: _exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var items = snapshot.data!
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList();
          return SearchChoices<String>.single(
            items: items,
            value: _exerciseSearchValue,
            hint: "Exercise Name",
            searchHint: "Exercise Name",
            onChanged: (value) {
              _exerciseSearchValue = value;
            },
            onClear: () {
              _exerciseSearchValue = null;
              setState(() {}); // Call setState to remove the data displayed
            },
            isExpanded: true,
          );
        } else {
          return DropdownButtonFormField(
            items: const [],
            onChanged: (value) {},
            decoration: const InputDecoration(labelText: "Exercise Name"),
            validator: (value) => "Exercise not specified",
          );
        }
      },
    );

    var exercises = Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _exercises.map((e) => WorkoutExercise(model: e)).toList(),
        ),
      ],
    );

    return PaddedContainer(
      child: Column(
        children: [
          Form(
            key: _workoutForm,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: "Workout Name"),
                  keyboardType: TextInputType.text,
                  maxLength: 32,
                  validator: validateNonNull,
                ),
                TextFormField(
                  controller: _duration,
                  decoration: const InputDecoration(labelText: "Average Duration (minutes)"),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                )
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          SectionTitle(text: "Add Exercises", style: Theme.of(context).text.titleLarge),
          Form(
            key: _exercisesForm,
            child: Column(
              children: [
                exerciseDropdownFuture,
                TextFormField(
                  controller: _weight,
                  decoration: const InputDecoration(labelText: "Weight (kg)"),
                  keyboardType: TextInputType.number,
                  validator: validateInt,
                ),
                TextFormField(
                  controller: _sets,
                  decoration: const InputDecoration(labelText: "Sets"),
                  keyboardType: TextInputType.number,
                  validator: validateInt,
                ),
                TextFormField(
                  controller: _reps,
                  decoration: const InputDecoration(labelText: "Reps"),
                  keyboardType: TextInputType.number,
                  validator: validateInt,
                ),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: addExercise,
              child: const Text("Add exercise"),
            ),
          ),
          exercises,
          Center(
            child: TextButton(
              onPressed: createWorkout,
              child: const Text("Create workout"),
            ),
          ),
        ],
      ),
    );
  }
}
