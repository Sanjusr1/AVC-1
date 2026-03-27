import 'package:flutter/material.dart';

class DeviceDiscoveryScreen extends StatelessWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Discovery'),
      ),
      body: const Center(
        child: Text('Device Discovery Screen'),
      ),
    );
  }
}
