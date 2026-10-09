import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/money.dart';

/// `main()`da bir marta yuklanadi va override qilinadi.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('main() da override qilinishi kerak'),
);

@immutable
class AppSettingsState {
  const AppSettingsState({
    required this.localeCode,
    required this.themeMode,
    required this.mainCurrencyCode,
    required this.monthStartDay,
    required this.weekStartsOn,
    required this.onboardingDone,
    required this.lastBackupAt,
  });

  final String localeCode;
  final ThemeMode themeMode;
  final String mainCurrencyCode;

  /// Moliyaviy oyning boshlanish kuni (1–28).
  final int monthStartDay;

  /// `DateTime.monday` yoki `DateTime.sunday`.
  final int weekStartsOn;

  final bool onboardingDone;
  final DateTime? lastBackupAt;

  Currency get mainCurrency => Currency.byCode(mainCurrencyCode);

  Locale get locale => Locale(localeCode);

  AppSettingsState copyWith({
    String? localeCode,
    ThemeMode? themeMode,
    String? mainCurrencyCode,
    int? monthStartDay,
    int? weekStartsOn,
    bool? onboardingDone,
    DateTime? lastBackupAt,
    bool clearLastBackup = false,
  }) {
    return AppSettingsState(
      localeCode: localeCode ?? this.localeCode,
      themeMode: themeMode ?? this.themeMode,
      mainCurrencyCode: mainCurrencyCode ?? this.mainCurrencyCode,
      monthStartDay: monthStartDay ?? this.monthStartDay,
      weekStartsOn: weekStartsOn ?? this.weekStartsOn,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      lastBackupAt:
          clearLastBackup ? null : (lastBackupAt ?? this.lastBackupAt),
    );
  }
}

class _Keys {
  static const locale = 'locale_code';
  static const theme = 'theme_mode';
  static const currency = 'main_currency';
  static const monthStartDay = 'month_start_day';
  static const weekStartsOn = 'week_starts_on';
  static const onboardingDone = 'onboarding_done';
  static const lastBackupAt = 'last_backup_at';
}

class SettingsController extends Notifier<AppSettingsState> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettingsState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final backupMillis = prefs.getInt(_Keys.lastBackupAt);
    return AppSettingsState(
      localeCode: prefs.getString(_Keys.locale) ?? 'uz',
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == prefs.getString(_Keys.theme),
        orElse: () => ThemeMode.system,
      ),
      mainCurrencyCode: prefs.getString(_Keys.currency) ?? Currency.uzs.code,
      monthStartDay: prefs.getInt(_Keys.monthStartDay) ?? 1,
      weekStartsOn: prefs.getInt(_Keys.weekStartsOn) ?? DateTime.monday,
      onboardingDone: prefs.getBool(_Keys.onboardingDone) ?? false,
      lastBackupAt: backupMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(backupMillis),
    );
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await _prefs.setString(_Keys.locale, code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_Keys.theme, mode.name);
  }

  Future<void> setMainCurrency(String code) async {
    state = state.copyWith(mainCurrencyCode: code);
    await _prefs.setString(_Keys.currency, code);
  }

  Future<void> setMonthStartDay(int day) async {
    final clamped = day.clamp(1, 28);
    state = state.copyWith(monthStartDay: clamped);
    await _prefs.setInt(_Keys.monthStartDay, clamped);
  }

  Future<void> setWeekStartsOn(int weekday) async {
    state = state.copyWith(weekStartsOn: weekday);
    await _prefs.setInt(_Keys.weekStartsOn, weekday);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingDone: true);
    await _prefs.setBool(_Keys.onboardingDone, true);
  }

  Future<void> resetOnboarding() async {
    state = state.copyWith(onboardingDone: false);
    await _prefs.setBool(_Keys.onboardingDone, false);
  }

  Future<void> markBackupNow() async {
    final now = DateTime.now();
    state = state.copyWith(lastBackupAt: now);
    await _prefs.setInt(_Keys.lastBackupAt, now.millisecondsSinceEpoch);
  }

  /// Hamma ma'lumot o'chirilganda zaxira sanasi ham ma'nosini yo'qotadi.
  Future<void> markBackupCleared() async {
    state = state.copyWith(clearLastBackup: true);
    await _prefs.remove(_Keys.lastBackupAt);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettingsState>(
  SettingsController.new,
);

/// Balansni yashirish rejimi — jamoat joyida foydali. Saqlanmaydi:
/// ilova qayta ochilganda balans yana ko'rinadi.
class BalanceVisibility extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final balanceVisibleProvider =
    NotifierProvider<BalanceVisibility, bool>(BalanceVisibility.new);
