import 'package:cloud_firestore/cloud_firestore.dart';

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
