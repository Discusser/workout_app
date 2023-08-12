import 'package:flutter/material.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/reusable_widgets/containers.dart';

import '../reusable_widgets/dialogs/add_cardio_dialog.dart';
import '../reusable_widgets/dialogs/add_weight_dialog.dart';
import '../reusable_widgets/dialogs/add_workout_dialog.dart';
import '../reusable_widgets/dialogs/set_goal_dialog.dart';
import '../reusable_widgets/workout_creation.dart';

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
  Widget? _dropdownValue;

  void onPressed() {
    if (_dropdownValue != null) {
      showDialog(context: context, builder: (context) => _dropdownValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    var dropdownItems = const [
      DialogDropdownItem(dialog: AddWorkoutDialog(), value: "workout_session", child: Text("Workout Session")),
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
            const WorkoutCreationForm(),
          ],
        ),
      ),
    );
  }
}
