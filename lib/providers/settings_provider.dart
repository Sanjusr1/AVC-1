import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App settings model
class AppSettings {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool pushNotificationsEnabled;
  final int refreshInterval; // in seconds
  final bool offlineModeEnabled;
  final bool analyticsEnabled;
  final bool hapticFeedbackEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.pushNotificationsEnabled = true,
    this.refreshInterval = 30,
    this.offlineModeEnabled = true,
    this.analyticsEnabled = true,
    this.hapticFeedbackEnabled = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? pushNotificationsEnabled,
    int? refreshInterval,
    bool? offlineModeEnabled,
    bool? analyticsEnabled,
    bool? hapticFeedbackEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      offlineModeEnabled: offlineModeEnabled ?? this.offlineModeEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    );
  }
}

/// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void updateThemeMode(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void togglePushNotifications(bool enabled) {
    state = state.copyWith(pushNotificationsEnabled: enabled);
  }

  void updateRefreshInterval(int interval) {
    state = state.copyWith(refreshInterval: interval);
  }

  void toggleOfflineMode(bool enabled) {
    state = state.copyWith(offlineModeEnabled: enabled);
  }

  void toggleAnalytics(bool enabled) {
    state = state.copyWith(analyticsEnabled: enabled);
  }

  void toggleHapticFeedback(bool enabled) {
    state = state.copyWith(hapticFeedbackEnabled: enabled);
  }

  void resetToDefaults() {
    state = const AppSettings();
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// Convenience providers
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).notificationsEnabled;
});