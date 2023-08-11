import 'package:flutter/material.dart';
import 'package:workout_app/extensions/string_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/firebase/firestore_types.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/reusable_widgets/containers.dart';

import 'home.dart';

class Muscles {
  static List<String> simplifyMuscleNames(List<String> muscles, bool remove) {
    var list = muscles.map((e) => simplifyMuscleName(e, remove)).toList();
    list.removeWhere((element) => element == "");
    return list;
  }

  static String simplifyMuscleName(String name, bool remove) {
    var value = map[name.toLowerCase()];

    if (value == null) {
      if (map.values.map((e) => e.toLowerCase()).contains(name.toLowerCase())) {
        return name;
      } else {
        return remove ? "" : name;
      }
    }

    return value;
  }

  static Map<String, String> _createMap(Map<List<String>, String> map) {
    var newMap = <String, String>{};
    for (var entry in map.entries) {
      var keyList = entry.key;
      for (var key in keyList) {
        newMap[key] = entry.value;
      }
    }
    return newMap;
  }

  static Map<String, String> map = _createMap({
    ["anterior deltoids", "posterior deltoids", "anterior deltoid", "posterior deltoid", "deltoid"]: "Shoulders",
    ["pectoralis major", "pectoralis minor", "pectoralis"]: "Chest",
    ["latissimus dorsi"]: "Lats",
    ["rhomboid major", "rhomboid minor, rhomboid"]: "Rhomboids",
    ["levator scapulae"]: "Neck",
    ["teres major", "teres minor"]: "Teres",
    ["triceps brachii"]: "Triceps",
    ["biceps brachii", "brachialis"]: "Biceps",
    ["trapezius"]: "Trapezius",
    [
      "rectus femoris",
      "vastus lateralis",
      "vastus intermedius",
      "vastus medialis",
      "quadriceps femoris",
      "quadriceps extensor",
      "quads",
    ]: "Quadriceps",
    ["erector spinae", "spinal erector"]: "Lower Back",
    ["buttocks", "gluteus maximus", "gluteus medius", "gluteus minimus"]: "Glutes",
    ["semimembranosus", "semitendinosus", "biceps femoris"]: "Hamstrings",
    [
      "adductor brevis",
      "pectineus",
      "gracilis",
      "obturator externus",
      "adductor magnus",
      "adductor minimus",
      "adductor longus",
    ]: "Hip Adductors",
    ["gastrocnemius", "soleus", "plantaris"]: "Calf",
    [
      "flexor carpi radialis",
      "palmaris longus",
      "flexor carpi ulnaris",
      "pronator teres",
      "flexor digitorum superficialis",
      "flexor digitorum profundus",
      "flexor pollicis longus",
      "pronator quadratus",
    ]: "Forearm Flexors",
    [
      "brachioradialis",
      "extensor carpi radialis longus",
      "extensor carpi radialis brevi",
      "extensor carpi ulnaris",
      "anconeus",
      "extensor digitorum",
      "extensor digit minimi",
      "abductor pollicis longus",
      "extensor pollicis longus",
      "extensor pollicis brevis",
      "extensor indicis",
      "supinator",
    ]: "Forearm Extensors",
    ["rectus abdominis", "abdominals"]: "Abs",
    ["core"]: "Core",
    ["obliques"]: "Obliques"
  });
}

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key, required this.model});

  final ExerciseModel model;

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  // late Future<String> _username;
  // late Future<List<String>> _workoutsFuture;

  bool _detailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // _username = Provider.of<UserModel>(context).username;
    // _workoutsFuture = getWorkouts();
  }

  // Future<List<String>> getWorkouts() async {
  //   var username = await _username;
  //   return FirebaseFirestore.instance.getWorkoutsWithExercise(widget.model.name, username);
  // }

  Widget _createMuscleList(List<String> values) {
    values = _detailed ? values : Muscles.simplifyMuscleNames(values, !_detailed).toSet().toList();
    var children = <Widget>[];

    for (int i = 0; i < values.length; i++) {
      children.add(Text(
        "${i + 1}. ${values[i]}",
        style: Theme.of(context).text.bodyLarge!.apply(fontSizeFactor: 1.2),
      ));
    }

    return Row(
      children: [
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ],
    );
  }

  Widget _createExerciseMusclesWorked() {
    var muscleLists = <Widget>[];

    if (widget.model.targetMuscles.isNotEmpty) {
      muscleLists.addAll([
        SectionTitle(text: "Target", style: Theme.of(context).text.headlineSmall),
        _createMuscleList(widget.model.targetMuscles),
      ]);
    }
    if (widget.model.assistingMuscles.isNotEmpty) {
      muscleLists.addAll([
        SectionTitle(text: "Assisting", style: Theme.of(context).text.headlineSmall),
        _createMuscleList(widget.model.assistingMuscles),
      ]);
    }
    if (widget.model.stabilizingMuscles.isNotEmpty && _detailed) {
      muscleLists.addAll([
        SectionTitle(text: "Stabilizers", style: Theme.of(context).text.headlineSmall),
        _createMuscleList(widget.model.stabilizingMuscles),
      ]);
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const SectionTitle(text: "Muscles Worked"),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(_detailed ? "Less" : "More"),
                onPressed: () {
                  setState(() {
                    _detailed = !_detailed;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Column(children: muscleLists),
      ],
    );
  }

  Widget _createExerciseDescription() {
    return Column(
      children: [
        const SectionTitle(text: "Description"),
        const SizedBox(height: 8.0),
        Text(widget.model.description, style: Theme.of(context).text.bodyLarge),
      ],
    );
  }

  Widget _createExerciseHeader() {
    return Column(
      children: [
        SectionTitle(text: widget.model.name),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).color.onBackground.withOpacity(0.75))),
          child: Image.asset(widget.model.name.asExerciseImage()),
        ),
      ],
    );
  }

  // Widget _createMiscInfo() {
  //   var futureBuilder = FutureBuilder(
  //       future: _workoutsFuture,
  //       builder: (context, snapshot) {
  //         var textStyle = Theme.of(context).text.bodyLarge;
  //         var children = <Widget>[Text("In workouts: ", style: textStyle)];

  //         if (snapshot.hasData) {
  //           if (snapshot.data!.isEmpty) {
  //             children.add(Text("None", style: textStyle));
  //           }
  //           for (var value in snapshot.data!) {
  //             children.add(Chip(
  //               label: Text(value),
  //               backgroundColor: AppColors.unusedBackground.withOpacity(0.25),
  //               elevation: 4.0,
  //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //             ));
  //           }
  //         } else {
  //           children.add(Text("Getting workouts", style: textStyle));
  //         }

  //         return Row(children: children);
  //       });

  //   return Column(
  //     children: [
  //       const SectionTitle(text: "More"),
  //       const SizedBox(height: 8.0),
  //       futureBuilder,
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GenericPage(
      body: PaddedContainer(
        child: Column(
          children: [
            _createExerciseHeader(),
            const Divider(),
            _createExerciseMusclesWorked(),
            const Divider(),
            _createExerciseDescription(),
            // const Divider(),
            // _createMiscInfo(), // TODO: find something useful to add here, or remove this forever
          ],
        ),
      ),
    );
  }
}
