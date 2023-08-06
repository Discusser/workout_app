import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reusable_widgets/goal.dart';
import 'firestore_types.dart';

extension FirestoreDocumentHelper on FirebaseFirestore {
  DocumentReference<Map<String, dynamic>> colGoals(String username) => collection("goals").doc(username);
  DocumentReference<Map<String, dynamic>> colStats(String username) => collection("stats").doc(username);
  CollectionReference<Map<String, dynamic>> colWorkouts(String username) => collection("workouts").doc(username).collection("workouts");

  Future<List<Goal>> getGoals(String username, {bool Function(GoalModel oldGoal, GoalModel goal)? onSubmitted}) async {
    var list = <Goal>[];

    var snapshot = await colGoals(username)
        .withConverter(fromFirestore: GoalListModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .get();
    for (var model in snapshot.data()!.goals) {
      list.add(Goal.fromModel(goalModel: model, onSubmitted: onSubmitted));
    }

    return list;
  }

  Future<void> removeGoal(GoalModel model, String username) async {
    colGoals(username).update({
      "goals": FieldValue.arrayRemove([model.toFirestore()])
    });
  }

  Future<void> addGoals(List<GoalModel> goals, String username) async {
    var model = GoalListModel(goals: goals);
    await colGoals(username)
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

    var snapshot = await colWorkouts(username).get();
    for (var doc in snapshot.docs) {
      workouts.add(doc.data()["name"]);
    }

    return workouts;
  }

  Future<void> addWorkoutStat(DateTime date, int minutes, String name, String username) async {
    Map<String, dynamic> data = {"date": date, "minutes": minutes, "name": name};
    await colStats(username).collection("workouts").add(data);
  }

  Future<void> addCardioStat(double kilometers, int minutes, DateTime date, String username) async {
    Map<String, dynamic> data = {"kilometers": kilometers, "minutes": minutes, "date": date};
    await colStats(username).collection("cardio").add(data);
  }

  Future<void> addWeightStat(double weight, DateTime date, String username) async {
    Map<String, dynamic> data = {"weight": weight, "date": date};
    await colStats(username).collection("weight").add(data);
  }
}
