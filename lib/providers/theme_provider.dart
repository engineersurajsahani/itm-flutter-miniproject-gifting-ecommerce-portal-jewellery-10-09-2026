import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark;

  ThemeProvider() : _isDark = false {
    LuxuryTheme.isDark = _isDark;
  }

  bool get isDark => _isDark;

  void toggle() => setDark(!_isDark);

  void setDark(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    LuxuryTheme.isDark = value;
    notifyListeners();
  }
}
