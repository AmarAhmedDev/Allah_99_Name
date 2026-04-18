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
    _isAmharicAudio = prefs.getBool(_amharicAudioPrefKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleLanguage(bool isAmharic) async {
    if (_isAmharicAudio == isAmharic) return; // Skip if no change
    _isAmharicAudio = isAmharic;
    notifyListeners(); // Update UI immediately

    // Save in background
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_amharicAudioPrefKey, _isAmharicAudio);
    });
  }
}
