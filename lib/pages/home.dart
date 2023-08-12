import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/extensions/num_helper.dart';
import 'package:workout_app/extensions/string_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/pages/settings.dart';
import 'package:workout_app/pages/workout.dart';
import 'package:workout_app/reusable_widgets/loading.dart';
import 'package:workout_app/route_manager.dart';

import '../firebase/firestore_types.dart';
import '../reusable_widgets/containers.dart';
import '../reusable_widgets/form_dialog.dart';
import '../reusable_widgets/goal.dart';
import '../reusable_widgets/scrollables.dart';
import '../reusable_widgets/texts.dart';
import '../theme/app_theme.dart';
import '../user_data.dart';
import 'generic.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: style ?? Theme.of(context).text.headlineMedium));
  }
}

class WeekSummary extends StatefulWidget {
  const WeekSummary({super.key});

  @override
  State<WeekSummary> createState() => _WeekSummaryState();
}

class _WeekSummaryState extends State<WeekSummary> {
  late Future<String> _username;
  late Future<ComparativeStatisticsModel> _statsFuture;
  late Future<double?> _weightGoalFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Provider.of<StatisticChangeModel>(context);

    _username = Provider.of<UserModel>(context).username;
    _statsFuture = getStats();
    _weightGoalFuture = getWeightGoal();
  }

  Future<double?> getWeightGoal() async {
    var username = await _username;
    return await FirebaseFirestore.instance.getWeightGoal(username);
  }

  Future<ComparativeStatisticsModel> getStats() async {
    var username = await _username;

    var before = await FirebaseFirestore.instance.getPreviousStats(username);
    var after = await FirebaseFirestore.instance.getStats(username);

    return ComparativeStatisticsModel(before: before, after: after);
  }

  Widget _constructRow(Widget statisticText) {
    return Row(
      children: [
        const Text("•"),
        const SizedBox(
          width: 4,
        ),
        statisticText
      ],
    );
  }

  Widget constructListElements(ComparativeStatisticsModel model) {
    double validate(double value, [int? digits]) {
      return value.isFinite ? double.parse(value.toStringAsFixed(digits ?? 2)) : 0.0;
    }

    ProgressColor color(double value, [String? sign]) {
      var comparison = validate(value).compareTo(0.0);
      var color = comparison == 0
          ? ProgressColor.none
          : comparison > 0
              ? ProgressColor.up
              : ProgressColor.down;

      if (sign != null) {
        color = ProgressColor(color: color.color, sign: sign);
      }

      return color;
    }

    String percent(double value) {
      return "${validate(value)}%";
    }

    var children = <Widget>[];
    var before = model.before;
    var after = model.after;

    if (before == null || after == null) {
      return const Column(children: []);
    }

    {
      // Cardio
      var difference = (after.cardioTotalDistance - before.cardioTotalDistance) / before.cardioTotalDistance * 100;
      children.add(_constructRow(
        StatisticText(
          text: "${validate(after.cardioTotalDistance)} km of cardio",
          progress: color(difference),
          value: percent(difference),
        ),
      ));
    }
    {
      // Weight
      var difference = (after.weightAverageWeight - before.weightAverageWeight) / before.weightAverageWeight * 100;
      var maxDistance = Provider.of<SettingsModel>(context).preferences.getDouble("max_weight_tolerance")!;
      children.add(_constructRow(FutureBuilder(
        future: _weightGoalFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var goal = snapshot.data!;
            var weightCondition = after.weightAverageWeight < goal;
            var weightColor = color(weightCondition ? difference : -difference, difference > 0 ? "+" : "-");
            return StatisticText(
              text: "${validate(after.weightAverageWeight, 1)} kg",
              progress: ProgressColor.progressive(weightColor, after.weightAverageWeight, goal, maxDistance),
              value: percent(difference.abs()),
            );
          } else {
            return StatisticText(
              text: "${validate(after.weightAverageWeight, 1)} kg",
              progress: ProgressColor.progressive(color(difference), after.weightAverageWeight, null, maxDistance),
              value: percent(difference),
            );
          }
        },
      )));
    }
    {
      // Workouts
      var difference = (after.workoutTotalTime - before.workoutTotalTime) / before.workoutTotalTime * 100;
      children.add(_constructRow(
        StatisticText(
          text: "${validate(after.workoutTotalTime / 60)} hours working out",
          progress: color(difference),
          value: percent(difference),
        ),
      ));
    }

    return Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: children);
  }

  void displayInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: PaddedContainer(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(style: Theme.of(context).text.headlineSmall, "Why is there no progress?"),
                Text(
                  textAlign: TextAlign.center,
                  style: Theme.of(context).text.bodyMedium,
                  "This section calculates your data from the current week, and compares it to last week's data. If you're wondering why "
                  "your progress is still at 0.0%, it probably means that there is no data to compare to from last week",
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var listElements = FutureBuilder(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return constructListElements(snapshot.data!);
        } else {
          return Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: [
            Text("Calculating statistics...", style: Theme.of(context).text.titleMedium),
            // Container(margin: const EdgeInsets.all(8.0), height: 2.0, child: const LinearProgressIndicator()),
          ]);
        }
      },
    );

    return PaddedContainer(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SectionTitle(text: "Past 7 days"),
              Align(alignment: Alignment.centerRight, child: IconButton(onPressed: displayInfo, icon: const Icon(Icons.info_outline))),
            ],
          ),
          Container(alignment: Alignment.centerLeft, child: listElements),
          const Divider(
            thickness: 2,
          )
        ],
      ),
    );
  }
}

