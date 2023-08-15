import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/pages/loading.dart';
import 'package:workout_app/reusable_widgets/containers.dart';

import '../reusable_widgets/dialogs/add_cardio_dialog.dart';
import '../reusable_widgets/dialogs/add_weight_dialog.dart';
import '../reusable_widgets/dialogs/set_goal_dialog.dart';
import '../reusable_widgets/workout_creation.dart';
import '../user_data.dart';

class DialogDropdownItem<String> extends DropdownMenuItem<String> {
  const DialogDropdownItem({super.key, required super.child, required super.value, required this.dialog});

  final Widget dialog;
}

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  late Future<String> _username;
  late Future<List<String>> _exercisesFuture;
  late Future<List<String>> _workoutsFuture;

  Widget? _dropdownValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;

    _exercisesFuture = getExercises();
    _workoutsFuture = getWorkouts();
  }

  Future<List<String>> getExercises() async {
    var username = await _username;
    var result = await FirebaseFirestore.instance.getExercises(username);
    return result.map((e) => e.name).toList();
  }

  Future<List<String>> getWorkouts() async {
    var username = await _username;
    return await FirebaseFirestore.instance.getWorkoutNames(username);
  }

  void onPressed() {
    if (_dropdownValue != null) {
      showDialog(context: context, builder: (context) => _dropdownValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    var dropdownItems = const [
      DialogDropdownItem(dialog: AddCardioDialog(), value: "cardio_session", child: Text("Cardio Session")),
      DialogDropdownItem(dialog: AddWeightDialog(), value: "weight", child: Text("Weight")),
      DialogDropdownItem(dialog: SetGoalDialog(), value: "weight_goal", child: Text("Weight Goal")),
    ];

    var form = Form(
      child: PaddedContainer(
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                items: dropdownItems,
                hint: const Text("I want to add.."),
                onChanged: (value) => _dropdownValue = dropdownItems.firstWhere((element) => element.value == value).dialog,
              ),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: onPressed)
          ],
        ),
      ),
    );

    return FutureBuilder(
      future: Future.wait([_exercisesFuture, _workoutsFuture]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var exercises = snapshot.data![0];
          var workouts = snapshot.data![1];

          return GenericPage(
            body: PaddedContainer(
              child: Column(
                children: [
                  form,
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  const SectionTitle(text: "Create a workout"),
                  WorkoutCreationForm(exercises: exercises, workouts: workouts),
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
