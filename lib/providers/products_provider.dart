import 'package:flutter/material.dart';

class ProductsProvider extends ChangeNotifier {
  bool isDarkMode = false;

  void changeTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
