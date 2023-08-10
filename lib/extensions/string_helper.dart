import 'package:path/path.dart';

extension StringHelper on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String asExerciseImage() {
    return join('assets', 'exercises', "${toLowerCase().replaceAll(" ", "_")}.png");
  }
}
