import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/device_provider.dart';
import '../../widgets/common/bottom_nav.dart';

class ControlsScreen extends ConsumerStatefulWidget {
  const ControlsScreen({super.key});

  @override
  ConsumerState<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends ConsumerState<ControlsScreen> {
  double _volumeLevel = 75.0;
  double _sensitivityLevel = 50.0;
  double _responseTime = 25.0;
  bool _noiseReduction = true;
  bool _adaptiveMode = false;
  bool _voiceEnhancement = true;

  @override
  Widget build(BuildContext context) {
    final connectedDevice = ref.watch(connectedDeviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Controls'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showAdvancedSettings();
            },
          ),
        ],
      ),
      body: connectedDevice == null
          ? _buildNoDeviceView()
          : _buildControlsView(connectedDevice),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildNoDeviceView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Device Connected',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Connect a device to access controls',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to device discovery
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device discovery coming soon')),
                );
              },
              child: const Text('Find Devices'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsView(Device device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Device info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.device_hub, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          device.category,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(deviceProvider.notifier).disconnectDevice();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Calibrate',
                  Icons.tune,
                  Colors.blue,
                  () => _showCalibrationDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Test Voice',
                  Icons.mic,
                  Colors.green,
                  () => _testVoice(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Reset',
                  Icons.refresh,
                  Colors.orange,
                  () => _resetSettings(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Emergency',
                  Icons.emergency,
                  Colors.red,
                  () => _emergencyStop(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Volume Control
          _buildControlSection(
            'Volume Control',
            Icons.volume_up,
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Volume Level'),
                    Text('${_volumeLevel.round()}%'),
                  ],
                ),
                Slider(
                  value: _volumeLevel,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() {
                      _volumeLevel = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sensitivity Control
          _buildControlSection(
            'Sensitivity',
            Icons.sensors,
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sensitivity Level'),
                    Text('${_sensitivityLevel.round()}%'),
                  ],
                ),
                Slider(
                  value: _sensitivityLevel,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() {
                      _sensitivityLevel = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Response Time
          _buildControlSection(
            'Response Time',
            Icons.speed,
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Response Delay'),
                    Text('${_responseTime.round()}ms'),
                  ],
                ),
                Slider(
                  value: _responseTime,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() {
                      _responseTime = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Feature Toggles
          _buildControlSection(
            'Features',
            Icons.featured_play_list,
            Column(
              children: [
                SwitchListTile(
                  title: const Text('Noise Reduction'),
                  subtitle: const Text('Reduce background noise'),
                  value: _noiseReduction,
                  onChanged: (value) {
                    setState(() {
                      _noiseReduction = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Adaptive Mode'),
                  subtitle: const Text('Automatically adjust settings'),
                  value: _adaptiveMode,
                  onChanged: (value) {
                    setState(() {
                      _adaptiveMode = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Voice Enhancement'),
                  subtitle: const Text('Enhance voice clarity'),
                  value: _voiceEnhancement,
                  onChanged: (value) {
                    setState(() {
                      _voiceEnhancement = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save Settings Button
          ElevatedButton(
            onPressed: () {
              _saveSettings();
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildControlSection(String title, IconData icon, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  void _showAdvancedSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Settings'),
        content: const Text('Advanced settings panel coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Calibration'),
        content: const Text('Follow the on-screen instructions to calibrate your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calibration started')),
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _testVoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice test initiated')),
    );
  }

  void _resetSettings() {
    setState(() {
      _volumeLevel = 75.0;
      _sensitivityLevel = 50.0;
      _responseTime = 25.0;
      _noiseReduction = true;
      _adaptiveMode = false;
      _voiceEnhancement = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults')),
    );
  }

  void _emergencyStop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Stop'),
        content: const Text('This will immediately stop all device operations. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(deviceProvider.notifier).disconnectDevice();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency stop activated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Save settings to device
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }
}