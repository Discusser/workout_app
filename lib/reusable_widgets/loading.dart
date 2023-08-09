import 'package:flutter/material.dart';

class LoadingFuture extends StatelessWidget {
  const LoadingFuture({super.key, text, sizedBox, progressIndicator, expanded})
      : text = text ?? "Loading..",
        sizedBox = sizedBox ?? const SizedBox(height: 8.0),
        progressIndicator = progressIndicator ?? const CircularProgressIndicator(),
        expanded = expanded ?? false;

  final String text;
  final Widget sizedBox;
  final Widget progressIndicator;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    var child = Center(
      child: Column(
        children: [
          Text(text),
          sizedBox,
          progressIndicator,
        ],
      ),
    );

    return expanded ? Expanded(child: child) : child;
  }
}
