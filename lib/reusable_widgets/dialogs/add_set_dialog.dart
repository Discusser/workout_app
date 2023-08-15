import 'package:flutter/material.dart';
import 'package:workout_app/firebase/firestore_types.dart';

import '../form_dialog.dart';

class AddSetDialog extends StatefulWidget {
  const AddSetDialog({super.key, required this.exercise, required this.workout, required this.exercises, required this.onSubmitAsync});

  final String exercise;
  final WorkoutModel workout;
  final List<WorkoutSessionExerciseModel> exercises;
  final Future<bool> Function(GlobalKey<FormState> key, String reps, String weight) onSubmitAsync;

  @override
  State<AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<AddSetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  String? validateNonNull(String? value) {
    if (value == null || value.isEmpty) {
      return "Value must not be null";
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

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: "Add set",
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: FormDialog.formatFormChildren([
            TextFormField(
              enabled: false,
              initialValue: widget.exercise,
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: "Reps"),
              keyboardType: TextInputType.number,
              autocorrect: false,
              validator: validateInt,
              controller: _repsController,
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: "Weight"),
              keyboardType: TextInputType.number,
              autocorrect: false,
              validator: validateInt,
              controller: _weightController,
            ),
          ]),
        ),
      ),
      onSubmitAsync: () => widget.onSubmitAsync(_formKey, _repsController.text, _weightController.text),
      buttonText: "Add",
    );
  }
}
