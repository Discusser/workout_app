import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/main.dart';

class FancyDatePicker extends StatefulWidget {
  FancyDatePicker({super.key, dateFormat, controller})
      : dateFormat = dateFormat ?? MyApp.dateFormat,
        controller = controller ?? TextEditingController();

  final DateFormat dateFormat;
  final TextEditingController controller;

  @override
  State<FancyDatePicker> createState() => _FancyDatePickerState();
}

class _FancyDatePickerState extends State<FancyDatePicker> {
  @override
  void initState() {
    super.initState();

    widget.controller.text = widget.dateFormat.format(DateTime.now());
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().copyWith(month: DateTime.now().month - 1),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = widget.dateFormat.format(pickedDate);

      setState(() {
        widget.controller.text = formattedDate;
      });
    }
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Date cannot be null";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: const InputDecoration(
        icon: Icon(Icons.calendar_today),
        labelText: "Date",
      ),
      validator: (value) => validateDate(value),
      readOnly: true,
      onTap: pickDate,
    );
  }
}
