import 'package:flutter/material.dart';

class LoadingFuture extends StatelessWidget {
  const LoadingFuture({super.key, String? text, SizedBox? sizedBox, ProgressIndicator? progressIndicator})
      : text = text ?? "Loading..",
        sizedBox = sizedBox ?? const SizedBox(height: 8.0),
        progressIndicator = progressIndicator ?? const CircularProgressIndicator();

  final String text;
  final Widget sizedBox;
  final Widget progressIndicator;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          sizedBox,
          progressIndicator,
        ],
      ),
    );
  }
}
