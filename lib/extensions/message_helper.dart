import 'package:flutter/material.dart';
import 'package:workout_app/extensions/theme_helper.dart';

import '../theme/app_theme.dart';

extension ErrorHelper on BuildContext {
  void showError(String text) {
    showDialog(
      context: this,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.error, color: AppColors.error),
          content: Text(text),
        );
      },
    );
  }

  void showAlert(String text) {
    showDialog(
      context: this,
      builder: (context) {
        return AlertDialog(
          title: const Text("Warning"),
          content: Text(text, style: Theme.of(context).text.bodyLarge),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void succesSnackbar(String text) {
    snackbar(
      text,
      leading: const Icon(Icons.check, color: AppColors.success),
    );
  }

  void loadingSnackbar(String text) {
    snackbar(
      text,
      leading: const Row(
        children: [CircularProgressIndicator(strokeWidth: 2.0), SizedBox(width: 8.0)],
      ),
    );
  }

  void snackbar(String text, {Widget? leading, Widget? trailing}) {
    var children = <Widget>[];

    if (leading != null) {
      children.add(leading);
    }
    children.add(Text(text));
    if (trailing != null) {
      children.add(trailing);
    }

    genericSnackbar(text, children);
  }

  void genericSnackbar(String text, List<Widget> children) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Row(children: children),
      action: SnackBarAction(label: "Hide", onPressed: () => {}),
    ));
  }
}
