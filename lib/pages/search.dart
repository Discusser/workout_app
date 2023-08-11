import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/firebase/firestore_helper.dart';
import 'package:workout_app/pages/exercise.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/reusable_widgets/containers.dart';
import 'package:workout_app/reusable_widgets/exercise.dart';
import 'package:workout_app/reusable_widgets/loading.dart';

import '../firebase/firestore_types.dart';
import '../user_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, controller});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  late Future<String> _username;
  late Future<List<ExerciseModel>> _itemsFuture;

  List<ExerciseModel>? _visibleItems;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _username = Provider.of<UserModel>(context).username;

    _itemsFuture = getExercises();
  }

  Future<List<ExerciseModel>> getExercises() async {
    var username = await _username;
    return FirebaseFirestore.instance.getExercises(username);
  }

  void filterSearch(List<ExerciseModel> items, String value) {
    setState(() {
      _visibleItems = items.where((element) {
        value = value.toLowerCase();
        return element.name.toLowerCase().contains(value) ||
            Muscles.simplifyMuscleNames(element.targetMuscles, true).map((e) => e.toLowerCase()).join(" ").contains(value) ||
            element.targetMuscles.map((e) => e.toLowerCase()).join(" ").contains(value);
      }).toList();
    });
  }

  Widget _createPage(List<ExerciseModel> data) {
    _visibleItems ??= data;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              filterSearch(data, value);
            },
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Search",
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
            ),
          ),
        ),
        Flexible(
          child: ListView.builder(
            itemCount: _visibleItems!.length,
            itemBuilder: (context, index) => ExerciseCard(model: _visibleItems![index]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _createPage(snapshot.data!);
        } else {
          return const LoadingFuture();
        }
      },
    );

    return GenericPage(
      scrollable: false,
      body: PaddedContainer(
        child: futureBuilder,
      ),
    );
  }
}
