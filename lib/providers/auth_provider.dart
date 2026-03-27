import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../services/auth_service.dart';

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, isLoading: $isLoading, user: $user, errorMessage: $errorMessage)';
  }
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Logger _logger;

  AuthNotifier(this._authService, this._logger) : super(const AuthState()) {
    _initializeAuth();
  }

  /// Initialize authentication state on app startup
  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      _logger.d('Initializing authentication state');
      
      final restoreResult = await _authService.restoreSession();
      
      switch (restoreResult.status) {
        case SessionRestoreStatus.success:
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: restoreResult.user,
            errorMessage: null,
          );
          _logger.i('Session restored successfully');
          break;
          
        case SessionRestoreStatus.noSession:
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            user: null,
            errorMessage: null,
          );
          _logger.d('No existing session found');
          break;
          
        case SessionRestoreStatus.failed:
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            user: null,
            errorMessage: restoreResult.errorMessage,
          );
          _logger.w('Session restore failed: ${restoreResult.errorMessage}');
          break;
      }
    } catch (e) {
      _logger.e('Error initializing authentication', error: e);
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        errorMessage: 'Failed to initialize authentication',
      );
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      _logger.i('Attempting login for email: $email');
      
      // Check for demo credentials
      if (email == 'demo@avc.com' && password == 'Demo@123') {
        // Simulate successful login for demo
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: User(
            id: 'demo-user',
            email: email,
            name: 'Demo User',
            emailVerified: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          errorMessage: null,
        );
        _logger.i('Demo login successful');
        return true;
      }
      
      final result = await _authService.login(email, password);
      
      if (result.success) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: result.user,
          errorMessage: null,
        );
        _logger.i('Login successful');
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          user: null,
          errorMessage: result.errorMessage,
        );
        _logger.w('Login failed: ${result.errorMessage}');
        return false;
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        errorMessage: e.message,
      );
      _logger.e('Authentication error: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        errorMessage: 'An unexpected error occurred',
      );
      _logger.e('Unexpected error during login', error: e);
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      _logger.i('Logging out user');
      
      await _authService.logout();
      
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        errorMessage: null,
      );
      
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Error during logout', error: e);
      
      // Even if logout fails, clear the local state
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        errorMessage: null,
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Refresh authentication state
  Future<void> refresh() async {
    try {
      _logger.d('Refreshing authentication state');
      
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
          errorMessage: null,
        );
      }
    } catch (e) {
      _logger.e('Error refreshing authentication state', error: e);
    }
  }
}

/// Authentication provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final logger = Logger();
  return AuthNotifier(authService, logger);
});

/// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Convenience provider for getting current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Convenience provider for checking if auth is loading
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Convenience provider for getting auth error message
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});