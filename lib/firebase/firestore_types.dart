import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/main.dart';
import 'package:workout_app/pages/statistics.dart';

class WorkoutSessionSetStatModel extends HasFormatteableData {
  WorkoutSessionSetStatModel({required this.date, required this.set, xAxisName, yAxisName, yAxisFormat})
      : super(
          xAxisName: xAxisName ?? "date",
          yAxisName: yAxisName ?? "kg",
          yAxisFormat: yAxisFormat ?? "{value} kg",
        );

  final DateTime date;
  final WorkoutSessionSetModel set;

  @override
  List<String> toFormattedTable() {
    return [
      "${set.reps} reps",
      "${set.kg} kg",
      MyApp.dateFormat.format(date),
    ];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "reps": set.reps,
      "kg": set.kg,
      "date": date,
    };
  }
}

class WorkoutSessionSetModel {
  const WorkoutSessionSetModel({required this.kg, required this.reps});

  final int kg;
  final int reps;

  factory WorkoutSessionSetModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;

    return WorkoutSessionSetModel.fromMap(data);
  }

  factory WorkoutSessionSetModel.fromMap(Map<String, dynamic> data) {
    return WorkoutSessionSetModel(kg: data["kg"], reps: data["reps"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "kg": kg,
      "reps": reps,
    };
  }
}

class WorkoutSessionExerciseModel {
  WorkoutSessionExerciseModel({required this.name, required this.sets});

  final String name;
  List<WorkoutSessionSetModel> sets;

  factory WorkoutSessionExerciseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;

    return WorkoutSessionExerciseModel.fromMap(data);
  }

  factory WorkoutSessionExerciseModel.fromMap(Map<String, dynamic> data) {
    var sets = (data["sets"] as List<dynamic>).map((e) => WorkoutSessionSetModel.fromMap(e)).toList();

    return WorkoutSessionExerciseModel(name: data["name"], sets: sets);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "sets": sets.map((e) => e.toFirestore()).toList(),
    };
  }
}

class UserWorkoutSessionStatModel extends HasFormatteableData {
  UserWorkoutSessionStatModel({required this.session, xAxisName, yAxisName, yAxisFormat})
      : super(
          xAxisName: xAxisName ?? "date",
          yAxisName: yAxisName ?? "minutes",
          yAxisFormat: yAxisFormat ?? "{value} mins",
        );

  final UserWorkoutSessionModel session;

  factory UserWorkoutSessionStatModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;

    return UserWorkoutSessionStatModel(session: UserWorkoutSessionModel.fromMap(data["model"]));
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "date": session.timeStart.toDate(),
      "minutes": session.minutes,
      "name": session.name,
    };
  }

  @override
  List<String> toFormattedTable() {
    return [
      session.name,
      "${session.minutes.toStringAsFixed(0)} minutes",
      MyApp.dateFormat.format(session.timeStart.toDate()),
    ];
  }
}

class UserWorkoutSessionModel {
  const UserWorkoutSessionModel({
    required this.active,
    required this.name,
    required this.exercises,
    required this.timeStart,
    this.timeEnd,
  });

  final bool active;
  final String name;
  final List<WorkoutSessionExerciseModel> exercises;
  final Timestamp timeStart;
  final Timestamp? timeEnd;

  int get minutes {
    return (timeEnd == null ? (active ? Timestamp.now().toDate() : timeStart.toDate()) : timeEnd!.toDate())
        .difference(timeStart.toDate())
        .inMinutes;
  }

  factory UserWorkoutSessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;

    return UserWorkoutSessionModel.fromMap(data);
  }

  factory UserWorkoutSessionModel.fromMap(Map<String, dynamic> data) {
    var exercises = <WorkoutSessionExerciseModel>[];
    for (var exercise in data["exercises"]) {
      exercises.add(WorkoutSessionExerciseModel.fromMap(exercise));
    }

    return UserWorkoutSessionModel(
      active: data["active"],
      name: data["name"],
      exercises: exercises,
      timeStart: data["time_start"],
      timeEnd: data["time_end"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "active": active,
      "name": name,
      "exercises": exercises.map((e) => e.toFirestore()).toList(),
      "time_start": timeStart,
      "time_end": timeEnd,
    };
  }
}

