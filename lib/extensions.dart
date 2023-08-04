
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/firestore_types.dart';
import 'package:workout_app/reusable_widgets.dart';

import 'app_theme.dart';

extension TextStyleHelper on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
}

extension ThemeDataHelper on ThemeData {
  ColorScheme get color => colorScheme;
  TextTheme get text => textTheme;
  IconThemeData get icon => iconTheme;
}

extension ColorMath on Color {
  static colorBetween(Color start, Color end, double factor) {
    int computeChannel(int startChannel, int endChannel) {
      return (factor * (endChannel - startChannel) + startChannel).round();
    }

    int r = computeChannel(start.red, end.red);
    int g = computeChannel(start.green, end.green);
    int b = computeChannel(start.blue, end.blue);

    return Color.fromARGB(255, r, g, b);
  }
}

extension ErrorHelper on BuildContext {
  void showError(String text) {
    showDialog(context: this, builder: (context) {
      return AlertDialog(
        icon: const Icon(Icons.error, color: AppColors.error),
        content: Text(text),
      );
    });
  }

  void loadingSnackbar(String text) {
    snackbar(text, beforeText: [
      const CircularProgressIndicator(strokeWidth: 2.0),
      const SizedBox(width: 8.0)
    ]);
  }

  void snackbar(String text, {List<Widget>? beforeText, List<Widget>? afterText}) {
    beforeText ??= [];
    afterText ??= [];

    var children = <Widget>[];

    children.addAll(beforeText);
    children.add(Text(text));
    children.addAll(afterText);

    genericSnackbar(text, children);
  }

  void genericSnackbar(String text, List<Widget> children) {
    ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Row(
          children: children
        ), action: SnackBarAction(label: "Hide", onPressed: () => {}))
    );
  }
}

extension FirestoreDocumentHelper on DocumentReference {
  Future<List<Goal>> getGoals({bool Function(GoalModel oldGoal, GoalModel goal)? onSubmitted}) async {
    var goals = <Goal>[];

    var snapshot = await withConverter(fromFirestore: GoalListModel.fromFirestore, toFirestore: (value, options) => value.toFirestore()).get();
    for (var model in snapshot.data()!.goals) {
      goals.add(Goal.fromModel(goalModel: model, onSubmitted: onSubmitted));
    }

    return goals;
  }

  Future<void> removeGoal(GoalModel model) async {
    debugPrint("To firestore: ${model.toFirestore()}");
    update({
      "goals": FieldValue.arrayRemove([model.toFirestore()])
    });
  }

  Future<void> addGoals(List<GoalModel> goals) async {
    var model = GoalListModel(goals: goals);
    await withConverter(fromFirestore: GoalListModel.fromFirestore, toFirestore: (value, options) => value.toFirestore()).set(model);
  }

  Future<void> insertGoal(int index, GoalModel model) async {
    var goals = await getGoals();
    var models = goals.map((goal) => GoalModel(completed: goal.completed, goal: goal.goal)).toList();
    models.insert(index, model);
    addGoals(models);
  }
}