import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/firebase/firestore_types.dart';
import 'package:workout_app/main.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/pages/loading.dart';
import 'package:workout_app/pages/workout_session.dart';
import 'package:workout_app/reusable_widgets/containers.dart';

import '../route_manager.dart';
import '../user_data.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<String> _username;
  late Future<List<UserWorkoutSessionStatModel>> _sessionsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).id;

    _sessionsFuture = getSessions();
  }

  Future<List<UserWorkoutSessionStatModel>> getSessions() async {
    var username = await _username;
    return FirebaseFirestore.instance.getWorkouts(username);
  }

  Widget _createListView(List<UserWorkoutSessionStatModel> sessions) {
    var border = BorderRadius.circular(10.0);
    var children = <Widget>[];

    for (var session in sessions) {
      var card = Card(
        child: InkWell(
          borderRadius: border,
          onTap: () => RouteManager.push(context, (context) => WorkoutSessionPage(session: session)),
          child: PaddedContainer(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).color.onBackground.withOpacity(0.75)),
              borderRadius: border,
            ),
            child: Table(
              children: [
                TableRow(
                  children: [
                    Text(
                      session.session.name,
                      style: Theme.of(context).text.titleMedium,
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      "${session.session.minutes} minutes",
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      MyApp.dateFormat.format(session.session.timeStart.toDate()),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      children.add(card);
    }

    return ListView(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GenericPage(
            scrollable: false,
            body: PaddedContainer(
              child: _createListView(snapshot.data!),
            ),
          );
        } else {
          return const LoadingPage();
        }
      },
    );
  }
}
