import 'package:flutter/material.dart';
import 'package:workout_app/pages/generic.dart';
import 'package:workout_app/pages/home.dart';
import 'package:workout_app/reusable_widgets/containers.dart';

import '../reusable_widgets/workout_creation.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericPage(
      body: PaddedContainer(
        child: Column(
          children: [
            WorkoutListView(),
            Divider(),
            SectionTitle(text: "Create a workout"),
            WorkoutCreationForm(),
          ],
        ),
      ),
    );
  }
}
