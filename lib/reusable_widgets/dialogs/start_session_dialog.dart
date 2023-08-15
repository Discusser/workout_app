import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';

import '../../user_data.dart';
import '../form_dialog.dart';

class HomePageNotifier with ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class StartSessionDialog extends StatefulWidget {
  const StartSessionDialog({super.key});

  @override
  State<StartSessionDialog> createState() => _StartSessionDialogState();
}

class _StartSessionDialogState extends State<StartSessionDialog> {
  final _formKey = GlobalKey<FormState>();

  late Future<List<String>> _workoutsFuture;
  late Future<String> _username;

  String? _name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).id;
    _workoutsFuture = getWorkouts();
  }

  Future<List<String>> getWorkouts() async {
    var username = await _username;
    var workouts = await FirebaseFirestore.instance.getWorkoutNames(username);
    return workouts;
  }

  Future<bool> onSubmit() async {
    // if (_formKey.currentState!.validate()) {
    // }

    if (_name == null || _name!.isEmpty) {
      return false;
    }

    var username = await _username;
    var started = await FirebaseFirestore.instance.startWorkoutSession(_name!, username);

    if (!mounted) {
      return false;
    }

    if (!started) {
      context.showAlert("There is already an active session, finish it before starting a new one.");
    } else {
      context.succesSnackbar("Started \"${_name!}\" session");
    }

    Provider.of<HomePageNotifier>(context, listen: false).notify();

    return true;
  }

  void onDropdownChanged(String? value) {
    if (value != null) {
      _name = value;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      title: "Start Workout Session",
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: FormDialog.formatFormChildren([
            dropdown,
          ]),
        ),
      ),
      onSubmitAsync: onSubmit,
      buttonText: "Start",
    );
  }
}
