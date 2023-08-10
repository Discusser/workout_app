import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/pages/settings.dart';
import 'package:workout_app/reusable_widgets/form_dialog.dart';
import 'package:workout_app/route_manager.dart';
import 'package:workout_app/user_data.dart';

import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var prefManager = PreferenceManager(preferences: await SharedPreferences.getInstance());
  var userModel = UserModel(user: null);

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      debugPrint("Signed out");
    } else {
      debugPrint("Signed in with email address ${user.email}");
    }
    userModel.updateUser(user);
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => StatisticChangeModel()),
      ChangeNotifierProvider(create: (context) => userModel),
      ChangeNotifierProvider(create: (context) => SettingsModel(preferences: prefManager.preferences)),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final dateFormat = DateFormat("dd-MM-yyyy");

  @override
  Widget build(BuildContext context) {
    var settingsModel = Provider.of<SettingsModel>(context);

    return MaterialApp(
      title: 'Workout App',
      theme: settingsModel.get("dark_theme") == true ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      initialRoute: '/',
      routes: RouteManager.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
