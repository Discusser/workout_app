import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/extensions/theme_helper.dart';
import 'package:workout_app/user_data.dart';

import '../reusable_widgets/containers.dart';
import 'generic.dart';

abstract class SettingsOption<T> extends StatefulWidget {
  SettingsOption({
    super.key,
    required value,
    required this.label,
    required this.prefKey,
    required this.icon,
    required this.preferences,
    required this.onChanged,
  }) : value = preferences.get(prefKey) is T ? preferences.get(prefKey) : value;

  final T value;
  final String label;
  final String prefKey;
  final IconData icon;
  final SharedPreferences preferences;
  final void Function() onChanged;
}

abstract class _SettingsOptionState<U, T extends SettingsOption<U>> extends State<T> {
  U? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  void setValue(BuildContext context, U newValue);

  void onChanged(BuildContext context, U? newValue) {
    setState(() {
      if (newValue != null) {
        _value = newValue;
        setValue(context, _value!);
        widget.onChanged();
      }
    });
  }
}

class BoolSettingsOption extends SettingsOption<bool> {
  BoolSettingsOption({
    super.key,
    required super.value,
    required super.label,
    required super.prefKey,
    required super.icon,
    required super.preferences,
    required super.onChanged,
  });

  @override
  State<BoolSettingsOption> createState() => _BoolSettingsOptionState();
}

class _BoolSettingsOptionState extends _SettingsOptionState<bool, BoolSettingsOption> {
  @override
  void setValue(BuildContext context, bool newValue) {
    Provider.of<SettingsModel>(context, listen: false).setBool(widget.prefKey, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.label),
      secondary: Icon(widget.icon),
      value: _value ?? widget.value,
      onChanged: (value) => onChanged(context, value),
    );
  }
}

class DoubleSettingsOption extends SettingsOption<double> {
  DoubleSettingsOption({
    super.key,
    required super.value,
    required super.label,
    required super.prefKey,
    required super.icon,
    required super.preferences,
    required super.onChanged,
  })  : controller = TextEditingController(),
        focusNode = FocusNode();

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<DoubleSettingsOption> createState() => _DoubleSettingsOptionState();
}

class _DoubleSettingsOptionState extends _SettingsOptionState<double, DoubleSettingsOption> {
  @override
  void setValue(BuildContext context, double newValue) {
    Provider.of<SettingsModel>(context, listen: false).setDouble(widget.prefKey, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return OptionWidget(
      title: Text("Max Weight Tolerance", style: Theme.of(context).text.bodyLarge),
      trailing: Expanded(
        child: TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "kg",
          ),
          controller: widget.controller,
          enabled: true,
          autocorrect: false,
          textAlignVertical: TextAlignVertical.center,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 3,
          onSubmitted: (value) => onChanged(context, double.tryParse(value)),
        ),
      ),
    );
  }
}

class OptionWidget extends StatelessWidget {
  const OptionWidget({super.key, this.icon, this.title, this.trailing});

  final Widget? icon;
  final Widget? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return PaddedContainer(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          icon,
          title,
          const Spacer(flex: 1),
          trailing,
        ].nonNulls.toList(),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void valueChanged() {
    setState(() {});
  }

  Widget _sectionDivider() {
    return const PaddedContainer(child: Divider(thickness: 2));
  }

  void signOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Provider.of<UserModel>(context, listen: false).updateUser(null);
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      BoolSettingsOption(
        value: false,
        label: "Dark Theme",
        prefKey: "dark_theme",
        preferences: widget.preferences,
        icon: Icons.brightness_3,
        onChanged: valueChanged,
      ),
      DoubleSettingsOption(
        value: 20,
        label: "Maximum Weight Tolerance",
        prefKey: "max_weight_tolerance",
        preferences: widget.preferences,
        icon: Icons.scale,
        onChanged: valueChanged,
      ),
      _sectionDivider(),
      ElevatedButton(onPressed: () => signOut(context), child: const Text("Sign out"))
    ];

    return GenericPage(
      body: PaddedContainer(
          child: Column(
        children: children,
      )),
    );
  }
}

class PreferenceManager {
  PreferenceManager({required this.preferences}) {
    ifBoolNotSet("dark_theme", true);
    ifDoubleNotSet("max_weight_tolerance", 20);
  }

  void ifBoolNotSet(String key, bool value) {
    ifNotSet(key, (key, value) => preferences.setBool(key, value), value);
  }

  void ifDoubleNotSet(String key, double value) {
    ifNotSet(key, (key, value) => preferences.setDouble(key, value), value);
  }

  void ifNotSet<T>(String key, void Function(String key, T value) function, T value) {
    if (preferences.get(key) == null) {
      function(key, value);
    }
  }

  final SharedPreferences preferences;
}

class SettingsModel extends ChangeNotifier {
  SettingsModel({required this.preferences});

  final SharedPreferences preferences;

  Object get(String key) {
    return preferences.get(key)!;
  }

  void setBool(String key, bool value) {
    preferences.setBool(key, value);
    notifyListeners();
  }

  void setDouble(String key, double value) {
    preferences.setDouble(key, value);
    notifyListeners();
  }
}
