import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:path/path.dart" as p;
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/pages/settings.dart';

import '../firebase/firestore_types.dart';
import '../reusable_widgets/containers.dart';
import '../reusable_widgets/goal.dart';
import '../reusable_widgets/scrollables.dart';
import '../reusable_widgets/texts.dart';
import '../theme/app_theme.dart';
import '../user_data.dart';
import 'generic.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: Theme.of(context).text.headlineMedium));
  }
}

class WeekSummary extends StatelessWidget {
  const WeekSummary({super.key});

  @override
  Widget build(BuildContext context) {
    // todo: make this dynamic
    // todo: add the ability to add the data
    var listElements = [
      const StatisticText(
        text: "7.8 hours working out",
        progress: ProgressColor.up,
        value: "7%",
      ),
      const StatisticText(
        text: "12 km of cardio",
        progress: ProgressColor.down,
        value: "4%",
      ),
      const StatisticText(
        text: "4 PRs broken",
      ),
      StatisticText(
        text: "1.7 kg lost",
        progress: ProgressColor.progressive(70.67),
        value: "69.4 kg",
      ),
    ];

    var columnBodyRows = <Row>[];

    for (var element in listElements) {
      columnBodyRows.add(Row(children: [
        const Text("•"),
        const SizedBox(
          width: 4,
        ),
        element
      ]));
    }

    return PaddedContainer(
      child: Column(
        children: [
          const SectionTitle(text: "Past 7 days"),
          Container(
              alignment: Alignment.centerLeft,
              child: Column(
                children: columnBodyRows,
              )),
          const Divider(
            thickness: 2,
          )
        ],
      ),
    );
  }
}

class WorkoutListView extends StatelessWidget {
  const WorkoutListView({super.key});

  Widget _buildWorkout(BuildContext context, String name, String image, String time) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), color: Theme.of(context).color.surface),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(name, style: Theme.of(context).text.headlineSmall),
          Expanded(child: Image.asset(image, width: 160)),
          Text(time, style: Theme.of(context).text.titleSmall)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // todo: randomize image for workout based on workout exercise
    // todo: add the ability to create workouts
    var children = <Widget>[
      _buildWorkout(context, "Push", p.join('assets', 'dips.png'), "45 minutes"),
      _buildWorkout(context, "Pull", p.join('assets', 'romanian_deadlift.png'), "45 minutes"),
      _buildWorkout(context, "Legs", p.join('assets', 'leg_extension.png'), "45 minutes")
    ];

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

    _username = Provider.of<UserModel>(context, listen: false).username;

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
        future: _goalsFuture, // This is fine because the getGoals function is smart and will only fetch from database if necessary
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
    ));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        WeekSummary(),
        WorkoutListView(),
        GoalsListView(),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App',
      theme: Provider.of<SettingsModel>(context).get("dark_theme") == true
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: const GenericPage(body: HomePage()),
      debugShowCheckedModeBanner: false,
    );
  }
}