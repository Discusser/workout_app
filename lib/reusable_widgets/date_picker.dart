import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FancyDatePicker extends StatefulWidget {
  FancyDatePicker({super.key, controller}) : controller = controller ?? TextEditingController();

  final TextEditingController controller;

  @override
  State<FancyDatePicker> createState() => _FancyDatePickerState();
}

class _FancyDatePickerState extends State<FancyDatePicker> {
  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().copyWith(month: DateTime.now().month - 1),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

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
