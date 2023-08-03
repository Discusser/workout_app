import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/extensions.dart';
import 'package:workout_app/firebase_options.dart';
import 'package:workout_app/reusable_widgets.dart';
import 'package:workout_app/settings.dart';
import 'package:workout_app/user_data.dart';

import 'app_theme.dart';

void main() async {
  // todo : add splash screen
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  var database = FirebaseFirestore.instance;
  var prefManager = PreferenceManager(preferences: await SharedPreferences.getInstance());
  var userModel = UserModel(user: null);
  
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      debugPrint("Signed out...");
    } else {
      debugPrint("Signed in! ${user.email}:${user.uid}");
    }
    userModel.updateUser(user);
  });

  runApp(MultiProvider(
    providers: [
      Provider.value(value: database),
      Provider.value(value: prefManager.preferences),
      ChangeNotifierProvider(create: (context) => userModel),
      ChangeNotifierProvider(create: (context) => SettingsModel(preferences: prefManager.preferences)),
    ],
    child: const MyApp(),
  ));
}

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
  List<Goal> _goals = <Goal>[];
  bool _shouldFetchGoals = true; // Whether or not this state should fetch the goals from Firestore
  late String _username;

  @override
  void initState() {
    super.initState();

    () async {
      _username = await Provider.of<UserModel>(context, listen: false).username;
    }();
  }

  void addGoal(BuildContext context) {
    setState(() {
      // todo: Open keyboard when the goal is added
      // todo: add goal to firebase
      print("adding goal");
      var goal = Goal(completed: false, goal: "", onSubmitted: onSubmitted, isFresh: true);
      _goals.insert(0, goal);
      print("goal added to _goals");
      // var username = await Provider.of<UserModel>(context).username;
      // FirebaseFirestore.instance.collection("goals").doc(username).withConverter(
      //     fromFirestore: GoalModel.fromFirestore,
      //     toFirestore: (value, options) => value.toFirestore(),
      // );
    });
  }

  void onSubmitted(String text) {
    // Update Firestore
  }

  Future<List<Goal>> getGoals() async {
    print("getGoals has been called and shouldFetchGoals is set to $_shouldFetchGoals, username is $_username");
    print("_goals: $_goals");

    if (!_shouldFetchGoals) {
      return _goals; // Return local version of goals
    }

    var goals = <Goal>[];

    goals = await FirebaseFirestore.instance.collection("goals").doc(_username).getGoals(onSubmitted: onSubmitted);

    print("Query has completed, it's result is $goals");

    _goals = goals; // Cache goals from firestore

    _shouldFetchGoals = false;

    return goals;
  }

  void _dismissGoalAsync(Goal goal) async {
    print("removing goal from firebase");

    // Remove entry from firebase
    await FirebaseFirestore.instance.collection("goals").doc(_username).removeGoal(goal.goalModel);
  }

  void dismissGoal(BuildContext context, Goal goal) {
    print("starting goal dismiss");

    _dismissGoalAsync(goal);

    print("async part complete, showing snackbar..");

    // Snackbar popup "goal removed"
    context.snackbar("Goal removed");
  }

  @override
  Widget build(BuildContext context) {
    var title = Stack(
      alignment: Alignment.center,
      children: [
        const SectionTitle(text: "Goals"),
        Align(alignment: Alignment.centerRight, child: IconButton(onPressed: () => addGoal(context), icon: const Icon(Icons.add_circle),
            color: AppColors.success.withOpacity(0.75)))
      ],
    );

    var goals = FutureBuilder(
        future: getGoals(), // This is fine because the getGoals function is smart and will only fetch from database if necessary
        builder: (context, snapshot) {
          print("attempting to get goals");
          if (snapshot.hasData) {
            _goals = snapshot.data!;
            print("snapshot has data $_goals");
            var dismissibleChildren = <Widget>[];
            for (int i = 0; i < _goals.length; i++) {
              var child = _goals[i];
              dismissibleChildren.add(Dismissible(key: UniqueKey(), child: child, onDismissed: (direction) => dismissGoal(context, child)));
            }
            return Column(children: dismissibleChildren);
          } else {
            print("no data yet");
            return Column(children: [
              Text("Fetching goals...", style: Theme.of(context).text.titleMedium),
              Container(margin: const EdgeInsets.all(8.0), height: 2.0, child: const LinearProgressIndicator()),
            ]);
          }
        },
    );

    return PaddedContainer(child: Column(
      children: [
        title,
        goals
      ],
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

class GenericPage extends StatelessWidget {
  const GenericPage({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<UserModel>(context).loggedIn) {
      return const LoginPage();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).color.background,
      appBar: const TopAppBar(),
      body: SafeArea(
        child: ScrollableBody(child: body),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email must be provided";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password must be provided";
    }

    return null;
  }

  void _wrapSubmit(BuildContext context, void Function() submitFunction) {
    if (_formKey.currentState!.validate()) {
      submitFunction();
    }
  }

  void login(BuildContext context) {
    _wrapSubmit(context, () async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      } on FirebaseAuthException catch (e) {
        if (e.message != null) {
          context.showError(e.message!);
        }
      }
    });
  }

  void register(BuildContext context) {
    _wrapSubmit(context, () async {
      try {
        if (_usernameController.text.isEmpty) {
          context.showError("Username must be provided");
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
          var user = <String, dynamic>{
            "username": _usernameController.text,
            "email": _emailController.text,
            "timestamp": DateTime.now().millisecondsSinceEpoch
          };
          FirebaseFirestore.instance.collection("users").add(user).then((doc) => debugPrint("Created new document in users collection with id ${doc.id}"));
        }
      } on FirebaseAuthException catch (e) {
        if (e.message != null) {
          context.showError(e.message!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).color.background,
      body: SafeArea(
        child: PaddedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).color.onBackground),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(decoration: const InputDecoration(hintText: "Username"), keyboardType: TextInputType.name,
                          controller: _usernameController, maxLength: 24),
                      TextFormField(decoration: const InputDecoration(hintText: "Email"), keyboardType: TextInputType.emailAddress,
                          autocorrect: false, validator: (value) => validateEmail(value), controller: _emailController),
                      TextFormField(decoration: const InputDecoration(hintText: "Password"), keyboardType: TextInputType.visiblePassword,
                          autocorrect: false, obscureText: true, validator: (value) => validatePassword(value), controller: _passwordController),
                      const SizedBox(height: 8.0),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        ElevatedButton(onPressed: () => login(context), child: const Text("Sign in")),
                        ElevatedButton(onPressed: () => register(context), child: const Text("Register"))
                      ])
                    ],
                  ),
                ),
              )],
            ),
          ),
        ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App',
      theme: Provider.of<SettingsModel>(context).get("dark_theme") == true ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: const GenericPage(body: HomePage()),
      debugShowCheckedModeBanner: false,
    );
  }
}
