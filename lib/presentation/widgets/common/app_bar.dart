import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';

class AppAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool showLogout;

  const AppAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.showLogout = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showBackButton,
      actions: [
        ...?actions,
        if (showLogout)
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final authNotifier = ref.read(authProvider.notifier);
                await authNotifier.logout();
                if (context.mounted) {
                  context.goNamed('login');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text('Logout ${user?.email ?? ''}'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}