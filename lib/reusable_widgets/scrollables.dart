import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/viewport_offset.dart';

class ScrollableBody extends StatelessWidget {
  const ScrollableBody({super.key, required this.child, scrollDirection}) : scrollDirection = scrollDirection ?? Axis.vertical;

  final Widget child;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(scrollDirection: scrollDirection, child: IntrinsicHeight(child: child));
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

class ScrollableTable extends StatelessWidget {
  ScrollableTable({super.key, controller, scrollDirection, required this.children, this.border})
      : controller = controller ?? ScrollController(),
        scrollDirection = scrollDirection ?? Axis.vertical;

  final ScrollController controller;
  final Axis scrollDirection;
  final List<TableRow> children;
  final TableBorder? border;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      interactive: true,
      thumbVisibility: true,
      radius: const Radius.circular(8.0),
      controller: controller,
      child: Container(
        // decoration: BoxDecoration(border: Border.all(color: Theme.of(context).color.onBackground)),
        margin: scrollDirection == Axis.horizontal ? const EdgeInsets.only(bottom: 8.0) : const EdgeInsets.only(right: 8.0),
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: scrollDirection,
          child: Table(
            border: border,
            children: children,
          ),
        ),
      ),
    );
  }
}
