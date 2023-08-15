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
    list.removeWhere((element) => element.isEmpty);
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
  bool _detailed = false;

  Widget _createMuscleList(List<String> values) {
    var copy = List<String>.from(values);
    copy = _detailed ? copy : Muscles.simplifyMuscleNames(copy, !_detailed).toSet().toList();
    copy.removeWhere((element) => element.isEmpty);
    var children = <Widget>[];

    for (int i = 0; i < copy.length; i++) {
      children.add(Text(
        "${i + 1}. ${copy[i]}",
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
          ],
        ),
      ),
    );
  }
}
