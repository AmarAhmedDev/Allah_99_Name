import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _amharicAudioPrefKey = 'is_amharic_audio';
  bool _isAmharicAudio = false;

  bool get isAmharicAudio => _isAmharicAudio;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isAmharicAudio = prefs.getBool(_amharicAudioPrefKey) ?? true; // Amharic might be the default based on user intent, but let's default to false (English) to be safe or true, let's use true for Amharic or false for English. Let's make Amharic default.
    notifyListeners();
  }

  Future<void> toggleLanguage(bool isAmharic) async {
    if (_isAmharicAudio != isAmharic) {
      _isAmharicAudio = isAmharic;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_amharicAudioPrefKey, _isAmharicAudio);
      notifyListeners();
    }
  }
}
