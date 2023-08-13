import 'package:flutter/material.dart';
import 'package:workout_app/extensions/theme_helper.dart';

import '../firebase/firestore_types.dart';
import '../theme/app_theme.dart';

class Goal extends StatefulWidget {
  Goal({
    super.key,
    required this.completed,
    required this.goal,
    GoalModel? goalModel,
    bool Function(GoalModel oldGoal, GoalModel goal)? onSubmitted,
    bool? isFresh,
  })  : goalModel = goalModel ?? GoalModel(completed: completed, goal: goal),
        controller = TextEditingController(text: goal),
        focusNode = FocusNode(),
        onSubmitted = onSubmitted ?? ((oldGoal, goal) => true),
        isFresh = isFresh ?? false;

  Goal.fromModel({Key? key, required GoalModel goalModel, bool Function(GoalModel oldGoal, GoalModel goal)? onSubmitted})
      : this(
          key: key,
          completed: goalModel.completed,
          goal: goalModel.goal,
          goalModel: goalModel,
          onSubmitted: onSubmitted,
        );

  final GoalModel goalModel;
  final bool completed;
  final String goal;
  final TextEditingController controller;
  final bool Function(GoalModel oldGoal, GoalModel goal) onSubmitted;
  final FocusNode focusNode;
  final bool isFresh;

  @override
  State<Goal> createState() => _GoalState();
}

class _GoalState extends State<Goal> {
  GoalModel _oldGoal = const GoalModel(completed: false, goal: "");
  bool _completed = false;
  bool _isFresh = false; // Whether or not this state has just been added (using the add goal button)
  bool _enqueueFocus = false; // Whether or not focus should be requested on the next build call

  @override
  void initState() {
    super.initState();
    _completed = widget.completed;
    _isFresh = widget.isFresh;
    _oldGoal = GoalModel(completed: _completed, goal: widget.goal);

    if (_isFresh) {
      _enqueueFocus = true;
      _isFresh = false;
    }
  }

  void requestEnqueuedFocus() {
    if (!widget.focusNode.hasFocus && _enqueueFocus) {
      FocusScope.of(context).requestFocus(widget.focusNode);
      _enqueueFocus = false;
    }
  }

  void toggleCompletion() {
    setState(() {
      _completed = !_completed;
    });

    var model = GoalModel(completed: _completed, goal: widget.controller.text);
    widget.onSubmitted(_oldGoal, model);
    _oldGoal = model;
  }

  void onSubmitted(String text) {
    var model = GoalModel(completed: _completed, goal: text);

    if (widget.onSubmitted(_oldGoal, model) == false) {
      _enqueueFocus = true;
    }

    _oldGoal = model;
  }

  @override
  Widget build(BuildContext context) {
    var color = _completed ? AppColors.success.withOpacity(0.75) : AppColors.unusedBackground;
    var baseTextStyle = Theme.of(context).text.titleMedium!;
    var textStyle = _completed ? baseTextStyle.copyWith(decoration: TextDecoration.lineThrough) : baseTextStyle;
    var textField = TextField(
      decoration: InputDecoration(
          border: InputBorder.none, hintText: "A goal...", hintStyle: baseTextStyle.withColor(AppColors.unusedText), isCollapsed: true),
      controller: widget.controller,
      enabled: true,
      focusNode: widget.focusNode,
      style: textStyle,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onSubmitted: (text) => onSubmitted(text),
    );

    if (_enqueueFocus) {
      requestEnqueuedFocus();
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: toggleCompletion,
      child: Row(
        children: [
          Icon(_completed ? Icons.check_box : Icons.check_box_outline_blank),
          const SizedBox(width: 8.0),
          Expanded(child: textField)
        ],
      ),
    );
  }
}
