import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/firebase/firestore_types.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/pages/loading.dart';
import 'package:workout_app/pages/statistics.dart';
import 'package:workout_app/reusable_widgets/containers.dart';

import '../reusable_widgets/form_dialog.dart';
import '../user_data.dart';

class QueryDropdownItem<String> extends DropdownMenuItem<String> {
  const QueryDropdownItem({super.key, required super.child, required super.value, required this.query});

  final Future<List<HasFormatteableData>> Function(String username) query;
}

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  late Future<String> _username;
  late Future<List<HasFormatteableData>> _recordsFuture;
  late Future<List<ExerciseModel>> _exercisesFuture;

  Future<List<HasFormatteableData>> Function(String)? _dropdownValue;
  String? _value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Provider.of<StatisticChangeModel>(context);

    _username = Provider.of<UserModel>(context).id;

    _exercisesFuture = getExercises();
  }

  Future<List<ExerciseModel>> getExercises() async {
    var username = await _username;
    return FirebaseFirestore.instance.getExercises(username);
  }

  void onPressed() async {
    if (_dropdownValue != null) {
      var username = await _username;
      _recordsFuture = _dropdownValue!(username);
      setState(() {});
    }
  }

  Widget _createRecordView() {
    if (_dropdownValue == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: _recordsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              StatisticsHelper(context: context).makeTable(
                "Current Record",
                snapshot.data!.isNotEmpty ? [snapshot.data![0]] : <HasFormatteableData>[],
              ),
              StatisticsHelper(context: context).makeTable("Records", snapshot.data!),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _createForm(List<ExerciseModel> exercises) {
    var dropdownItems = [
      QueryDropdownItem(
        query: (username) => FirebaseFirestore.instance.getWorkoutTimeRecords(username),
        value: "Workout Time",
        child: const Text("Workout Time"),
      ),
      QueryDropdownItem(
        query: (username) => FirebaseFirestore.instance.getCardioDistanceRecords(username),
        value: "Cardio Distance",
        child: const Text("Cardio Distance"),
      ),
      QueryDropdownItem(
        query: (username) => FirebaseFirestore.instance.getCardioTimeRecords(username),
        value: "Cardio Time",
        child: const Text("Cardio Time"),
      ),
    ];

    for (var exercise in exercises) {
      dropdownItems.add(
        QueryDropdownItem(
          query: (username) => FirebaseFirestore.instance.getExerciseRecords(exercise.name, username),
          value: "${exercise.name} PR",
          child: Text("${exercise.name} PR"),
        ),
      );
    }

    return Form(
      child: PaddedContainer(
        child: Row(
          children: [
            Expanded(
              child: SearchChoices<String>.single(
                items: dropdownItems,
                value: _value,
                hint: "I want to see..",
                searchHint: "I want to see..",
                onChanged: (value) {
                  _value = value;
                  _dropdownValue = dropdownItems.firstWhere((element) => element.value == value).query;
                  onPressed();
                },
                onClear: () {
                  _value = null;
                  _dropdownValue = null;
                  setState(() {}); // Call setState to remove the data displayed
                },
                isExpanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GenericPage(
            body: PaddedContainer(
              child: Column(
                children: [
                  _createForm(snapshot.data!),
                  _createRecordView(),
                ],
              ),
            ),
          );
        } else {
          return const LoadingPage();
        }
      },
    );
  }
}
