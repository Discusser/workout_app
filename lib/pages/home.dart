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
import 'package:workout_app/route_manager.dart';

import '../firebase/firestore_types.dart';
import '../reusable_widgets/containers.dart';
import '../reusable_widgets/goal.dart';
import '../reusable_widgets/scrollables.dart';
import '../reusable_widgets/texts.dart';
import '../theme/app_theme.dart';
import '../user_data.dart';
import 'generic.dart';
import 'loading.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: style ?? Theme.of(context).text.headlineMedium));
  }
}

class WeekSummary extends StatelessWidget {
  const WeekSummary({super.key, required this.stats, required this.weightGoal});

  final ComparativeStatisticsModel stats;
  final double weightGoal;

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

  Widget constructListElements(BuildContext context, ComparativeStatisticsModel model, double weightGoal) {
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
      var weightCondition = after.weightAverageWeight < weightGoal;
      var weightColor = color(weightCondition ? difference : -difference, difference > 0 ? "+" : "-");
      children.add(_constructRow(
        StatisticText(
          text: "${validate(after.weightAverageWeight, 1)} kg",
          progress: ProgressColor.progressive(weightColor, after.weightAverageWeight, weightGoal, maxDistance),
          value: percent(difference.abs()),
        ),
      ));
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

  @override
  Widget build(BuildContext context) {
    var info = Column(
      children: [
        Text(style: Theme.of(context).text.headlineSmall, "Why is there no progress?"),
        Text(
          textAlign: TextAlign.center,
          style: Theme.of(context).text.bodyMedium,
          "This section calculates your data from the current week, and compares it to last week's data. If you're wondering why "
          "your progress is still at 0.0%, it probably means that there is no data to compare to from last week",
        ),
      ],
    );

    return PaddedContainer(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SectionTitle(text: "Past 7 days"),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => context.showInfo(info),
                  icon: const Icon(Icons.info_outline),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: constructListElements(context, stats, weightGoal),
          ),
          const Divider(
            thickness: 2,
          )
        ],
      ),
    );
  }
}

class WorkoutListView extends StatelessWidget {
  const WorkoutListView({super.key, required this.workouts});

  final List<WorkoutModel> workouts;

  Widget _buildWorkout(BuildContext context, WorkoutModel model) {
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
    var children = workouts.map((e) => _buildWorkout(context, e)).toList();

    return PaddedContainer(
        child: Column(
      children: [
        const SectionTitle(text: "Your Workouts"),
        SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: ScrollableListView(
            scrollDirection: Axis.horizontal,
            children: children,
          ),
        ),
        const Divider(
          thickness: 2,
        )
      ],
    ));
  }
}

class GoalsListView extends StatefulWidget {
  const GoalsListView({super.key, required this.goals});

  final List<Goal> goals;

  @override
  State<GoalsListView> createState() => _GoalsListViewState();
}

class _GoalsListViewState extends State<GoalsListView> {
  // late Future<List<Goal>> _goalsFuture;
  late Future<String> _username;

  List<Goal> _goals = <Goal>[];
  // bool _shouldFetchGoals = true; // Whether or not this state should fetch the goals from Firestore

  @override
  void initState() {
    super.initState();

    _goals = widget.goals.map((e) => Goal(completed: e.completed, goal: e.goal, onSubmitted: onSubmitted)).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;
    // _goalsFuture = getGoals();
  }

  /// Returns `false` if there is already a goal with the same text, returns `true` otherwise
  bool onSubmitted(GoalModel oldGoal, GoalModel goal) {
    // Check if a goal with the same text already exists
    if (checkForDuplicateGoal(_goals, goal.goal)) {
      return false;
    }

    // Get index of goal in _goals
    var index = _goals.indexWhere((element) => element.goal == oldGoal.goal);

    // Update _goals
    _goals[index] = Goal.fromModel(goalModel: goal, onSubmitted: onSubmitted);

    // Update Firestore
    _setGoal(index, oldGoal, goal);

    return true;
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

  // TODO: do something if there are no goals
  // perhaps:
  // fetch from DB, wait X seconds ---> response ---> return response
  //      |                                                 ^
  //      |                                                 |
  //      v                                                 |
  //   no response ---> create document doc(username) for next time
  // Future<List<Goal>> getGoals() async {
  //   if (!_shouldFetchGoals) {
  //     return _goals; // Return local version of goals
  //   }

  //   var username = await _username;
  //   var goals = <Goal>[];

  //   debugPrint("Getting goals for $username from Firestore");
  //   goals = await FirebaseFirestore.instance.getGoals(username, onSubmitted: onSubmitted);

  //   _goals = goals; // Cache goals from firestore
  //   _shouldFetchGoals = false;

  //   return goals;
  // }

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
          child: IconButton(
            onPressed: _addGoal,
            icon: const Icon(Icons.add_circle),
            color: AppColors.success.withOpacity(0.75),
          ),
        )
      ],
    );

    return PaddedContainer(
      child: Column(
        children: [title, _createDismissible(_goals)],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String> _username;
  late Future<List<Goal>> _goalsFuture;
  late Future<List<WorkoutModel>> _workoutsFuture;
  late Future<ComparativeStatisticsModel> _statsFuture;
  late Future<double?> _weightGoalFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;

    _goalsFuture = getGoals();
    _workoutsFuture = getWorkouts();
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

  Future<List<Goal>> getGoals() async {
    var username = await _username;
    var goals = <Goal>[];

    debugPrint("Getting goals for $username from Firestore");
    goals = await FirebaseFirestore.instance.getGoals(username);

    return goals;
  }

  Future<List<WorkoutModel>> getWorkouts() async {
    var username = await _username;
    return FirebaseFirestore.instance.getWorkoutModels(username);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_goalsFuture, _workoutsFuture, _statsFuture, _weightGoalFuture]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var goals = snapshot.data![0] as List<Goal>;
          var workouts = snapshot.data![1] as List<WorkoutModel>;
          var stats = snapshot.data![2] as ComparativeStatisticsModel;
          var weightGoal = snapshot.data![3] as double;

          return GenericPage(
            body: Column(
              children: [
                WeekSummary(stats: stats, weightGoal: weightGoal),
                WorkoutListView(workouts: workouts),
                GoalsListView(goals: goals),
              ],
            ),
          );
        } else {
          return const LoadingPage();
        }
      },
    );
  }
}
