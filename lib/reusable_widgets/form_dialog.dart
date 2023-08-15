import 'package:flutter/material.dart';

import 'containers.dart';

class StatisticChangeModel with ChangeNotifier {
  void change() {
    notifyListeners();
  }
}

class FormDialog extends StatefulWidget {
  const FormDialog({super.key, required this.title, required this.form, this.onSubmit, this.onSubmitAsync, this.buttonText});

  final String title;
  final Widget form;
  final bool Function()? onSubmit;
  final Future<bool> Function()? onSubmitAsync;
  final String? buttonText;

  static List<Widget> formatFormChildren(List<Widget> children) {
    return children.map((e) => Container(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList();
  }

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  Future<void> onPressed() async {
    if ((widget.onSubmitAsync == null || await widget.onSubmitAsync!()) && (widget.onSubmit == null || widget.onSubmit!())) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: PaddedContainer(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title),
            const SizedBox(height: 8.0),
            widget.form,
            ElevatedButton(
              onPressed: onPressed,
              child: Text(widget.buttonText ?? "Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
