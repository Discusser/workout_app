import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/settings.dart';
import '../route_manager.dart';
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
      actions: [
        IconButton(
          onPressed: () => RouteManager.pushNamed(context, '/settings'),
          icon: const Icon(Icons.settings),
        )
      ],
    );
  }
}
