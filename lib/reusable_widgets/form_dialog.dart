import 'package:flutter/material.dart';

import 'containers.dart';

class FormDialog extends StatelessWidget {
  const FormDialog({super.key, required this.title, required this.form, this.onSubmit});

  final String title;
  final Widget form;
  final bool Function()? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: PaddedContainer(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(height: 8.0),
            form,
            ElevatedButton(
              onPressed: () {
                if (onSubmit!()) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
