import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/settings.dart';
import '../user_data.dart';

class TopAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  @override
  State<TopAppBar> createState() => _TopAppBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _TopAppBarState extends State<TopAppBar> {
  late Future<String> _username;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;
  }

  void settings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsPage(preferences: Provider.of<SettingsModel>(context).preferences),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FutureBuilder(
        future: _username,
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
}
