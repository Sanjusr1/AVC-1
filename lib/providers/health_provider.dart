import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

/// Health metric model
class HealthMetric {
  final String deviceId;
  final int signalStrength;
  final int batteryLevel;
  final int latency;
  final int sensorAccuracy;
  final DateTime timestamp;

  const HealthMetric({
    required this.deviceId,
    required this.signalStrength,
    required this.batteryLevel,
    required this.latency,
    required this.sensorAccuracy,
    required this.timestamp,
  });
}

/// Health state
class HealthState {
  final Map<String, List<HealthMetric>> deviceMetrics;
  final bool isMonitoring;
  final String? errorMessage;

  const HealthState({
    this.deviceMetrics = const {},
    this.isMonitoring = false,
    this.errorMessage,
  });

  HealthState copyWith({
    Map<String, List<HealthMetric>>? deviceMetrics,
    bool? isMonitoring,
    String? errorMessage,
  }) {
    return HealthState(
      deviceMetrics: deviceMetrics ?? this.deviceMetrics,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Health notifier
class HealthNotifier extends StateNotifier<HealthState> {
  final Random _random = Random();

  HealthNotifier() : super(const HealthState()) {
    _generateMockData();
  }

  void _generateMockData() {
    final now = DateTime.now();
    final deviceIds = ['1', '2', '3'];
    final metrics = <String, List<HealthMetric>>{};

    for (final deviceId in deviceIds) {
      final deviceMetrics = <HealthMetric>[];
      
      // Generate 24 hours of data (one point per hour)
      for (int i = 0; i < 24; i++) {
        final timestamp = now.subtract(Duration(hours: 23 - i));
        
        deviceMetrics.add(HealthMetric(
          deviceId: deviceId,
          signalStrength: 60 + _random.nextInt(40), // 60-100
          batteryLevel: deviceId == '1' ? 90 - i * 2 : 50 + _random.nextInt(40), // Simulate battery drain for device 1
          latency: 20 + _random.nextInt(80), // 20-100ms
          sensorAccuracy: 80 + _random.nextInt(20), // 80-100%
          timestamp: timestamp,
        ));
      }
      
      metrics[deviceId] = deviceMetrics;
    }

    state = state.copyWith(deviceMetrics: metrics);
  }

  void startMonitoring() {
    state = state.copyWith(isMonitoring: true);
  }

  void stopMonitoring() {
    state = state.copyWith(isMonitoring: false);
  }

  HealthMetric? getLatestMetric(String deviceId) {
    final metrics = state.deviceMetrics[deviceId];
    if (metrics == null || metrics.isEmpty) return null;
    return metrics.last;
  }

  List<HealthMetric> getMetricsForDevice(String deviceId) {
    return state.deviceMetrics[deviceId] ?? [];
  }
}

/// Health provider
final healthProvider = StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  return HealthNotifier();
});

/// Convenience providers
final healthMetricsProvider = Provider.family<List<HealthMetric>, String>((ref, deviceId) {
  return ref.watch(healthProvider).deviceMetrics[deviceId] ?? [];
});

final latestHealthMetricProvider = Provider.family<HealthMetric?, String>((ref, deviceId) {
  final metrics = ref.watch(healthProvider).deviceMetrics[deviceId];
  if (metrics == null || metrics.isEmpty) return null;
  return metrics.last;
});

final isMonitoringProvider = Provider<bool>((ref) {
  return ref.watch(healthProvider).isMonitoring;
});