class WorkoutExerciseModel {
  const WorkoutExerciseModel({required this.kg, required this.name, required this.reps, required this.sets});

  final int kg;
  final String name;
  final int reps;
  final int sets;

  factory WorkoutExerciseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    return WorkoutExerciseModel.fromMap(snapshot.data()!);
  }

  factory WorkoutExerciseModel.fromMap(Map<String, dynamic> data) {
    return WorkoutExerciseModel(
      kg: data["kg"],
      name: data["name"],
      reps: data["reps"],
      sets: data["sets"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "kg": kg,
      "name": name,
      "reps": reps,
      "sets": sets,
    };
  }
}

class WorkoutModel {
  const WorkoutModel({required this.exercises, required this.name, required this.minutes});

  final List<WorkoutExerciseModel> exercises;
  final String name;
  final double minutes;

  factory WorkoutModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    return WorkoutModel.fromMap(snapshot.data()!);
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> data) {
    var exercises = <WorkoutExerciseModel>[];
    for (var exercise in data["exercises"]) {
      exercises.add(WorkoutExerciseModel.fromMap(exercise));
    }

    return WorkoutModel(exercises: exercises, name: data["name"], minutes: (data["minutes"] as num).toDouble());
  }

  Map<String, dynamic> toFirestore() {
    return {
      "exercises": exercises.map((e) => e.toFirestore()).toList(),
      "name": name,
      "minutes": minutes,
    };
  }
}

class ExerciseModel {
  ExerciseModel({required this.name, required this.targetMuscles, assistingMuscles, stabilizingMuscles, required this.description})
      : assistingMuscles = assistingMuscles ?? [],
        stabilizingMuscles = stabilizingMuscles ?? [];

  final String name;
  final List<String> targetMuscles;
  final List<String> assistingMuscles;
  final List<String> stabilizingMuscles;
  final String description;

  static List<String> asStringList(List<dynamic> list) {
    return list.map((e) => (e as String)).toList();
  }

  factory ExerciseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    var muscles = data["muscles"];
    return ExerciseModel(
      name: data["name"],
      targetMuscles: asStringList(muscles["target"] as List<dynamic>),
      assistingMuscles: asStringList(muscles["assisting"] as List<dynamic>),
      stabilizingMuscles: asStringList(muscles["stabilizing"] as List<dynamic>),
      description: data["description"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "muscles": {
        "target": targetMuscles,
        "assisting": assistingMuscles,
        "stabilizing": stabilizingMuscles,
      },
      "description": description,
    };
  }
}

class WeightModel extends HasFormatteableData {
  WeightModel({required this.date, required this.weight, xAxisName, yAxisName, yAxisFormat})
      : super(
          xAxisName: xAxisName ?? "date",
          yAxisName: yAxisName ?? "weight",
          yAxisFormat: yAxisFormat ?? "{value} kg",
        );

  DateTime date;
  double weight;

  factory WeightModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return WeightModel(
      date: (data["date"] as Timestamp).toDate(),
      weight: (data["weight"] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "weight": weight,
      "date": date,
    };
  }

  @override
  List<String> toFormattedTable() {
    return [
      "$weight kg",
      MyApp.dateFormat.format(date),
    ];
  }
}

class CardioSessionModel extends HasFormatteableData {
  CardioSessionModel({required this.date, required this.minutes, required this.kilometers, xAxisName, yAxisName, yAxisFormat})
      : super(
          xAxisName: xAxisName ?? "date",
          yAxisName: yAxisName ?? "kilometers",
          yAxisFormat: yAxisFormat ?? "{value} km",
        );

