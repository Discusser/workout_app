import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/extensions/message_helper.dart';
import 'package:workout_app/extensions/theme_helper.dart';

import '../reusable_widgets/containers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email must be provided";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password must be provided";
    }

    return null;
  }

  void _wrapSubmit(BuildContext context, void Function() submitFunction) {
    if (_formKey.currentState!.validate()) {
      submitFunction();
    }
  }

  void login(BuildContext context) {
    _wrapSubmit(context, () async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      } on FirebaseAuthException catch (e) {
        if (e.message != null) {
          context.showError(e.message!);
        }
      }
    });
  }

  void register(BuildContext context) {
    _wrapSubmit(context, () async {
      try {
        if (_usernameController.text.isEmpty) {
          context.showError("Username must be provided");
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
          var user = <String, dynamic>{
            "username": _usernameController.text,
            "email": _emailController.text,
            "timestamp": DateTime.now().millisecondsSinceEpoch
          };
          FirebaseFirestore.instance
              .collection("users")
              .add(user)
              .then((doc) => debugPrint("Created new document in users collection with id ${doc.id}"));
        }
      } on FirebaseAuthException catch (e) {
        if (e.message != null) {
          context.showError(e.message!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).color.background,
      body: SafeArea(
        child: PaddedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).color.onBackground),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                          decoration: const InputDecoration(hintText: "Username"),
                          keyboardType: TextInputType.name,
                          controller: _usernameController,
                          maxLength: 24),
                      TextFormField(
                          decoration: const InputDecoration(hintText: "Email"),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          validator: (value) => validateEmail(value),
                          controller: _emailController),
                      TextFormField(
                          decoration: const InputDecoration(hintText: "Password"),
                          keyboardType: TextInputType.visiblePassword,
                          autocorrect: false,
                          obscureText: true,
                          validator: (value) => validatePassword(value),
                          controller: _passwordController),
                      const SizedBox(height: 8.0),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        ElevatedButton(onPressed: () => login(context), child: const Text("Sign in")),
                        ElevatedButton(onPressed: () => register(context), child: const Text("Register"))
                      ])
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
