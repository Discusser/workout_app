import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reusable_widgets/goal.dart';
import 'firestore_types.dart';

extension FirestoreDocumentHelper on FirebaseFirestore {
  Future<List<Goal>> getGoals(String username, {bool Function(GoalModel oldGoal, GoalModel goal)? onSubmitted}) async {
    var goals = <Goal>[];

    var snapshot = await collection("goals")
        .doc(username)
        .withConverter(fromFirestore: GoalListModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .get();
    for (var model in snapshot.data()!.goals) {
      goals.add(Goal.fromModel(goalModel: model, onSubmitted: onSubmitted));
    }

    return goals;
  }

  Future<void> removeGoal(GoalModel model, String username) async {
    debugPrint("To firestore: ${model.toFirestore()}");
    collection("goals").doc(username).update({
      "goals": FieldValue.arrayRemove([model.toFirestore()])
    });
  }

  Future<void> addGoals(List<GoalModel> goals, String username) async {
    var model = GoalListModel(goals: goals);
    await collection("goals")
        .doc(username)
        .withConverter(fromFirestore: GoalListModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .set(model);
  }

  Future<void> insertGoal(int index, GoalModel model, String username) async {
    var goals = await getGoals(username);
    var models = goals.map((goal) => GoalModel(completed: goal.completed, goal: goal.goal)).toList();
    models.insert(index, model);
    addGoals(models, username);
  }

  Future<List<String>> getWorkoutNames(String username) async {
    var workouts = <String>[];

    var snapshot = await collection("workouts").doc(username).collection("workouts").get();
    for (var doc in snapshot.docs) {
      workouts.add(doc.data()["name"]);
    }

    return workouts;
  }

  Future<void> addWorkoutStat(DateTime date, int minutes, String name, String username) async {
    Map<String, dynamic> data = {"date": date, "minutes": minutes, "name": name};
    await collection("stats").doc(username).collection("workouts").add(data);
  }
}
