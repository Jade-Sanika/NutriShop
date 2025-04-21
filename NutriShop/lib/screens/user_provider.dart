import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _email = 'johndoe@example.com'; // Default email for testing

  String get email => _email;

  void login(String email) {
    _email = email;
    notifyListeners();
  }

  void logout() {
    _email = '';
    notifyListeners();
  }
}
