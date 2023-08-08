import 'package:flutter/material.dart';

class DirectionalMenuBar extends StatelessWidget {
  const DirectionalMenuBar({super.key, required this.textDirection, required this.children, required this.child, this.width, this.height});

  final TextDirection textDirection;
  final List<Widget> children;
  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child:
            MenuBar(children: [Directionality(textDirection: textDirection, child: SubmenuButton(menuChildren: children, child: child))]));
  }
}

class SubmenuMenuItem extends StatelessWidget {
  const SubmenuMenuItem({super.key, required this.menuChildren, required this.child});

  final List<Widget> menuChildren;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SubmenuButton(
      menuStyle: const MenuStyle(),
      menuChildren: menuChildren,
      child: child,
    );
  }
}
