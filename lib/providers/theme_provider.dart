import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners(); // Update UI immediately

    // Save in background - don't await
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    });
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return; // Skip if no change
    _themeMode = mode;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    });
  }
}
