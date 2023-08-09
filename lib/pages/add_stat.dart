import 'package:flutter/material.dart';
import 'package:workout_app/reusable_widgets/containers.dart';
import 'package:workout_app/reusable_widgets/dialogs/add_cardio_dialog.dart';
import 'package:workout_app/reusable_widgets/dialogs/add_weight_dialog.dart';
import 'package:workout_app/reusable_widgets/dialogs/add_workout_dialog.dart';

import 'generic.dart';

class AddStatPage extends StatefulWidget {
  const AddStatPage({super.key});

  static final Map<String, void Function(BuildContext context)> dropdownOptions = {
    "workout_session": (context) => _showDialog(context, const AddWorkoutDialog()),
    "cardio_session": (context) => _showDialog(context, const AddCardioDialog()),
    "weight": (context) => _showDialog(context, const AddWeightDialog()),
  };

  static void _showDialog(BuildContext context, Widget child) {
    showDialog(context: context, builder: (context) => child);
  }

  @override
  State<AddStatPage> createState() => _AddStatPageState();
}

class _AddStatPageState extends State<AddStatPage> {
  String? _dropdownValue;

  void onPressed() {
    var func = AddStatPage.dropdownOptions[_dropdownValue];
    if (func != null) {
      func(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericPage(
      body: PaddedContainer(
        child: Column(children: [
          
        ]),
      ),
    );
  }
}
