import 'package:flutter/material.dart';

class PaddedContainer extends StatelessWidget {
  const PaddedContainer(
      {super.key, required this.child, this.margin, this.height, this.width, this.padding, this.decoration, this.constraints});

  final Widget child;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final Decoration? decoration;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding == null ? const EdgeInsets.all(8.0) : const EdgeInsets.all(8.0).add(padding!),
      margin: margin,
      height: height,
      width: width,
      decoration: decoration,
      constraints: constraints,
      child: child,
    );
  }
}