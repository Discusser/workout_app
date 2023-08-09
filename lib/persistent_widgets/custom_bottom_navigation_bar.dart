import 'package:flutter/material.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/pages/statistics.dart';

import '../pages/add_stat.dart';
import '../reusable_widgets/dialogs/add_cardio_dialog.dart';
import '../reusable_widgets/dialogs/add_weight_dialog.dart';
import '../reusable_widgets/dialogs/add_workout_dialog.dart';
import '../reusable_widgets/dialogs/set_goal_dialog.dart';
import '../reusable_widgets/menu_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  void page(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => page,
    ));
  }

  void _showDialog(BuildContext context, Widget child) {
    showDialog(context: context, builder: (context) => child);
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).color.onSurface;

    // var moreMenuBar = DirectionalMenuBar(
    //   width: 64,
    //   height: 64,
    //   textDirection: TextDirection.rtl,
    //   children: [
    //     MenuItemButton(onPressed: () {}, child: const Text("About")),
    //     SubmenuMenuItem(menuChildren: [
    //       MenuItemButton(onPressed: () => _showDialog(context, const AddWorkoutDialog()), child: const Text("Workout")),
    //       MenuItemButton(onPressed: () => _showDialog(context, const AddCardioDialog()), child: const Text("Cardio")),
    //       SubmenuMenuItem(menuChildren: [
    //         MenuItemButton(onPressed: () => _showDialog(context, const SetGoalDialog()), child: const Text("Set Goal")),
    //         MenuItemButton(onPressed: () => _showDialog(context, const AddWeightDialog()), child: const Text("Add")),
    //       ], child: const Text("Weight"))
    //     ], child: const Text("Add")),
    //   ],
    //   child: const Text("More"),
    // );

    return BottomAppBar(
      color: Theme.of(context).color.surface,
      height: 48 + 6 * 2,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.emoji_events_outlined,
            color: color,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.search,
            color: color,
          ),
        ),
        IconButton(
          onPressed: () => page(context, const StatisticsPage()),
          icon: Icon(
            Icons.bar_chart,
            color: color,
          ),
        ),
      ]),
    );
  }
}
