import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

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
    await colStats(username).collection("workouts").add({
      "date": date,
      "minutes": minutes,
      "name": name,
    });
  }

  Future<void> addCardioStat(double kilometers, int minutes, DateTime date, String username) async {
    await colStats(username).collection("cardio").add({
      "kilometers": kilometers,
      "minutes": minutes,
      "date": date,
    });
  }

  Future<void> addWeightStat(double weight, DateTime date, String username) async {
    await colStats(username).collection("weight").add({
      "weight": weight,
      "date": date,
    });
  }

  Future<List<StatisticModel>> getPreviousStat(String statCollection, String username) async {
    var result = await colStats(username)
        .collection(statCollection)
        .orderBy("date", descending: true)
        .limitToLast(14)
        .withConverter(fromFirestore: StatisticModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .get();
    return result.docs.map((e) => e.data()).toList();
  }

  Future<List<StatisticModel>> getStatWeekBefore(String statCollection, String username) async {
    var week = const Duration(days: 7);
    var result = await colStats(username)
        .collection(statCollection)
        .orderBy("date", descending: true)
        .where("date", isLessThanOrEqualTo: DateTime.now().subtract(week), isGreaterThanOrEqualTo: DateTime.now().subtract(week * 2))
        .limitToLast(7)
        .withConverter(fromFirestore: StatisticModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .get();
    return result.docs.map((e) => e.data()).toList();
  }

  Future<List<StatisticModel>> getStatPastWeek(String statCollection, String username) async {
    var result = await colStats(username)
        .collection(statCollection)
        .orderBy("date", descending: true)
        .limitToLast(7)
        .withConverter(fromFirestore: StatisticModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .get();
    return result.docs.map((e) => e.data()).toList();
  }

  Future<StatisticsModel?> getPreviousStats(String username) async {
    var cardio = await getStatWeekBefore("cardio", username);
    var weight = await getStatWeekBefore("weight", username);
    var workouts = await getStatWeekBefore("workouts", username);

    return StatisticsModel(stats: {
      "cardio": cardio,
      "weight": weight,
      "workouts": workouts,
    });
  }

  Future<StatisticsModel?> getStats(String username) async {
    var cardio = await getStatPastWeek("cardio", username);
    var weight = await getStatPastWeek("weight", username);
    var workouts = await getStatPastWeek("workouts", username);

    return StatisticsModel(stats: {
      "cardio": cardio,
      "weight": weight,
      "workouts": workouts,
    });
  }

  Future<void> addWeightGoal(double weight, String username) async {
    await colStats(username).set({
      "weight_goal": weight,
    });
  }

  Future<double?> getWeightGoal(String username) async {
    var result = await colStats(username).get();
    print("Result is ${result.data()}");
    return result.data()?["weight_goal"];
  }
}
