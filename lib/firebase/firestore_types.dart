import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/main.dart';
import 'package:workout_app/pages/statistics.dart';

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
    return WeightModel(date: data["date"].toDate(), weight: data["weight"].toDouble());
  }

  @override
  Map<String, dynamic> toFirestore() {
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
    return CardioSessionModel(date: data["date"].toDate(), minutes: data["minutes"].toDouble(), kilometers: data["kilometers"].toDouble());
  }

  @override
  Map<String, dynamic> toFirestore() {
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
    return WorkoutSessionModel(date: data["date"].toDate(), minutes: data["minutes"].toDouble(), name: data["name"]);
  }

  @override
  Map<String, dynamic> toFirestore() {
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
