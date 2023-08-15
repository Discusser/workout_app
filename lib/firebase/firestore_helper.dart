import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reusable_widgets/goal.dart';
import 'firestore_types.dart';

extension FirestoreDocumentHelper on FirebaseFirestore {
  DocumentReference<Map<String, dynamic>> colGoals(String username) => collection("goals").doc(username);
  DocumentReference<Map<String, dynamic>> colStats(String username) => collection("stats").doc(username);
  CollectionReference<Map<String, dynamic>> colWorkouts(String username) => collection("workouts").doc(username).collection("workouts");
  CollectionReference<Map<String, dynamic>> colWorkoutSessions(String username) =>
      collection("workouts").doc(username).collection("sessions");
  CollectionReference<Map<String, dynamic>> colExercises() => collection("exercises");

  Future<List<Goal>> getGoals(String username, {bool Function(GoalModel oldGoal, GoalModel goal)? onSubmitted}) async {
    var list = <Goal>[];

    var snapshot = await colGoals(username)
        .withConverter(fromFirestore: GoalListModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .get();

    if (snapshot.data() == null) {
      return [];
    }

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

  Future<List<String>> getWorkoutNames(String username, [GetOptions? options]) async {
    var workouts = <String>[];

    var snapshot = await colWorkouts(username).get(options);
    for (var doc in snapshot.docs) {
      workouts.add(doc.data()["name"]);
    }

    return workouts;
  }

  Future<void> addWorkoutStat(UserWorkoutSessionModel model, String username) async {
    await colStats(username).collection("workouts").add({
      "date": DateTime.now(),
      "minutes": model.minutes,
      "name": model.name,
      "model": model.toFirestore(),
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
    return mapToData(result);
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
    return mapToData(result);
  }

  Future<List<StatisticModel>> getStatPastWeek(String statCollection, String username) async {
    var result = await colStats(username)
        .collection(statCollection)
        .orderBy("date", descending: true)
        .limitToLast(7)
        .withConverter(fromFirestore: StatisticModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .get();
    return mapToData(result);
  }

  Future<List<UserWorkoutSessionStatModel>> getWorkouts(String username) async {
    var result = await colStats(username)
        .collection("workouts")
        .orderBy("date", descending: true)
        .withConverter(fromFirestore: UserWorkoutSessionStatModel.fromFirestore, toFirestore: (value, options) => value.toMap())
        .get();
    return mapToData(result);
  }

  Future<List<CardioSessionModel>> getCardio(String username) async {
    var result = await colStats(username)
        .collection("cardio")
        .orderBy("date", descending: true)
        .withConverter(fromFirestore: CardioSessionModel.fromFirestore, toFirestore: (value, options) => value.toMap())
        .get();
    return mapToData(result);
  }

  Future<List<WeightModel>> getWeight(String username) async {
    var result = await colStats(username)
        .collection("weight")
        .orderBy("date", descending: true)
        .withConverter(fromFirestore: WeightModel.fromFirestore, toFirestore: (value, options) => value.toMap())
        .get();
    return mapToData(result);
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
    return result.data()?["weight_goal"];
  }

  Future<List<UserWorkoutSessionStatModel>> getWorkoutTimeRecords(String username) async {
    var result = await colStats(username)
        .collection("workouts")
        .orderBy("date", descending: false)
        .withConverter(fromFirestore: UserWorkoutSessionStatModel.fromFirestore, toFirestore: (value, options) => value.toMap())
        .get();

    return getRecords(result, (data) => data.session.minutes).map((e) {
      e.yAxisName = "minutes";
      e.yAxisFormat = "{value} min";
      return e;
    }).toList();
  }

  Future<List<CardioSessionModel>> getCardioDistanceRecords(String username) async {
    var result = await colStats(username)
        .collection("cardio")
        .orderBy("date", descending: false)
        .withConverter(fromFirestore: CardioSessionModel.fromFirestore, toFirestore: (value, options) => value.toMap())
        .get();

    return getRecords(result, (data) => data.kilometers).map((e) {
      e.yAxisName = "kilometers";
      e.yAxisFormat = "{value} km";
      return e;
    }).toList();
  }

  Future<List<CardioSessionModel>> getCardioTimeRecords(String username) async {
    var result = await colStats(username)
        .collection("cardio")
        .orderBy("date", descending: false)
        .withConverter(fromFirestore: CardioSessionModel.fromFirestore, toFirestore: (value, options) => value.toMap())
        .get();

    return getRecords(result, (data) => data.minutes).map((e) {
      e.yAxisName = "minutes";
      e.yAxisFormat = "{value} min";
      return e;
    }).toList();
  }

  Future<List<WorkoutSessionSetStatModel>> getExerciseRecords(String exercise, String username) async {
    var result = await colStats(username)
        .collection("workouts")
        .orderBy("date", descending: false)
        .withConverter(fromFirestore: UserWorkoutSessionStatModel.fromFirestore, toFirestore: (value, options) => value.toMap())
        .get();

    var sets = <WorkoutSessionSetStatModel>[];

    for (var workout in mapToData(result)) {
      for (var exercise in workout.session.exercises.where((element) => element.name == exercise)) {
        var duration = const Duration(minutes: 0);

        sets.addAll(exercise.sets.map((e) {
          duration += const Duration(minutes: 1);
          return WorkoutSessionSetStatModel(
            date: workout.session.timeStart.toDate().add(duration),
            set: e,
          );
        }));
      }
    }

    return getRecordsFromList(
      sets,
      (data) => data.set.kg,
      (data) => data.set.reps,
    ).map((e) {
      e.yAxisName = "kg";
      e.yAxisFormat = "{value} kg";
      return e;
    }).toList();
  }

  // Future<List<WorkoutSessionSetModel>> getExerciseRecord(String exercise, String username) async {
  // var result = await colStats(username)
  //     .collection("workouts")
  //     .orderBy("date", descending: false)
  //     .withConverter(fromFirestore: UserWorkoutSessionStatModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
  //     .get();

  //   return getRecords(result, (data) => data.reps * data.kg).map((e) => null)
  // }

  Future<List<ExerciseModel>> getExercises(String username, [GetOptions? options]) async {
    var result = await colExercises().get(options);

    return result.docs.map((e) => ExerciseModel.fromFirestore(e, null)).toList();
  }

  Future<List<WorkoutModel>> getWorkoutModels(String username) async {
    var result = await colWorkouts(username)
        .withConverter(fromFirestore: WorkoutModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .get();

    return mapToData(result);
  }

  Future<List<String>> getWorkoutsWithExercise(String exercise, String username) async {
    var result = await getWorkoutModels(username);

    return result.where((element) => element.exercises.map((e) => e.name).contains(exercise)).map((e) => e.name).toList();
  }

  Future<bool> addWorkout(WorkoutModel model, String username, [bool? replace, GetOptions? options]) async {
    var workoutNames = await getWorkoutNames(username, options);

    if ((replace == null || !replace) && workoutNames.map((e) => e.toLowerCase()).contains(model.name.toLowerCase())) {
      return false;
    }

    await colWorkouts(username)
        .withConverter(fromFirestore: WorkoutModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .add(model);
    return true;
  }

  Future<String?> getActiveWorkoutSession(String username) async {
    var result = await colWorkoutSessions(username).where("active", isEqualTo: true).get();

    if (result.docs.length > 1) {
      debugPrint("There is more than one active workout session, this shouldn't be possible");
    } else if (result.docs.isEmpty) {
      return null;
    }

    return result.docs[0].id;
  }

  Future<bool> startWorkoutSession(String name, String username) async {
    var activeSession = await getActiveWorkoutSession(username);

    if (activeSession != null) {
      return false;
    }

    await colWorkoutSessions(username)
        .withConverter(fromFirestore: UserWorkoutSessionModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .add(
          UserWorkoutSessionModel(
            active: true,
            name: name,
            timeStart: Timestamp.now(),
            exercises: [],
          ),
        );
    return true;
  }

  Future<Timestamp?> endWorkoutSession(String username) async {
    var activeSession = await getActiveWorkoutSession(username);

    if (activeSession == null) {
      debugPrint("Tried to end the workout session but there are none active");
      return null;
    }

    var timeEnd = Timestamp.now();
    var data = {
      "active": false,
      "time_end": timeEnd,
    };

    await colWorkoutSessions(username)
        .withConverter(fromFirestore: UserWorkoutSessionModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
        .doc(activeSession)
        .update(data);
    return timeEnd;
  }

  Future<bool> updateWorkoutSession(List<WorkoutSessionExerciseModel> exercises, String username) async {
    var activeSession = await getActiveWorkoutSession(username);

    if (activeSession == null) {
      debugPrint("Tried to update the workout session but there are none active");
      return false;
    }

    // var session = await colWorkoutSessions(username)
    //     .withConverter(fromFirestore: UserWorkoutSessionModel.fromFirestore, toFirestore: (value, options) => value.toFirestore())
    //     .doc(activeSession)
    //     .get();
    // var data = session.data()!;

    await colWorkoutSessions(username).doc(activeSession).update({
      "exercises": exercises.map((e) => e.toFirestore()).toList(),
    });
    return true;
  }

  Future<void> removeWorkout(String name, String username) async {
    var ref = colWorkouts(username)
        .withConverter(fromFirestore: WorkoutModel.fromFirestore, toFirestore: (value, options) => value.toFirestore());
    var result = await ref.where("name", isEqualTo: name).get();

    if (result.docs.isNotEmpty) {
      ref.doc(result.docs[0].id).delete();
    }
  }

  List<T> getRecords<T, U>(QuerySnapshot<T> snapshot, Comparable<U> Function(T data) key, [Comparable<U> Function(T data)? key2]) {
    return getRecordsFromList(mapToData(snapshot), key, key2);
  }

  List<T> getRecordsFromList<T, U>(List<T> list, Comparable<U> Function(T data) key, [Comparable<U> Function(T data)? key2]) {
    Comparable<U>? biggest;
    Comparable<U>? biggest2;

    var records = <T>[];

    for (var data in list) {
      var current = key(data);
      var current2 = key2 != null ? key2(data) : null;
      var comparison = Comparable.compare(current, biggest ?? current);
      if (biggest == null || comparison > 0) {
        records.add(data);
        biggest = current;
        biggest2 = current2;
      } else if (comparison == 0 && current2 != null && biggest2 != null) {
        if (Comparable.compare(current2, biggest2) > 0) {
          records.add(data);
          biggest2 = current2;
        }
      }
    }

    return records.reversed.toList();
  }

  List<T> mapToData<T>(QuerySnapshot<T> snapshot) {
    return snapshot.docs.map((e) => e.data()).toList();
  }
}
