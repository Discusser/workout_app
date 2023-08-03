import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  UserModel({required this.user});

  User? user;
  String? _cachedUsername;
  String? _username;

  Future<String> get username async {
    if (_cachedUsername != null) {
      return _cachedUsername!; // Return cached value if it is present
    }

    if (user != null) {
      debugPrint("Updating user with new value ${user?.email}");
      await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: user?.email).get().then((querySnapshot) {
        debugPrint("Query executed. Length of output is ${querySnapshot.docs.length}");
        if (querySnapshot.docs.length == 1) {
          debugPrint("Query data is ${querySnapshot.docs.first.data()}");
          _username = querySnapshot.docs.first.data()["username"]; // Cache the value so that we don't have to run the query again.
          _cachedUsername = _username;
        } else {
          debugPrint("Query for users with email ${user?.email} resulted in more than one document. This should not be possible.");
        }
      });
    }

    return _username ?? null.toString();
  }
  bool get loggedIn => user != null;

  void updateUser(User? user) async {
    _cachedUsername = null; // Invalidate cache on user update
    this.user = user;

    await username;

    notifyListeners();
  }
}