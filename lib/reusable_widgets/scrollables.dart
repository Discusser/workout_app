import 'package:flutter/material.dart';

class ScrollableBody extends StatelessWidget {
  const ScrollableBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: IntrinsicHeight(child: child));
  }
}

class ScrollableListView extends StatelessWidget {
  ScrollableListView({super.key, controller, scrollDirection, required this.children})
      : controller = controller ?? ScrollController(),
        scrollDirection = scrollDirection ?? Axis.vertical;

  final ScrollController controller;
  final Axis scrollDirection;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      interactive: true,
      thumbVisibility: true,
      radius: const Radius.circular(8.0),
      controller: controller,
      child: Container(
        margin: scrollDirection == Axis.horizontal ? const EdgeInsets.only(bottom: 8.0) : const EdgeInsets.only(right: 8.0),
        child: ListView(
          controller: controller,
          scrollDirection: scrollDirection,
          children: children,
        ),
      ),
    );
  }
}