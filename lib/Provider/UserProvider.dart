import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? iduser;

  String? getUserId() => iduser;

  void setUserId(String id) {
    iduser = id;
    notifyListeners();
  }
}
