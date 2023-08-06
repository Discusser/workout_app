import 'package:flutter/material.dart';

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
        });
  }

  void loadingSnackbar(String text) {
    snackbar(text, beforeText: [const CircularProgressIndicator(strokeWidth: 2.0), const SizedBox(width: 8.0)]);
  }

  void snackbar(String text, {List<Widget>? beforeText, List<Widget>? afterText}) {
    beforeText ??= [];
    afterText ??= [];

    var children = <Widget>[];

    children.addAll(beforeText);
    children.add(Text(text));
    children.addAll(afterText);

    genericSnackbar(text, children);
  }

  void genericSnackbar(String text, List<Widget> children) {
    ScaffoldMessenger.of(this)
        .showSnackBar(SnackBar(content: Row(children: children), action: SnackBarAction(label: "Hide", onPressed: () => {})));
  }
}