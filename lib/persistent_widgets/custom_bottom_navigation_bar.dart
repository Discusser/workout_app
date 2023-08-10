import 'package:flutter/material.dart';
import 'package:workout_app/extensions/theme_helper.dart';

import '../route_manager.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).color.onSurface;

    return BottomAppBar(
      color: Theme.of(context).color.surface,
      height: 48 + 6 * 2,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          onPressed: () => RouteManager.pushNamed(context, '/records'),
          icon: Icon(Icons.emoji_events_outlined, color: color),
        ),
        IconButton(
          onPressed: () => RouteManager.pushNamed(context, '/search'),
          icon: Icon(Icons.search, color: color),
        ),
        IconButton(
          onPressed: () => RouteManager.clearAndPushNamed(context, '/'),
          icon: Icon(Icons.home, color: color),
        ),
        IconButton(
          onPressed: () => RouteManager.pushNamed(context, '/statistics'),
          icon: Icon(Icons.bar_chart, color: color),
        ),
      ]),
    );
  }
}
