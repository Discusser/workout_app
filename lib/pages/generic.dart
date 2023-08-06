import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/theme_helper.dart';

import '../persistent_widgets/custom_bottom_navigation_bar.dart';
import '../persistent_widgets/top_app_bar.dart';
import '../reusable_widgets/scrollables.dart';
import '../user_data.dart';
import 'login.dart';

class GenericPage extends StatelessWidget {
  const GenericPage({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<UserModel>(context).loggedIn) {
      return const LoginPage();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).color.background,
      appBar: const TopAppBar(),
      body: SafeArea(
        child: ScrollableBody(child: body),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
