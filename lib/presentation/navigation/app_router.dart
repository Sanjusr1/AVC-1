import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/health/health_screen.dart';
import '../screens/controls/controls_screen.dart';
import '../screens/ai/ai_assistant_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/device/device_discovery_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/health',
        name: 'health',
        builder: (context, state) => const HealthScreen(),
      ),
      GoRoute(
        path: '/controls',
        name: 'controls',
        builder: (context, state) => const ControlsScreen(),
      ),
      GoRoute(
        path: '/ai',
        name: 'ai',
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: '/more',
        name: 'more',
        builder: (context, state) => const MoreScreen(),
      ),
      GoRoute(
        path: '/device-discovery',
        name: 'device-discovery',
        builder: (context, state) => const DeviceDiscoveryScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isOnSplash = state.uri.toString() == '/splash';
      final isOnLogin = state.uri.toString() == '/login';
      
      // If still loading auth state, stay on splash
      if (authState.isLoading && !isOnSplash) {
        return '/splash';
      }
      
      // If not authenticated and not on login/splash, redirect to login
      if (!authState.isAuthenticated && !isOnLogin && !isOnSplash) {
        return '/login';
      }
      
      // If authenticated and on login/splash, redirect to dashboard
      if (authState.isAuthenticated && (isOnLogin || isOnSplash)) {
        return '/dashboard';
      }
      
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
});