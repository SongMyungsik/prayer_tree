import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultSeedColor = Color(0xFF7C5CBF);
const defaultPassword = '0691';

const seedColorPresets = [
  defaultSeedColor, // 보라 (기본)
  Color(0xFF3F6FD6), // 파랑
  Color(0xFF3F9B6C), // 초록
  Color(0xFFD68A3F), // 주황
  Color(0xFFD65B8F), // 핑크
  Color(0xFF2F9BA6), // 틸
];

const _themeModeKey = 'settings_theme_mode';
const _seedColorKey = 'settings_seed_color';
const _passwordKey = 'settings_app_password';

class AppSettings extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  Color seedColor = defaultSeedColor;
  String password = defaultPassword;
  bool loaded = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode = switch (prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final colorValue = prefs.getInt(_seedColorKey);
    if (colorValue != null) seedColor = Color(colorValue);
    password = prefs.getString(_passwordKey) ?? defaultPassword;
    loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> setSeedColor(Color color) async {
    seedColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.toARGB32());
  }

  Future<void> setPassword(String newPassword) async {
    password = newPassword;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, newPassword);
  }
}
