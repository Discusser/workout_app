import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/extensions/num_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/pages/exercise.dart';
import 'package:workout_app/pages/loading.dart';
import 'package:workout_app/reusable_widgets/muscle_list.dart';
import 'package:workout_app/reusable_widgets/workout_creation.dart';
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
  late WorkoutModel _model;
  late Future<String> _username;
  late Future<List<ExerciseModel>> _workoutExerciseModelsFuture;
  late Future<List<String>> _exercisesFuture;
  late Future<List<String>> _workoutNamesFuture;

  final _workoutKey = GlobalKey<WorkoutMetadataCreationFormState>();
  final _workoutFormKey = GlobalKey<FormState>();
  final _keys = <GlobalKey<ExerciseCreationFormState>>[];
  final _formKeys = <GlobalKey<FormState>>[];

  String _oldWorkoutName = "";

  @override
  void initState() {
    super.initState();

    _model = widget.model;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;

    calculateFutures();

    _oldWorkoutName = _model.name;
  }

  void calculateFutures() {
    _workoutExerciseModelsFuture = getWorkoutExerciseModels();
    _exercisesFuture = getExerciseNames();
    _workoutNamesFuture = getWorkoutNames();
  }

  Future<List<ExerciseModel>> getWorkoutExerciseModels() async {
    var username = await _username;
    var result = await FirebaseFirestore.instance.getExercises(username, const GetOptions(source: Source.server));
    var workoutExercises = _model.exercises.map((e) => Muscles.simplifyMuscleName(e.name, false));
    return result.where((element) => workoutExercises.contains(Muscles.simplifyMuscleName(element.name, false))).toList();
  }

  Future<List<String>> getExerciseNames() async {
    var username = await _username;
    var result = await FirebaseFirestore.instance.getExercises(username, const GetOptions(source: Source.server));
    return result.map((e) => e.name).toList();
  }

  Future<List<String>> getWorkoutNames() async {
    var username = await _username;
    return await FirebaseFirestore.instance.getWorkoutNames(username, const GetOptions(source: Source.server));
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
      Text("Average Duration: ${_model.minutes.removeTrailingZeros(2)} minutes", style: style),
      Text("Number of Exercises: ${_model.exercises.length}", style: style),
      Text(
        "Number of Sets: ${_model.exercises.map((e) => e.sets).reduce((value, element) => value + element)}",
        style: style,
      ),
    ]);
  }

  Widget _createMusclesTargeted(List<ExerciseModel> exercises) {
    return Column(
      children: [
        const SectionTitle(text: "Muscles Targeted"),
        _createLeftAlignedColumn([
          MuscleList(
            muscles: exercises.map((e) => e.targetMuscles).reduce((value, element) => value + element),
            detailed: false,
          ),
        ]),
      ],
    );
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

  Widget _createExerciseInfo(List<String> exercises, List<String> workoutNames) {
    var children = <Widget>[];

    children.add(WorkoutMetadataCreationForm(
      key: _workoutKey,
      formKey: _workoutFormKey,
      nameController: TextEditingController(text: _oldWorkoutName),
      durationController: TextEditingController(text: _model.minutes.removeTrailingZeros(2)),
    ));

    for (var exercise in widget.model.exercises) {
      var form = ExerciseCreationForm(
        initialValue: exercise.name,
        weightController: TextEditingController(text: exercise.kg.toString()),
        setsController: TextEditingController(text: exercise.sets.toString()),
        repsController: TextEditingController(text: exercise.reps.toString()),
        key: _createKey(),
        formKey: _createFormKey(),
        exercises: exercises,
        intValidator: validateInt,
      );

      children.add(form);
    }

    children.add(Center(
      child: TextButton(
        onPressed: saveChanges,
        child: const Text("Save Changes"),
      ),
    ));

    return PaddedContainer(child: Column(children: children));
  }

  GlobalKey<FormState> _createFormKey() {
    var key = GlobalKey<FormState>();

    _formKeys.add(key);

    return key;
  }

  GlobalKey<ExerciseCreationFormState> _createKey() {
    var key = GlobalKey<ExerciseCreationFormState>();

    _keys.add(key);

    return key;
  }

  void saveChanges() async {
    var models = <WorkoutExerciseModel>[];

    for (int i = 0; i < _keys.length; i++) {
      if (_formKeys[i].currentState!.validate()) {
        var state = _keys[i].currentState!;
        var exercise = state.searchValue;
        if (exercise == null || exercise.isEmpty) {
          return context.showError("Invalid exercise");
        }

        models.add(WorkoutExerciseModel(
          kg: int.parse(state.weight.text),
          name: exercise,
          reps: int.parse(state.reps.text),
          sets: int.parse(state.sets.text),
        ));
      } else {
        // Return early if there's an issue with an exercise, the form should handle displaying the error
        return;
      }
    }

    if (!_workoutFormKey.currentState!.validate()) {
      return;
    }

    var state = _workoutKey.currentState!;
    var model = WorkoutModel(
      name: state.name.text,
      minutes: double.parse(state.duration.text),
      exercises: models,
    );
    var username = await _username;
    await FirebaseFirestore.instance.removeWorkout(_oldWorkoutName, username);
    await FirebaseFirestore.instance.addWorkout(
      model,
      username,
      true,
      const GetOptions(source: Source.server),
    );

    _model = model;

    calculateFutures();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_workoutExerciseModelsFuture, _exercisesFuture, _workoutNamesFuture]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var workoutExercises = snapshot.data![0] as List<ExerciseModel>;
          var exercises = snapshot.data![1] as List<String>;
          var workoutNames = snapshot.data![2] as List<String>;

          return GenericPage(
            body: PaddedContainer(
              child: Column(
                children: [
                  SectionTitle(text: _model.name),
                  const SizedBox(height: 8.0),
                  const Divider(),
                  _createMiscInfo(),
                  const Divider(),
                  _createMusclesTargeted(workoutExercises),
                  const Divider(),
                  _createExerciseInfo(exercises, workoutNames),
                ],
              ),
            ),
          );
        } else {
          return const LoadingPage();
        }
      },
    );
  }
}