class WorkoutListView extends StatefulWidget {
  const WorkoutListView({super.key});

  @override
  State<WorkoutListView> createState() => _WorkoutListViewState();
}

class _WorkoutListViewState extends State<WorkoutListView> {
  late Future<String> _username;
  late Future<List<WorkoutModel>> _workoutsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;

    _workoutsFuture = getWorkouts();
  }

  Future<List<WorkoutModel>> getWorkouts() async {
    var username = await _username;
    return FirebaseFirestore.instance.getWorkoutModels(username);
  }

  Widget _buildWorkout(WorkoutModel model) {
    var path = model.exercises[Random().nextInt(model.exercises.length)].name.asExerciseImage();

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), color: Theme.of(context).color.surface),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(4.0),
      child: Material(
        child: Ink(
          child: InkWell(
            onTap: () => RouteManager.push(context, (context) => WorkoutPage(model: model)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(model.name, style: Theme.of(context).text.headlineSmall),
                Expanded(child: Ink.image(image: AssetImage(path), width: MediaQuery.of(context).size.width / 2.5)),
                Text("${model.minutes.removeTrailingZeros(2)} minutes", style: Theme.of(context).text.titleSmall)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var future = FutureBuilder(
      future: _workoutsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var children = snapshot.data!.map((e) => _buildWorkout(e)).toList();

          return ScrollableListView(
            scrollDirection: Axis.horizontal,
            children: children,
          );
        } else {
          return const LoadingFuture();
        }
      },
    );

    return PaddedContainer(
        child: Column(
      children: [
        const SectionTitle(text: "Your Workouts"),
        SizedBox(height: MediaQuery.of(context).size.height / 4, child: future),
        const Divider(
          thickness: 2,
        )
      ],
    ));
  }
}

class GoalsListView extends StatefulWidget {
  const GoalsListView({super.key});

  @override
  State<GoalsListView> createState() => _GoalsListViewState();
}

