import 'package:flutter/material.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/pages/records.dart';
import 'package:workout_app/pages/settings.dart';
import 'package:workout_app/pages/statistics.dart';

class RouteManager {
  static final routes = {
    '/': (context) => const HomePage(),
    '/settings': (context) => const SettingsPage(),
    '/statistics': (context) => const StatisticsPage(),
    '/records': (context) => const RecordsPage(),
  };

  static Future<Object?> push(BuildContext context, Widget Function(BuildContext context) builder) {
    return Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  static Future<Object?> pushNamed(BuildContext context, String route) {
    return Navigator.pushNamed(context, route);
  }

  static Future<Object?> clearAndPushNamed(BuildContext context, String route) {
    Navigator.popUntil(context, (route) => false);
    return Navigator.pushNamed(context, route);
  }
}
