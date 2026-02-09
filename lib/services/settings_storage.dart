import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int REFRESH_RATE_DEF = 10; /* In seconds */

class AppSettings {
  /* Here Fields */
  final int refreshRate;

  const AppSettings({
    required this.refreshRate,
  });

  /* Here Defaults */
  factory AppSettings.defaults() => const AppSettings(
      refreshRate: REFRESH_RATE_DEF,
  );

  AppSettings copyWith({
    int? refreshRate,
  }) {
    return AppSettings(
        refreshRate: refreshRate ?? this.refreshRate,
    );
  }
}


class SettingsRepository {
  static const _refreshRateKey = "refresh_rate";

  final SharedPreferences prefs;

  SettingsRepository(this.prefs);

  AppSettings load() {
    return AppSettings(
        refreshRate: prefs.getInt(_refreshRateKey) ?? REFRESH_RATE_DEF,
    );
  }

  Future<void> save(AppSettings s) async {
    await prefs.setInt(_refreshRateKey, s.refreshRate);
  }
}

class SettingsController extends ChangeNotifier {
  final SettingsRepository repo;
  late AppSettings _settings;

  AppSettings get settings => _settings;

  SettingsController(this.repo) {
    _settings = repo.load();
  }

  void setRefreshRate(int value) {
    _settings = _settings.copyWith(refreshRate: value);
    repo.save(_settings);
    notifyListeners();
  }
}
