import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/extensions/string_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/firebase/firestore_types.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/pages/plotted_data.dart';
import 'package:workout_app/reusable_widgets/loading.dart';
import 'package:workout_app/reusable_widgets/scrollables.dart';
import 'package:workout_app/theme/app_theme.dart';

import '../reusable_widgets/containers.dart';
import '../user_data.dart';

abstract class HasFormatteableData {
  Map<String, dynamic> toFirestore();
  String getXAxisName();
  String getYAxisName();
  String getYAxisFormat();
  List<String> toFormattedTable();
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<String> _username;
  late Future<List<WorkoutSessionModel>> _workoutsFuture;
  late Future<List<CardioSessionModel>> _cardioFuture;
  late Future<List<WeightModel>> _weightFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context, listen: false).username;
    _workoutsFuture = getWorkouts();
    _cardioFuture = getCardio();
    _weightFuture = getWeight();
  }

  Future<List<WorkoutSessionModel>> getWorkouts() async {
    var username = await _username;
    return FirebaseFirestore.instance.getWorkouts(username);
  }

  Future<List<CardioSessionModel>> getCardio() async {
    var username = await _username;
    return FirebaseFirestore.instance.getCardio(username);
  }

  Future<List<WeightModel>> getWeight() async {
    var username = await _username;
    return FirebaseFirestore.instance.getWeight(username);
  }

  void _addHeader(List<TableRow> list, List<String> headers) {
    var children = <Widget>[];

    for (int i = 0; i < headers.length; i++) {
      children.add(PaddedContainer(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: i == 0 ? 0 : 1,
              color: Theme.of(context).color.background,
            ),
          ),
        ),
        child: Text(
          headers[i],
          style: Theme.of(context).text.titleMedium,
        ),
      ));
    }

    list.add(TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Theme.of(context).color.background,
          ),
        ),
      ),
      children: children,
    ));
  }

  void _addRow(List<TableRow> list, List<String> cells) {
    var children = <Widget>[];

    for (int i = 0; i < cells.length; i++) {
      children.add(PaddedContainer(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: i == 0 ? 0 : 2,
              color: Theme.of(context).color.background,
            ),
            bottom: BorderSide(
              width: 2,
              color: Theme.of(context).color.background,
            ),
          ),
        ),
        child: Text(cells[i]),
      ));
    }

    list.add(TableRow(
      decoration: BoxDecoration(
        color: (list.length) % 2 == 0 ? AppColors.unusedBackground.withOpacity(0.18) : AppColors.unusedBackground.withOpacity(0.1),
      ),
      children: children,
    ));
  }

  List<String> _getHeaders(HasFormatteableData object) {
    return object.toFirestore().keys.map((e) => e.capitalize()).toList();
  }

  void plotData(Future<List<HasFormatteableData>> future, String title) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlottedDataPage(data: future, title: title),
    ));
  }

  Widget makeTableFromFuture(String title, Future<List<HasFormatteableData>> future) {
    var sectionTitle = Stack(
      alignment: Alignment.center,
      children: [
        SectionTitle(text: title),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => plotData(future, title),
          ),
        )
      ],
    );

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          var children = <TableRow>[];
          var headers = _getHeaders(snapshot.data![0]);

          _addHeader(children, headers);

          for (var element in snapshot.data!) {
            _addRow(children, element.toFormattedTable());
          }

          return PaddedContainer(
            child: Column(
              children: [
                sectionTitle,
                const SizedBox(height: 8.0),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
                  child: ScrollableTable(
                    children: children,
                  ),
                ),
              ],
            ),
          );
        } else {
          return PaddedContainer(
            child: Column(
              children: [
                sectionTitle,
                const LoadingFuture(),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GenericPage(
      body: PaddedContainer(
        child: Column(
          children: [
            makeTableFromFuture("Workouts", _workoutsFuture),
            const Divider(),
            makeTableFromFuture("Cardio", _cardioFuture),
            const Divider(),
            makeTableFromFuture("Weight", _weightFuture),
          ],
        ),
      ),
    );
  }
}
