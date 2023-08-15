import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/reusable_widgets/containers.dart';
import 'package:workout_app/reusable_widgets/dialogs/start_session_dialog.dart';

import '../firebase/firestore_types.dart';
import '../user_data.dart';
import 'exercise.dart';

class WorkoutCreationForm extends StatefulWidget {
  const WorkoutCreationForm({super.key, required this.exercises, required this.workouts});

  final List<String> exercises;
  final List<String> workouts;

  @override
  State<WorkoutCreationForm> createState() => WorkoutCreationFormState();
}

class WorkoutCreationFormState extends State<WorkoutCreationForm> {
  final workoutForm = GlobalKey<FormState>();
  final _exercisesParentForm = GlobalKey<ExerciseCreationFormState>();
  final _exercisesForm = GlobalKey<FormState>();
  final name = TextEditingController();
  final duration = TextEditingController();

  late Future<String> _username;

  var _workoutExercises = <WorkoutExerciseModel>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;
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

  Future<bool> _addWorkoutToFirestore(WorkoutModel model) async {
    var username = await _username;

    FirebaseFirestore.instance.addWorkout(model, username);

    return true;
  }

  Future<void> _createWorkoutAsync() async {
    if (_workoutExercises.isEmpty) {
      context.showAlert("There are no exercises in this workout. Please add at least one exercise");
      setState(() {});
      return;
    }

    var workoutAdded = await _addWorkoutToFirestore(WorkoutModel(
      exercises: _workoutExercises,
      name: name.text,
      minutes: double.parse(duration.text),
    ));

    if (!mounted) {
      return;
    }

    if (widget.workouts.map((e) => e.toLowerCase()).contains(name.text.toLowerCase())) {
      context.showAlert("Creating this workout will override another one with the same name. Please choose another name");
    }

    if (workoutAdded) {
      // The commented lines only reset to the previous values
      // _workoutForm.currentState!.reset();
      // _exercisesForm.currentState!.reset();

      _resetWorkoutForm();
      _exercisesParentForm.currentState!.resetForm();

      context.succesSnackbar("Successfully created workout!");
    }

    Provider.of<HomePageNotifier>(context, listen: false).notify();

    setState(() {});
  }

  void _resetWorkoutForm() {
    name.text = "";
    duration.text = "";
    _workoutExercises = <WorkoutExerciseModel>[];
  }

  void createWorkout() {
    if (workoutForm.currentState!.validate()) {
      context.loadingSnackbar("Creating workout...");
      _createWorkoutAsync();
    }
  }

  void addExercise() {
    if (_exercisesForm.currentState!.validate()) {
      var state = _exercisesParentForm.currentState!;
      var exercise = state.searchValue;

      if (exercise == null || exercise.isEmpty) {
        return context.showError("Invalid exercise");
      }

      _workoutExercises.add(WorkoutExerciseModel(
        kg: int.parse(state.weight.text),
        name: exercise,
        reps: int.parse(state.reps.text),
        sets: int.parse(state.sets.text),
      ));

      state.resetForm();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var exercises = Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _workoutExercises.map((e) => WorkoutExercise(model: e)).toList(),
        ),
      ],
    );

    return PaddedContainer(
      child: Column(
        children: [
          WorkoutMetadataCreationForm(
            formKey: workoutForm,
            nonNullValidator: validateNonNull,
            numberValidator: validateNumber,
            nameController: name,
            durationController: duration,
          ),
          const SizedBox(height: 8.0),
          SectionTitle(text: "Add Exercises", style: Theme.of(context).text.titleLarge),
          ExerciseCreationForm(
            key: _exercisesParentForm,
            formKey: _exercisesForm,
            intValidator: validateInt,
            exercises: widget.exercises,
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

class WorkoutMetadataCreationForm extends StatefulWidget {
  const WorkoutMetadataCreationForm({
    super.key,
    required this.formKey,
    this.nonNullValidator,
    this.numberValidator,
    this.nameController,
    this.durationController,
  });

  final GlobalKey<FormState> formKey;
  final String? Function(String?)? nonNullValidator;
  final String? Function(String?)? numberValidator;
  final TextEditingController? nameController;
  final TextEditingController? durationController;

  @override
  State<WorkoutMetadataCreationForm> createState() => WorkoutMetadataCreationFormState();
}

class WorkoutMetadataCreationFormState extends State<WorkoutMetadataCreationForm> {
  late TextEditingController name;
  late TextEditingController duration;

  @override
  void initState() {
    super.initState();

    name = widget.nameController ?? TextEditingController();
    duration = widget.durationController ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: "Workout Name"),
            keyboardType: TextInputType.text,
            maxLength: 32,
            validator: widget.nonNullValidator,
          ),
          TextFormField(
            controller: duration,
            decoration: const InputDecoration(labelText: "Average Duration (minutes)"),
            keyboardType: TextInputType.number,
            validator: widget.numberValidator,
          )
        ],
      ),
    );
  }
}

class ExerciseCreationForm extends StatefulWidget {
  const ExerciseCreationForm({
    super.key,
    required this.formKey,
    required this.exercises,
    this.intValidator,
    this.initialValue,
    this.weightController,
    this.setsController,
    this.repsController,
  });

  final GlobalKey<FormState> formKey;
  final List<String> exercises;
  final String? Function(String? value)? intValidator;
  final String? initialValue;
  final TextEditingController? weightController;
  final TextEditingController? setsController;
  final TextEditingController? repsController;

  @override
  State<ExerciseCreationForm> createState() => ExerciseCreationFormState();
}

class ExerciseCreationFormState extends State<ExerciseCreationForm> {
  late TextEditingController weight;
  late TextEditingController sets;
  late TextEditingController reps;

  String? searchValue;

  @override
  void initState() {
    super.initState();

    weight = widget.weightController ?? TextEditingController();
    sets = widget.setsController ?? TextEditingController();
    reps = widget.repsController ?? TextEditingController();

    searchValue = widget.initialValue;
  }

  void resetForm() {
    searchValue = null;
    weight.text = "";
    sets.text = "";
    reps.text = "";
  }

  @override
  Widget build(BuildContext context) {
    var items = widget.exercises
        .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
        .toList();
    var exerciseDropdown = SearchChoices<String>.single(
      items: items,
      value: searchValue,
      hint: "Exercise Name",
      searchHint: "Exercise Name",
      onChanged: (value) {
        searchValue = value;
      },
      onClear: () {
        searchValue = null;
        setState(() {}); // Call setState to remove the data displayed
      },
      isExpanded: true,
    );

    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          exerciseDropdown,
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              children: [
                TextFormField(
                  controller: weight,
                  decoration: const InputDecoration(labelText: "Weight (kg)"),
                  keyboardType: TextInputType.number,
                  validator: widget.intValidator,
                ),
                TextFormField(
                  controller: sets,
                  decoration: const InputDecoration(labelText: "Sets"),
                  keyboardType: TextInputType.number,
                  validator: widget.intValidator,
                ),
                TextFormField(
                  controller: reps,
                  decoration: const InputDecoration(labelText: "Reps"),
                  keyboardType: TextInputType.number,
                  validator: widget.intValidator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
