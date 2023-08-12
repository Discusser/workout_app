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
import 'package:workout_app/route_manager.dart';
import 'package:workout_app/theme/app_theme.dart';

import '../reusable_widgets/containers.dart';
import '../reusable_widgets/form_dialog.dart';
import '../user_data.dart';

abstract class HasFormatteableData {
  HasFormatteableData({required this.xAxisName, required this.yAxisName, required this.yAxisFormat});

  String xAxisName;
  String yAxisName;
  String yAxisFormat;

  Map<String, dynamic> toFirestore();
  List<String> toFormattedTable();
}

class StatisticsHelper {
  const StatisticsHelper({required this.context});

  final BuildContext context;

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
    RouteManager.push(context, (context) => PlottedDataPage(data: future, title: title));
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
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return PaddedContainer(
              child: Column(
                children: [
                  sectionTitle,
                  const SizedBox(height: 8.0),
                  const Center(child: Text("There are no records to display")),
                ],
              ),
            );
          }

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
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<String> _username;
  late Future<List<WorkoutSessionModel>> _workoutsFuture;
  late Future<List<CardioSessionModel>> _cardioFuture;
  late Future<List<WeightModel>> _weightFuture;

  // Widget? _dropdownValue;

  // void onPressed() {
  //   if (_dropdownValue != null) {
  //     showDialog(context: context, builder: (context) => _dropdownValue!);
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Provider.of<StatisticChangeModel>(context);

    _username = Provider.of<UserModel>(context).username;
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

  @override
  Widget build(BuildContext context) {
    // var dropdownItems = const [
    //   DialogDropdownItem(dialog: AddWorkoutDialog(), value: "workout_session", child: Text("Workout Session")),
    //   DialogDropdownItem(dialog: AddCardioDialog(), value: "cardio_session", child: Text("Cardio Session")),
    //   DialogDropdownItem(dialog: AddWeightDialog(), value: "weight", child: Text("Weight")),
    //   DialogDropdownItem(dialog: SetGoalDialog(), value: "weight_goal", child: Text("Weight Goal")),
    // ];

    // var form = Form(
    //   child: PaddedContainer(
    //     child: Row(
    //       children: [
    //         Expanded(
    //           child: DropdownButtonFormField<String>(
    //             items: dropdownItems,
    //             hint: const Text("I want to add.."),
    //             onChanged: (value) => _dropdownValue = dropdownItems.firstWhere((element) => element.value == value).dialog,
    //           ),
    //         ),
    //         IconButton(icon: const Icon(Icons.add), onPressed: onPressed)
    //       ],
    //     ),
    //   ),
    // );

    var helper = StatisticsHelper(context: context);

    return GenericPage(
      body: PaddedContainer(
        child: Column(
          children: [
            // form,
            // const Divider(),
            helper.makeTableFromFuture("Workouts", _workoutsFuture),
            const Divider(),
            helper.makeTableFromFuture("Cardio", _cardioFuture),
            const Divider(),
            helper.makeTableFromFuture("Weight", _weightFuture),
          ],
        ),
      ),
    );
  }
}