  final double minutes;
  DateTime date;
  double kilometers;

  factory CardioSessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return CardioSessionModel(
      date: (data["date"] as Timestamp).toDate(),
      minutes: (data["minutes"] as num).toDouble(),
      kilometers: (data["kilometers"] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "kilometers": kilometers,
      "minutes": minutes,
      "date": date,
    };
  }

  @override
  List<String> toFormattedTable() {
    return [
      "$kilometers km",
      "${minutes.toStringAsFixed(0)} minutes",
      MyApp.dateFormat.format(date),
    ];
  }
}

@Deprecated("This will be replaced by the workout session manually performed by the user")
class WorkoutSessionModel extends HasFormatteableData {
  WorkoutSessionModel({required this.date, required this.minutes, required this.name, xAxisName, yAxisName, yAxisFormat})
      : super(
          xAxisName: xAxisName ?? "date",
          yAxisName: yAxisName ?? "minutes",
          yAxisFormat: yAxisFormat ?? "{value} min",
        );

  final String name;
  DateTime date;
  double minutes;

  factory WorkoutSessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return WorkoutSessionModel(
      date: (data["date"] as Timestamp).toDate(),
      minutes: (data["minutes"] as num).toDouble(),
      name: data["name"],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "minutes": minutes,
      "date": date,
    };
  }

  @override
  List<String> toFormattedTable() {
    return [
      name,
      "${minutes.toStringAsFixed(0)} minutes",
      MyApp.dateFormat.format(date),
    ];
  }
}

class StatisticModel {
  StatisticModel({required this.data});

  final Map<String, dynamic> data;

  StatisticModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) : this(data: snapshot.data() ?? {});

  Map<String, dynamic> toFirestore() {
    return data;
  }
}

class StatisticsModel {
  StatisticsModel({required this.stats});

  final Map<String, List<StatisticModel>> stats;

  double get cardioTotalDistance {
    var cardio = stats["cardio"]!;
    var distance = 0.0;

    for (var stat in cardio) {
      distance += stat.data["kilometers"];
    }

    return distance;
  }

  double get cardioTotalTime {
    var cardio = stats["cardio"]!;
    var time = 0.0;

    for (var stat in cardio) {
      time += stat.data["minutes"];
    }

    return time;
  }

  double get weightAverageWeight {
    var weight = stats["weight"]!;
    var weightValue = 0.0;

    for (var stat in weight) {
      weightValue += stat.data["weight"];
    }

    return weightValue / weight.length;
  }

  double get workoutTotalTime {
    var cardio = stats["workouts"]!;
    var time = 0.0;

    for (var stat in cardio) {
      time += stat.data["minutes"];
    }

    return time;
  }
}

class ComparativeStatisticsModel {
  ComparativeStatisticsModel({required this.before, required this.after});

  final StatisticsModel? before;
  final StatisticsModel? after;
}

class GoalListModel {
  GoalListModel({required this.goals});

  final List<GoalModel> goals;

  factory GoalListModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    var goals = <GoalModel>[];
    for (var goal in data?["goals"]) {
      goals.add(GoalModel(completed: goal["completed"], goal: goal["goal"]));
    }

    return GoalListModel(goals: goals);
  }

  Map<String, dynamic> toFirestore() {
    var array = goals.map((model) => {"completed": model.completed, "goal": model.goal});

    return {
      "goals": array,
    };
  }
}

class GoalModel {
  const GoalModel({required this.completed, required this.goal});

  final bool completed;
  final String goal;

  factory GoalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return GoalModel(completed: data?["completed"], goal: data?["goal"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "completed": completed,
      "goal": goal,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModel && runtimeType == other.runtimeType && completed == other.completed && goal == other.goal;

  @override
  int get hashCode => completed.hashCode ^ goal.hashCode;

  @override
  String toString() {
    return 'GoalModel{completed: $completed, goal: $goal}';
  }
}
