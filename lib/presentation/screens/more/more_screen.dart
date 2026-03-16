import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/common/bottom_nav.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showProfileDialog(context, ref);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Settings Section
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          _buildSettingsTile(
            context,
            'Theme',
            'Appearance and display settings',
            Icons.palette,
            () => _showThemeDialog(context, ref),
          ),
          
          _buildSettingsTile(
            context,
            'Notifications',
            'Manage notification preferences',
            Icons.notifications,
            () => _showNotificationSettings(context, ref),
          ),
          
          _buildSettingsTile(
            context,
            'Privacy & Security',
            'Data and security settings',
            Icons.security,
            () => _showPrivacySettings(context),
          ),
          
          _buildSettingsTile(
            context,
            'Data & Storage',
            'Manage app data and cache',
            Icons.storage,
            () => _showDataSettings(context),
          ),

          const SizedBox(height: 24),

          // Support Section
          Text(
            'Support',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          _buildSettingsTile(
            context,
            'Help & FAQ',
            'Get help and find answers',
            Icons.help,
            () => _showHelp(context),
          ),
          
          _buildSettingsTile(
            context,
            'Contact Support',
            'Get in touch with our team',
            Icons.support_agent,
            () => _contactSupport(context),
          ),
          
          _buildSettingsTile(
            context,
            'Send Feedback',
            'Help us improve the app',
            Icons.feedback,
            () => _sendFeedback(context),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          _buildSettingsTile(
            context,
            'About AVC',
            'Learn more about the app',
            Icons.info,
            () => _showAbout(context),
          ),
          
          _buildSettingsTile(
            context,
            'Terms of Service',
            'Read our terms and conditions',
            Icons.description,
            () => _showTerms(context),
          ),
          
          _buildSettingsTile(
            context,
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            () => _showPrivacyPolicy(context),
          ),

          const SizedBox(height: 32),

          // Logout Button
          ElevatedButton(
            onPressed: () => _showLogoutDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Logout'),
          ),

          const SizedBox(height: 16),

          // App Version
          Center(
            child: Text(
              'Version 1.0.0 (Build 1)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showProfileDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(settingsProvider).themeMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotifications(value);
              },
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: settings.pushNotificationsEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).togglePushNotifications(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const Text('Privacy and security settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data & Storage'),
        content: const Text('Data management features coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const Text('Help documentation coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Support contact feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Text('Feedback feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About AVC'),
        content: const Text(
          'AVC Mobile App\n\n'
          'Manage and monitor your Artificial Vocal Cord devices with ease. '
          'This app provides real-time health monitoring, device controls, '
          'and AI-powered assistance for optimal device performance.\n\n'
          'Version 1.0.0\nBuild 1',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('Terms of service document coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy policy document coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed('login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}