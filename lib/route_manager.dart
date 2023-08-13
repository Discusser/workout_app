import 'package:flutter/material.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/pages/records.dart';
import 'package:workout_app/pages/search.dart';
import 'package:workout_app/pages/settings.dart';
import 'package:workout_app/pages/statistics.dart';
import 'package:workout_app/pages/add_data.dart';

class RouteManager {
  static final routes = {
    '/': (context) => const HomePage(),
    '/settings': (context) => const SettingsPage(),
    '/statistics': (context) => const StatisticsPage(),
    '/records': (context) => const RecordsPage(),
    '/search': (context) => const SearchPage(),
    '/workouts': (context) => const AddDataPage(),
  };

  static Future<Object?> push(BuildContext context, Widget Function(BuildContext context) builder) {
    return Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  static Future<Object?> pushNamed(BuildContext context, String route) {
    return Navigator.pushNamed(context, route);
  }

  static clear(BuildContext context) {
    Navigator.popUntil(context, (route) => false);
  }

  static Future<Object?> clearAndPushNamed(BuildContext context, String route) {
    clear(context);
    return pushNamed(context, route);
  }

  static Future<Object?> clearAndPush(BuildContext context, Widget Function(BuildContext context) builder) {
    clear(context);
    return push(context, builder);
  }
}
