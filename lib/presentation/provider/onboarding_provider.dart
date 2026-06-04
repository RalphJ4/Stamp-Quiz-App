import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  static const String _doneKey = 'onboarding_done';
  static const String _nameKey = 'player_name';
  static const String _colorKey = 'avatar_color';

  int _currentStep = 0;
  String _playerName = '';
  Color _avatarColor = const Color(0xFF7B2FBE);
  bool _completed = false;
  bool _loading = true;

  static const List<Color> presetColors = [
    Color(0xFF7B2FBE), // purple
    Color(0xFFFF6B6B), // red
    Color(0xFF42A5F5), // blue
    Color(0xFF66BB6A), // green
    Color(0xFFFFA726), // orange
    Color(0xFFE8B86D), // gold
  ];

  int get currentStep => _currentStep;
  String get playerName => _playerName;
  Color get avatarColor => _avatarColor;
  bool get completed => _completed;
  bool get loading => _loading;

  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  void setPlayerName(String name) {
    _playerName = name.trim();
    notifyListeners();
  }

  void setAvatarColor(Color color) {
    _avatarColor = color;
    notifyListeners();
  }

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_doneKey) ?? false;
  }

  Future<void> loadPreferences() async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _completed = prefs.getBool(_doneKey) ?? false;
    _playerName = prefs.getString(_nameKey) ?? '';
    final colorVal = prefs.getInt(_colorKey);
    if (colorVal != null) {
      _avatarColor = Color(colorVal);
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _completed = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doneKey, true);
    await prefs.setString(_nameKey, _playerName.isNotEmpty ? _playerName : 'Adventurer');
    await prefs.setInt(_colorKey, _avatarColor.toARGB32());
    notifyListeners();
  }

  int get stepCount => 5;
}
