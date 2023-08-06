import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/settings.dart';
import '../user_data.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  void settings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsPage(preferences: context.read<SharedPreferences>()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FutureBuilder(
        future: Provider.of<UserModel>(context).username,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!);
          } else {
            return const Text("...");
          }
        },
      ),
      actions: [IconButton(onPressed: () => settings(context), icon: const Icon(Icons.settings))],
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}