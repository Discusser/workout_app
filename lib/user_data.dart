import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  UserModel({required this.user});

  User? user;
  String? _username;
  String? _id;

  Future<String> get username async {
    if (user != null) {
      debugPrint("Fetching username for email address ${user?.email} from Firestore");
      await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: user?.email).get().then((querySnapshot) {
        if (querySnapshot.docs.length == 1) {
          _username = querySnapshot.docs.first.data()["username"];
        }
      });
    }

    return _username ?? null.toString();
  }

  Future<String> get id async {
    if (user != null) {
      _id = user!.uid;
    }

    return _id ?? null.toString();
  }

  bool get loggedIn => user != null;

  void updateUser(User? user) async {
    debugPrint("User has updated, new user has email address ${user?.email}");
    this.user = user;

    await username;
    await id;

    notifyListeners();
  }
}
