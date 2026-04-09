import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  final SharedPreferences _prefs;

  String _fontSize = 'Medium';
  List<String> _userInterests = [];
  bool _notificationsEnabled = false;

  String get fontSize => _fontSize;
  List<String> get userInterests => _userInterests;
  bool get notificationsEnabled => _notificationsEnabled;

  void _loadSettings() {
    _fontSize = _prefs.getString('fontSize') ?? 'Medium';
    _userInterests = _prefs.getStringList('userInterests') ?? [];
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? false;
    
    if (_notificationsEnabled) {
      NotificationService.instance.scheduleDailyReminder();
    }
    notifyListeners();
  }

  Future<void> setFontSize(String size) async {
    _fontSize = size;
    await _prefs.setString('fontSize', size);
    notifyListeners();
  }

  Future<void> addInterest(String interest) async {
    if (!_userInterests.contains(interest)) {
      _userInterests.add(interest);
      await _prefs.setStringList('userInterests', _userInterests);
      notifyListeners();
    }
  }

  Future<void> removeInterest(String interest) async {
    if (_userInterests.contains(interest)) {
      _userInterests.remove(interest);
      await _prefs.setStringList('userInterests', _userInterests);
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool('notificationsEnabled', enabled);
    
    if (enabled) {
      await NotificationService.instance.scheduleDailyReminder();
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }
    
    notifyListeners();
  }
}

