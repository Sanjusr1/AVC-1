import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity status
enum ConnectivityStatus {
  connected,
  disconnected,
  connecting,
  unknown,
}

/// WiFi status
enum WiFiStatus {
  connected,
  disconnected,
  scanning,
  unknown,
}

/// Connectivity state
class ConnectivityState {
  final ConnectivityStatus networkStatus;
  final WiFiStatus wifiStatus;
  final String? wifiNetworkName;
  final int? wifiSignalStrength;
  final bool isOnline;
  final DateTime lastConnected;

  const ConnectivityState({
    this.networkStatus = ConnectivityStatus.unknown,
    this.wifiStatus = WiFiStatus.unknown,
    this.wifiNetworkName,
    this.wifiSignalStrength,
    this.isOnline = false,
    DateTime? lastConnected,
  }) : lastConnected = lastConnected ?? DateTime.now();

  ConnectivityState copyWith({
    ConnectivityStatus? networkStatus,
    WiFiStatus? wifiStatus,
    String? wifiNetworkName,
    int? wifiSignalStrength,
    bool? isOnline,
    DateTime? lastConnected,
  }) {
    return ConnectivityState(
      networkStatus: networkStatus ?? this.networkStatus,
      wifiStatus: wifiStatus ?? this.wifiStatus,
      wifiNetworkName: wifiNetworkName ?? this.wifiNetworkName,
      wifiSignalStrength: wifiSignalStrength ?? this.wifiSignalStrength,
      isOnline: isOnline ?? this.isOnline,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }
}

/// Connectivity notifier
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(ConnectivityState(
    networkStatus: ConnectivityStatus.connected,
    wifiStatus: WiFiStatus.connected,
    wifiNetworkName: 'Home WiFi',
    wifiSignalStrength: 85,
    isOnline: true,
    lastConnected: DateTime.now(),
  ));

  void updateNetworkStatus(ConnectivityStatus status) {
    state = state.copyWith(
      networkStatus: status,
      isOnline: status == ConnectivityStatus.connected,
      lastConnected: status == ConnectivityStatus.connected ? DateTime.now() : state.lastConnected,
    );
  }

  void updateWiFiStatus(WiFiStatus status, {String? networkName, int? signalStrength}) {
    state = state.copyWith(
      wifiStatus: status,
      wifiNetworkName: networkName ?? state.wifiNetworkName,
      wifiSignalStrength: signalStrength ?? state.wifiSignalStrength,
    );
  }

  void simulateOffline() {
    state = state.copyWith(
      networkStatus: ConnectivityStatus.disconnected,
      wifiStatus: WiFiStatus.disconnected,
      isOnline: false,
    );
  }

  void simulateOnline() {
    state = state.copyWith(
      networkStatus: ConnectivityStatus.connected,
      wifiStatus: WiFiStatus.connected,
      wifiNetworkName: 'Home WiFi',
      wifiSignalStrength: 85,
      isOnline: true,
      lastConnected: DateTime.now(),
    );
  }
}

/// Connectivity provider
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

/// Convenience providers
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isOnline;
});

final wifiStatusProvider = Provider<WiFiStatus>((ref) {
  return ref.watch(connectivityProvider).wifiStatus;
});

final networkStatusProvider = Provider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityProvider).networkStatus;
});