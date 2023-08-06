import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';

import '../../theme/app_theme.dart';
import '../../user_data.dart';
import '../form_dialog.dart';

class AddWorkoutDialog extends StatefulWidget {
  const AddWorkoutDialog({super.key});

  @override
  State<AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();

  late Future<List<String>> _workoutsFuture;
  late Future<String> _username;

  DateTime? _date;
  String? _name;

  @override
  void initState() {
    super.initState();

    _username = Provider.of<UserModel>(context, listen: false).username;
    _workoutsFuture = getWorkouts();
  }

  Future<List<String>> getWorkouts() async {
    var username = await _username;
    var workouts = await FirebaseFirestore.instance.getWorkoutNames(username);
    return workouts;
  }

  List<Widget> formatFormChildren(List<Widget> children) {
    return children.map((e) => Container(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList();
  }

  String? validateMinutes(String? value) {
    if (value == null || value.isEmpty) {
      return "Minutes spent cannot be null";
    }

    return null;
  }

  Future<void> _onSubmitAsync() async {
    var username = await _username;
    FirebaseFirestore.instance.addWorkoutStat(_date!, int.parse(_minutesController.text), _name!, username);
  }

  bool onSubmit() {
    if (_formKey.currentState!.validate()) {
      _onSubmitAsync();
      context.snackbar("Added workout!", beforeText: [const Icon(Icons.check, color: AppColors.success)]);
      return true;
    }

    return false;
  }

  void onDropdownChanged(String? value) {
    if (value != null) {
      _name = value;
    }
  }

  void onDateSubmitted(DateTime value) {
    _date = value;
  }

  @override
  Widget build(BuildContext context) {
    var initialDate = DateTime.now();

    _date = initialDate;

    var dropdown = FutureBuilder(
      future: _workoutsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var items = snapshot.data!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();

          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(hintText: "Workout"),
            items: items,
            onChanged: (value) => onDropdownChanged(value),
          );
        } else {
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(hintText: "Workout"),
            items: const [],
            onChanged: (value) => onDropdownChanged(value),
          );
        }
      },
    );

    return FormDialog(
      title: "Add Workout",
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: FormDialog.formatFormChildren([
            dropdown,
            TextFormField(
              decoration: const InputDecoration(hintText: "Minutes spent"),
              keyboardType: TextInputType.number,
              autocorrect: false,
              validator: (value) => validateMinutes(value),
              controller: _minutesController,
            ),
            InputDatePickerFormField(
              initialDate: _date,
              firstDate: initialDate.copyWith(month: initialDate.month - 1),
              lastDate: initialDate,
              onDateSubmitted: (value) => onDateSubmitted(value),
            ),
          ]),
        ),
      ),
      onSubmit: onSubmit,
    );
  }
}
