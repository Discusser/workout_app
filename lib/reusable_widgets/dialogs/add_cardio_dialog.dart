import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/reusable_widgets/date_picker.dart';

import '../../theme/app_theme.dart';
import '../../user_data.dart';
import '../form_dialog.dart';

class AddCardioDialog extends StatefulWidget {
  const AddCardioDialog({super.key});

  @override
  State<AddCardioDialog> createState() => _AddCardioDialogState();
}

class _AddCardioDialogState extends State<AddCardioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _kilometersController = TextEditingController();
  final _minutesController = TextEditingController();
  final _dateController = TextEditingController();

  late Future<String> _username;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;
  }

  String? validateKilometers(String? value) {
    if (value == null || value.isEmpty) {
      return "Distance cannot be null";
    }

    return null;
  }

  String? validateMinutes(String? value) {
    if (value == null || value.isEmpty) {
      return "Minutes spent cannot be null";
    }

    return null;
  }

  Future<void> _onSubmitAsync() async {
    var username = await _username;
    FirebaseFirestore.instance.addCardioStat(
      double.parse(_kilometersController.text),
      int.parse(_minutesController.text),
      DateFormat("dd-MM-yyyy").parse(_dateController.text),
      username,
    );
  }

  bool onSubmit() {
    if (_formKey.currentState!.validate()) {
      _onSubmitAsync();
      Provider.of<StatisticChangeModel>(context, listen: false).change();
      context.snackbar("Added cardio!", beforeText: [const Icon(Icons.check, color: AppColors.success)]);
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: "Add Cardio",
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: FormDialog.formatFormChildren([
            TextFormField(
              decoration: const InputDecoration(hintText: "Distance (km)"),
              keyboardType: TextInputType.number,
              autocorrect: false,
              validator: (value) => validateKilometers(value),
              controller: _kilometersController,
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: "Minutes spent"),
              keyboardType: TextInputType.number,
              autocorrect: false,
              validator: (value) => validateMinutes(value),
              controller: _minutesController,
            ),
            FancyDatePicker(
              controller: _dateController,
            ),
          ]),
        ),
      ),
      onSubmit: onSubmit,
    );
  }
}