class _GoalsListViewState extends State<GoalsListView> {
  late Future<List<Goal>> _goalsFuture;
  List<Goal> _goals = <Goal>[];
  bool _shouldFetchGoals = true; // Whether or not this state should fetch the goals from Firestore
  late Future<String> _username;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;
    _goalsFuture = getGoals();
  }

  void _addGoal() {
    if (_goals.where((element) => element.goal == "").isNotEmpty) {
      context.showError("There is already an empty goal that exists. Fill it or delete it.");
      return;
    }

    setState(() {
      debugPrint("Adding goal to _goals");
      var goal = Goal(completed: false, goal: "", onSubmitted: onSubmitted, isFresh: true);
      _goals.insert(0, goal);
    });
  }

  Future<void> _setGoal(int index, GoalModel oldGoal, GoalModel goal) async {
    // Get username and fetch goals from database
    var username = await _username;
    var goals = await FirebaseFirestore.instance.getGoals(username);

    // If this goal was already present in the database before changing it, remove it so it can be replaced with the new value
    var matches = goals.where((element) => element.goalModel == oldGoal);
    if (matches.isNotEmpty) {
      await FirebaseFirestore.instance.removeGoal(oldGoal, username);
    }

    // Insert the goal at the specified index into the database
    await FirebaseFirestore.instance.insertGoal(index, goal, username);
  }

  /// Returns `true` if there is already a goal with the same text, returns `false` otherwise
  bool checkForDuplicateGoal(List<Goal> list, String goal) {
    // Check if a goal with the same text already exists
    if (_goals.where((element) => element.goal == goal).length > 1) {
      context.showError("A goal with the same text already exists");
      return true;
    }

    return false;
  }

  /// Returns `false` if there is already a goal with the same text, returns `true` otherwise
  bool onSubmitted(GoalModel oldGoal, GoalModel goal) {
    // Check if a goal with the same text already exists
    if (checkForDuplicateGoal(_goals, goal.goal)) {
      return false;
    }

    // Get index of goal in _goals
    var index = _goals.indexWhere((element) => element.goal == oldGoal.goal);

    debugPrint("Index $index found for goal ${oldGoal.goal}");
    debugPrint("Here is the actual list: ${_goals.map((e) => e.goal).toList()}");
    // Update _goals
    _goals[index] = Goal.fromModel(goalModel: goal, onSubmitted: onSubmitted);

    // Update Firestore
    debugPrint("Updating Firestore with goal ${goal.goal}");
    _setGoal(index, oldGoal, goal);

    return true;
  }

  // todo: do something if there are no goals
  // perhaps:
  // fetch from DB, wait X seconds ---> response ---> return response
  //      |                                                 ^
  //      |                                                 |
  //      v                                                 |
  //   no response ---> create document doc(username) for next time
  Future<List<Goal>> getGoals() async {
    if (!_shouldFetchGoals) {
      return _goals; // Return local version of goals
    }

    var username = await _username;
    var goals = <Goal>[];

    debugPrint("Getting goals for $username from Firestore");
    goals = await FirebaseFirestore.instance.getGoals(username, onSubmitted: onSubmitted);

    _goals = goals; // Cache goals from firestore
    _shouldFetchGoals = false;

    return goals;
  }

  void _dismissGoalAsync(Goal goal) async {
    // Remove entry from firebase
    var username = await _username;
    await FirebaseFirestore.instance.removeGoal(goal.goalModel, username);
  }

  void dismissGoal(Goal goal) {
    debugPrint("Dismissing goal ${goal.goal}");

    _dismissGoalAsync(goal);
    _goals.removeWhere((element) => element.goal == goal.goal);

    // Snackbar popup "goal removed"
    context.snackbar("Goal removed");
  }

  Widget _createDismissible(List<Goal> goals) {
    var dismissibleChildren = <Widget>[];
    for (int i = 0; i < _goals.length; i++) {
      var child = _goals[i];
      dismissibleChildren.add(Dismissible(key: UniqueKey(), child: child, onDismissed: (direction) => dismissGoal(child)));
    }
    return Column(children: dismissibleChildren);
  }

  @override
  Widget build(BuildContext context) {
    var title = Stack(
      alignment: Alignment.center,
      children: [
        const SectionTitle(text: "Goals"),
        Align(
            alignment: Alignment.centerRight,
            child: IconButton(onPressed: _addGoal, icon: const Icon(Icons.add_circle), color: AppColors.success.withOpacity(0.75)))
      ],
    );

    Widget goals;
    if (_goals.isEmpty) {
      goals = FutureBuilder(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _goals = snapshot.data!;
            return _createDismissible(_goals);
          } else {
            return Column(children: [
              Text("Fetching goals...", style: Theme.of(context).text.titleMedium),
              Container(margin: const EdgeInsets.all(8.0), height: 2.0, child: const LinearProgressIndicator()),
            ]);
          }
        },
      );
    } else {
      goals = _createDismissible(_goals);
    }

    return PaddedContainer(
      child: Column(
        children: [title, goals],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericPage(
      body: Column(
        children: [
          WeekSummary(),
          WorkoutListView(),
          GoalsListView(),
        ],
      ),
    );
  }
}
