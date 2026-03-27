import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../providers/device_provider.dart';
import '../../../providers/health_provider.dart';
import '../../widgets/common/bottom_nav.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  String? selectedDeviceId;

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(deviceListProvider);
    final connectedDevices = devices.where((d) => d.status == DeviceStatus.connected).toList();
    
    // Auto-select first connected device
    if (selectedDeviceId == null && connectedDevices.isNotEmpty) {
      selectedDeviceId = connectedDevices.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Monitor'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh health data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Health data refreshed')),
              );
            },
          ),
        ],
      ),
      body: connectedDevices.isEmpty
          ? _buildNoDevicesView()
          : Column(
              children: [
                // Device selector
                if (connectedDevices.length > 1)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: selectedDeviceId,
                      decoration: const InputDecoration(
                        labelText: 'Select Device',
                        border: OutlineInputBorder(),
                      ),
                      items: connectedDevices.map((device) {
                        return DropdownMenuItem(
                          value: device.id,
                          child: Text(device.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDeviceId = value;
                        });
                      },
                    ),
                  ),
                
                // Health metrics
                Expanded(
                  child: selectedDeviceId != null
                      ? _buildHealthMetrics(selectedDeviceId!)
                      : const Center(child: Text('Select a device to view health metrics')),
                ),
              ],
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildNoDevicesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Connected Devices',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Connect a device to view health metrics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetrics(String deviceId) {
    final healthMetrics = ref.watch(healthMetricsProvider(deviceId));
    final latestMetric = ref.watch(latestHealthMetricProvider(deviceId));

    if (healthMetrics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current metrics cards
          if (latestMetric != null) ...[
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Signal',
                    '${latestMetric.signalStrength}%',
                    Icons.signal_cellular_alt,
                    _getSignalColor(latestMetric.signalStrength),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Battery',
                    '${latestMetric.batteryLevel}%',
                    Icons.battery_std,
                    _getBatteryColor(latestMetric.batteryLevel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Latency',
                    '${latestMetric.latency}ms',
                    Icons.speed,
                    _getLatencyColor(latestMetric.latency),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Accuracy',
                    '${latestMetric.sensorAccuracy}%',
                    Icons.precision_manufacturing,
                    _getAccuracyColor(latestMetric.sensorAccuracy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],

          // Charts
          Text(
            '24-Hour Trends',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Signal Strength Chart
          _buildChart(
            'Signal Strength (%)',
            healthMetrics,
            (metric) => metric.signalStrength.toDouble(),
            Colors.blue,
          ),
          const SizedBox(height: 24),
          
          // Battery Level Chart
          _buildChart(
            'Battery Level (%)',
            healthMetrics,
            (metric) => metric.batteryLevel.toDouble(),
            Colors.green,
          ),
          const SizedBox(height: 24),
          
          // Latency Chart
          _buildChart(
            'Latency (ms)',
            healthMetrics,
            (metric) => metric.latency.toDouble(),
            Colors.orange,
          ),
          const SizedBox(height: 24),
          
          // Sensor Accuracy Chart
          _buildChart(
            'Sensor Accuracy (%)',
            healthMetrics,
            (metric) => metric.sensorAccuracy.toDouble(),
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    String title,
    List<HealthMetric> metrics,
    double Function(HealthMetric) valueExtractor,
    Color color,
  ) {
    final chartData = metrics.map((metric) {
      return ChartData(metric.timestamp, valueExtractor(metric));
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.hours,
                  interval: 4,
                  dateFormat: DateFormat('HH:mm'),
                ),
                primaryYAxis: NumericAxis(),
                series: <CartesianSeries>[
                  LineSeries<ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.time,
                    yValueMapper: (ChartData data, _) => data.value,
                    color: color,
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSignalColor(int signal) {
    if (signal >= 70) return Colors.green;
    if (signal >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getBatteryColor(int battery) {
    if (battery >= 50) return Colors.green;
    if (battery >= 20) return Colors.orange;
    return Colors.red;
  }

  Color _getLatencyColor(int latency) {
    if (latency <= 50) return Colors.green;
    if (latency <= 100) return Colors.orange;
    return Colors.red;
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 70) return Colors.orange;
    return Colors.red;
  }
}

class ChartData {
  final DateTime time;
  final double value;

  ChartData(this.time, this.value);
}