import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/extensions.dart';
import 'package:workout_app/settings.dart';
import 'package:workout_app/user_data.dart';

import 'app_theme.dart';
import 'firestore_types.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  void settings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsPage(preferences: context.read<SharedPreferences>()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FutureBuilder(
        future: Provider.of<UserModel>(context).username,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!);
          } else {
            return const Text("...");
          }
        },
      ),
      actions: [IconButton(onPressed: () => settings(context), icon: const Icon(Icons.settings))],
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class ProgressColor {
  static const up = ProgressColor(color: AppColors.success, sign: "+");
  static const down = ProgressColor(color: AppColors.error, sign: "-");

  static progressive(double progress) {
    final color = ColorMath.colorBetween(AppColors.error, AppColors.success, (progress / 100));
    return ProgressColor(color: color, progress: progress);
  }

  const ProgressColor({required this.color, this.sign, this.progress});

  final Color color;
  final String? sign;
  final double? progress;
}

class StatisticText extends StatelessWidget {
  const StatisticText({super.key, required this.text, this.progress, this.value});

  final String text;
  final ProgressColor? progress;
  final String? value;

  @override
  Widget build(BuildContext context) {
    String displayText = text;
    var children = <TextSpan>[];
    var style = Theme.of(context).text.bodyLarge;

    if (progress != null && value != null) {
      displayText += " (";

      var coloredText = "";
      if (progress?.sign != null) {
        coloredText += progress!.sign!;
      }
      if (value != null) {
        coloredText += value!;
      }

      children.add(
        TextSpan(text: coloredText, style: style?.copyWith(color: progress?.color)),
      );

      if (progress?.progress != null) {
        var optionalColoredText = "${progress!.progress.toString()}%";

        children.addAll([
          TextSpan(text: ", ", style: style),
          TextSpan(text: optionalColoredText, style: style?.copyWith(color: progress?.color)),
          TextSpan(text: " to goal", style: style)
        ]);
      }

      children.add(
        TextSpan(text: ")", style: style),
      );
    }

    return RichText(
        text: TextSpan(text: displayText, style: style?.copyWith(color: Theme.of(context).color.onBackground), children: children));
  }
}

class PaddedContainer extends StatelessWidget {
  const PaddedContainer(
      {super.key, required this.child, this.margin, this.height, this.width, this.padding, this.decoration, this.constraints});

  final Widget child;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final Decoration? decoration;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding == null ? const EdgeInsets.all(8.0) : const EdgeInsets.all(8.0).add(padding!),
      margin: margin,
      height: height,
      width: width,
      decoration: decoration,
      constraints: constraints,
      child: child,
    );
  }
}

class ScrollableListView extends StatelessWidget {
  ScrollableListView({super.key, controller, scrollDirection, required this.children})
      : controller = controller ?? ScrollController(),
        scrollDirection = scrollDirection ?? Axis.vertical;

  final ScrollController controller;
  final Axis scrollDirection;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      interactive: true,
      thumbVisibility: true,
      radius: const Radius.circular(8.0),
      controller: controller,
      child: Container(
        margin: scrollDirection == Axis.horizontal ? const EdgeInsets.only(bottom: 8.0) : const EdgeInsets.only(right: 8.0),
        child: ListView(
          controller: controller,
          scrollDirection: scrollDirection,
          children: children,
        ),
      ),
    );
  }
}

class ScrollableBody extends StatelessWidget {
  const ScrollableBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: IntrinsicHeight(child: child));
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).color.onSurface;

    return BottomAppBar(
      color: Theme.of(context).color.surface,
      height: 48 + 6 * 2,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.emoji_events_outlined,
            color: color,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.history,
            color: color,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.add_circle_outline,
            color: color,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.search,
            color: color,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_horiz,
            color: color,
          ),
        )
      ]),
    );
  }
}

class Goal extends StatefulWidget {
  Goal({super.key, required this.completed, required this.goal, goalModel, required this.onSubmitted, isFresh})
      : goalModel = goalModel ?? GoalModel(completed: completed, goal: goal),
        controller = TextEditingController(text: goal),
        focusNode = FocusNode(),
        isFresh = isFresh ?? false;

  Goal.fromModel({Key? key, required GoalModel goalModel, void Function(String)? onSubmitted})
      : this(
            key: key,
            completed: goalModel.completed,
            goal: goalModel.goal,
            goalModel: goalModel,
            onSubmitted: onSubmitted ?? (s) {});

  final GoalModel goalModel;
  final bool completed;
  final String goal;
  final TextEditingController controller;
  final void Function(String text) onSubmitted;
  final FocusNode focusNode;
  final bool isFresh;

  @override
  State<Goal> createState() => _GoalState();
}

class _GoalState extends State<Goal> {
  bool _completed = false;
  bool _isFresh = false; // Whether or not this state has just been added (using the add goal button)
  bool _enqueueFocus = false; // Whether or not focus should be requested on the next build call

  @override
  void initState() {
    super.initState();
    _completed = widget.completed;
    _isFresh = widget.isFresh;

    if (_isFresh) {
      _enqueueFocus = true;
      _isFresh = false;
    }
  }

  void requestEnqueuedFocus() {
    FocusScope.of(context).requestFocus(widget.focusNode); // todo: FIX
    _enqueueFocus = false;
  }

  void toggleCompletion() {
    setState(() {
      _completed = !_completed;
    });
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
      onSubmitted: (text) => widget.onSubmitted(text),
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
