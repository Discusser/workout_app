import 'package:flutter/material.dart';

class RouteManager {
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
