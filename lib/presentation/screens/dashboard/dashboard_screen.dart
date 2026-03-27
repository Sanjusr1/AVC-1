import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/bottom_nav.dart';
import '../../widgets/common/loading_indicator.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // TODO: Load actual data from providers
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data for now
    setState(() {
      _devices = [
        {
          'id': '1',
          'name': 'AVC Mask Pro',
          'category': 'AVC Mask',
          'status': 'connected',
          'signalStrength': 85,
          'batteryLevel': 92,
          'lastSeen': DateTime.now().subtract(const Duration(minutes: 5)),
        },
        {
          'id': '2',
          'name': 'AVC Audio Hub',
          'category': 'AVC Audio Hub',
          'status': 'disconnected',
          'signalStrength': 0,
          'batteryLevel': 45,
          'lastSeen': DateTime.now().subtract(const Duration(hours: 2)),
        },
      ];
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    
    if (mounted) {
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: const AppAppBar(
        title: 'Dashboard',
        showBackButton: false,
        showLogout: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadDashboardData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back${user?.email != null ? ', ${user!.email}' : ''}!',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your AVC devices and monitor their health.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats Overview
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    '${_devices.length}',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Devices',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    '${_devices.where((d) => d['status'] == 'connected').length}',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Connected',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Devices Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Devices',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.pushNamed('device-discovery');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Device'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Devices List
                    if (_devices.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.devices_other,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No devices found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first AVC device to get started',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.pushNamed('device-discovery');
                                },
                                child: const Text('Add Device'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _devices.map((device) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: device['status'] == 'connected' 
                                    ? Colors.green 
                                    : Colors.grey,
                                child: Icon(
                                  Icons.device_hub,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(device['name'] as String),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(device['category'] as String),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.signal_cellular_alt,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${device['signalStrength']}%'),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.battery_std,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${device['batteryLevel']}%'),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(
                                  device['status'] as String,
                                  style: TextStyle(
                                    color: device['status'] == 'connected' 
                                        ? Colors.green 
                                        : Colors.grey,
                                  ),
                                ),
                                backgroundColor: (device['status'] == 'connected' 
                                    ? Colors.green 
                                    : Colors.grey).withOpacity(0.1),
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Device details for ${device['name']} coming soon'),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}