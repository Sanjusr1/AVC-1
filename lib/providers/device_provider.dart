import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Device model for UI
class Device {
  final String id;
  final String name;
  final String category;
  final DeviceStatus status;
  final int signalStrength;
  final int batteryLevel;
  final DateTime lastSeen;
  final Map<String, dynamic>? config;

  const Device({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.signalStrength,
    required this.batteryLevel,
    required this.lastSeen,
    this.config,
  });

  Device copyWith({
    String? id,
    String? name,
    String? category,
    DeviceStatus? status,
    int? signalStrength,
    int? batteryLevel,
    DateTime? lastSeen,
    Map<String, dynamic>? config,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      signalStrength: signalStrength ?? this.signalStrength,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSeen: lastSeen ?? this.lastSeen,
      config: config ?? this.config,
    );
  }
}

enum DeviceStatus { connected, disconnected, connecting, error }

/// Device state
class DeviceState {
  final List<Device> devices;
  final Device? connectedDevice;
  final bool isLoading;
  final String? errorMessage;

  const DeviceState({
    this.devices = const [],
    this.connectedDevice,
    this.isLoading = false,
    this.errorMessage,
  });

  DeviceState copyWith({
    List<Device>? devices,
    Device? connectedDevice,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DeviceState(
      devices: devices ?? this.devices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Device state notifier
class DeviceNotifier extends StateNotifier<DeviceState> {
  final Logger _logger;

  DeviceNotifier(this._logger) : super(const DeviceState()) {
    _loadMockDevices();
  }

  void _loadMockDevices() {
    // Mock devices for UI development
    final mockDevices = [
      Device(
        id: '1',
        name: 'AVC Mask Pro',
        category: 'AVC Mask',
        status: DeviceStatus.connected,
        signalStrength: 85,
        batteryLevel: 92,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Device(
        id: '2',
        name: 'AVC Audio Hub',
        category: 'AVC Audio Hub',
        status: DeviceStatus.disconnected,
        signalStrength: 0,
        batteryLevel: 45,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Device(
        id: '3',
        name: 'AVC Wearable',
        category: 'AVC Wearable',
        status: DeviceStatus.connected,
        signalStrength: 72,
        batteryLevel: 78,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];

    state = state.copyWith(devices: mockDevices);
  }

  void connectToDevice(String deviceId) {
    final deviceIndex = state.devices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex == -1) return;

    final device = state.devices[deviceIndex];
    final updatedDevice = device.copyWith(status: DeviceStatus.connecting);
    
    final updatedDevices = List<Device>.from(state.devices);
    updatedDevices[deviceIndex] = updatedDevice;
    
    state = state.copyWith(devices: updatedDevices);

    // Simulate connection
    Future.delayed(const Duration(seconds: 2), () {
      final connectedDevice = updatedDevice.copyWith(status: DeviceStatus.connected);
      final finalDevices = List<Device>.from(state.devices);
      finalDevices[deviceIndex] = connectedDevice;
      
      state = state.copyWith(
        devices: finalDevices,
        connectedDevice: connectedDevice,
      );
    });
  }

  void disconnectDevice() {
    if (state.connectedDevice == null) return;

    final deviceId = state.connectedDevice!.id;
    final deviceIndex = state.devices.indexWhere((d) => d.id == deviceId);
    
    if (deviceIndex != -1) {
      final updatedDevice = state.devices[deviceIndex].copyWith(
        status: DeviceStatus.disconnected,
      );
      
      final updatedDevices = List<Device>.from(state.devices);
      updatedDevices[deviceIndex] = updatedDevice;
      
      state = state.copyWith(
        devices: updatedDevices,
        connectedDevice: null,
      );
    }
  }

  void addDevice(Device device) {
    final updatedDevices = List<Device>.from(state.devices)..add(device);
    state = state.copyWith(devices: updatedDevices);
  }

  void removeDevice(String deviceId) {
    final updatedDevices = state.devices.where((d) => d.id != deviceId).toList();
    Device? connectedDevice = state.connectedDevice;
    
    if (connectedDevice?.id == deviceId) {
      connectedDevice = null;
    }
    
    state = state.copyWith(
      devices: updatedDevices,
      connectedDevice: connectedDevice,
    );
  }
}

/// Device provider
final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((ref) {
  final logger = Logger();
  return DeviceNotifier(logger);
});

/// Convenience providers
final deviceListProvider = Provider<List<Device>>((ref) {
  return ref.watch(deviceProvider).devices;
});

final connectedDeviceProvider = Provider<Device?>((ref) {
  return ref.watch(deviceProvider).connectedDevice;
});

final connectedDevicesCountProvider = Provider<int>((ref) {
  return ref.watch(deviceProvider).devices
      .where((device) => device.status == DeviceStatus.connected)
      .length;
});

final deviceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(deviceProvider).isLoading;
});