import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';

import '../../user_data.dart';
import '../form_dialog.dart';

class SetGoalDialog extends StatefulWidget {
  const SetGoalDialog({super.key});

  @override
  State<SetGoalDialog> createState() => _SetGoalDialogState();
}

class _SetGoalDialogState extends State<SetGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  late Future<String> _username;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).id;
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return "Weight cannot be null";
    }

    return null;
  }

  Future<void> _onSubmitAsync() async {
    var username = await _username;
    FirebaseFirestore.instance.addWeightGoal(double.parse(_weightController.text), username);
  }

  bool onSubmit() {
    if (_formKey.currentState!.validate()) {
      _onSubmitAsync();
      Provider.of<StatisticChangeModel>(context, listen: false).change();
      context.succesSnackbar("Set Weight Goal!");
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: "Add Weight Goal",
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: FormDialog.formatFormChildren([
            TextFormField(
              decoration: const InputDecoration(hintText: "Weight (kg)"),
              keyboardType: TextInputType.number,
              autocorrect: false,
              validator: (value) => validateWeight(value),
              controller: _weightController,
            ),
          ]),
        ),
      ),
      onSubmit: onSubmit,
    );
  }
}
