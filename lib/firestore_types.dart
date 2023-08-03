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
    return {
      "goals": goals,
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
}