import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/reusable_widgets.dart';
import 'package:workout_app/user_data.dart';

import 'main.dart';

abstract class SettingsOption<T> extends StatefulWidget {
  SettingsOption({
    super.key,
    required active,
    required this.label,
    required this.prefKey,
    required this.icon,
    required this.preferences,
    required this.onChanged
  }) : active = preferences.get(prefKey) is T ? preferences.get(prefKey) : active;

  final T active;
  final String label;
  final String prefKey;
  final IconData icon;
  final SharedPreferences preferences;
  final void Function() onChanged;
}

abstract class _SettingsOptionState<T extends SettingsOption> extends State<T> {
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _active = widget.active;
  }

  void setValue(BuildContext context, Object newValue);

  void onChanged(BuildContext context, bool newValue) {
    setState(() {
      _active = newValue;
      setValue(context, _active);
      widget.onChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        title: Text(widget.label), secondary: Icon(widget.icon), value: _active, onChanged: (value) => onChanged(context, value));
  }
}

class BoolSettingsOption extends SettingsOption<bool> {
  BoolSettingsOption({
    super.key,
    required super.active,
    required super.label,
    required super.prefKey,
    required super.icon,
    required super.preferences,
    required super.onChanged
  });

  @override
  State<BoolSettingsOption> createState() => _BoolSettingsOptionState();
}

class _BoolSettingsOptionState extends _SettingsOptionState<BoolSettingsOption> {
  @override
  void setValue(BuildContext context, Object newValue) {
    Provider.of<SettingsModel>(context, listen: false).setBool(widget.prefKey, _active);
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
      BoolSettingsOption(active: false,
          label: "Dark Theme",
          prefKey: "dark_theme",
          preferences: widget.preferences,
          icon: Icons.brightness_3,
          onChanged: valueChanged),
      _sectionDivider(),
      ElevatedButton(onPressed: () => signOut(context), child: const Text("Sign out"))
    ];

    return GenericPage(
      body: PaddedContainer(child: Column(
        children: children,
      )),
    );
  }
}

class PreferenceManager {
  PreferenceManager({required this.preferences}) {
    ifBoolNotSet("dark_theme", true);
  }

  void ifBoolNotSet(String key, bool value) {
    ifNotSet(key, (key, value) => preferences.setBool(key, value), value);
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

  void setInt(String key, int value) {
    preferences.setInt(key, value);
    notifyListeners();
  }
}