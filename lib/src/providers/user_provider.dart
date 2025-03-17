import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _uuid;
  String? _name;

  String? get uuid => _uuid;
  String? get name => _name;

  void setUser(String uuid, String name) {
    _uuid = uuid;
    _name = name;
    notifyListeners();
  }

  void clearUser() {
    _uuid = null;
    _name = null;
    notifyListeners();
  }
}
