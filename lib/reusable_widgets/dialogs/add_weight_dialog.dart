import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';

import '../../theme/app_theme.dart';
import '../../user_data.dart';
import '../form_dialog.dart';

class AddWeightDialog extends StatefulWidget {
  const AddWeightDialog({super.key});

  @override
  State<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<AddWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  late Future<String> _username;

  DateTime? _date;

  @override
  void initState() {
    super.initState();

    _username = Provider.of<UserModel>(context, listen: false).username;
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return "Weight cannot be null";
    }

    return null;
  }

  Future<void> _onSubmitAsync() async {
    var username = await _username;
    FirebaseFirestore.instance.addWeightStat(double.parse(_weightController.text), _date!, username);
  }

  bool onSubmit() {
    if (_formKey.currentState!.validate()) {
      _onSubmitAsync();
      context.snackbar("Added weight!", beforeText: [const Icon(Icons.check, color: AppColors.success)]);
      return true;
    }

    return false;
  }

  void onDateSubmitted(DateTime value) {
    _date = value;
  }

  @override
  Widget build(BuildContext context) {
    var initialDate = DateTime.now();

    _date = initialDate;

    return FormDialog(
      title: "Add Weight",
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