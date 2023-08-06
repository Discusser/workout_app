import 'package:cloud_firestore/cloud_firestore.dart';

class GoalListModel {
  GoalListModel({required this.goals});

  final List<GoalModel> goals;

  factory GoalListModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    var goals = <GoalModel>[];
    for (var goal in data?["goals"]) {
      goals.add(GoalModel(completed: goal["completed"], goal: goal["goal"]));
    }

    return GoalListModel(goals: goals);
  }

  Map<String, dynamic> toFirestore() {
    var array = goals.map((model) => {
      "completed": model.completed,
      "goal": model.goal
    });

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
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return GoalModel(
        completed: data?["completed"],
        goal: data?["goal"]
    );
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