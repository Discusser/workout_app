import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/pages/settings.dart';
import 'package:workout_app/user_data.dart';

import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var database = FirebaseFirestore.instance;
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
      Provider.value(value: database),
      Provider.value(value: prefManager.preferences),
      ChangeNotifierProvider(create: (context) => userModel),
      ChangeNotifierProvider(create: (context) => SettingsModel(preferences: prefManager.preferences)),
    ],
    child: const MyApp(),
  ));
}
