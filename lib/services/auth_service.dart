import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'auth_token_manager.dart';
import 'secure_storage_service.dart';

/// Service for handling user authentication operations
/// Implements Requirements 1.1, 1.2, 1.4 from the specification
class AuthService {
  final Dio _dio;
  final AuthTokenManager _tokenManager;
  final Logger _logger;

  AuthService({
    Dio? dio,
    AuthTokenManager? tokenManager,
    Logger? logger,
  }) : _dio = dio ?? Dio(),
        _tokenManager = tokenManager ?? AuthTokenManager(),
        _logger = logger ?? Logger() {
    _setupDioInterceptors();
  }

  /// Sets up Dio interceptors for request/response handling
  void _setupDioInterceptors() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Making ${options.method} request to ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Received response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Request error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Authenticates user with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns [AuthResult] with success status and user data
  /// Throws [AuthException] on authentication failure
  Future<AuthResult> login(String email, String password) async {
    try {
      _logger.i('Attempting login for email: $email');

      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true) {
          final authData = data['data'];
          final accessToken = authData['access_token'] as String;
          final refreshToken = authData['refresh_token'] as String;
          final user = authData['user'] as Map<String, dynamic>;
          
          // Store tokens securely
          await _tokenManager.storeAuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userId: user['id'] as String,
            userEmail: user['email'] as String,
          );

          _logger.i('Login successful for user: ${user['id']}');
          
          return AuthResult.success(
            user: User.fromJson(user),
            accessToken: accessToken,
          );
        } else {
          final error = data['error'];
          throw AuthException(
            (error['message'] as String?) ?? 'Login failed',
            AuthErrorType.invalidCredentials,
          );
        }
      } else {
        throw AuthException(
          'Server error: ${response.statusCode}',
          AuthErrorType.serverError,
        );
      }
    } on DioException catch (e) {
      _logger.e('Network error during login', error: e);
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw AuthException(
          'Connection timeout. Please check your internet connection.',
          AuthErrorType.networkError,
        );
      } else if (e.response?.statusCode == 401) {
        throw AuthException(
          'Invalid email or password',
          AuthErrorType.invalidCredentials,
        );
      } else if (e.response?.statusCode == 429) {
        throw AuthException(
          'Too many login attempts. Please try again later.',
          AuthErrorType.rateLimited,
        );
      } else {
        throw AuthException(
          'Network error: ${e.message}',
          AuthErrorType.networkError,
        );
      }
    } catch (e) {
      _logger.e('Unexpected error during login', error: e);
      throw AuthException(
        'An unexpected error occurred',
        AuthErrorType.unknown,
      );
    }
  }

  /// Logs out the current user
  /// 
  /// Clears stored tokens and notifies the backend
  Future<void> logout() async {
    try {
      _logger.i('Logging out user');

      // Get current tokens for backend notification
      final tokens = await _tokenManager.getAuthTokens();
      
      if (tokens != null) {
        try {
          // Notify backend of logout (best effort)
          await _dio.post(
            '/api/auth/logout',
            options: Options(
              headers: {
                'Authorization': 'Bearer ${tokens.accessToken}',
              },
            ),
          );
        } catch (e) {
          _logger.w('Failed to notify backend of logout', error: e);
          // Continue with local logout even if backend notification fails
        }
      }

      // Clear stored tokens
      await _tokenManager.clearAuthTokens();
      
      _logger.i('Logout completed');
    } catch (e) {
      _logger.e('Error during logout', error: e);
      // Always clear tokens even if there's an error
      await _tokenManager.clearAuthTokens();
      rethrow;
    }
  }

  /// Refreshes the access token using the stored refresh token
  /// 
  /// Returns new [AuthTokens] or null if refresh fails
  Future<AuthTokens?> refreshToken() async {
    try {
      _logger.d('Attempting to refresh access token');

      final currentTokens = await _tokenManager.getAuthTokens();
      if (currentTokens == null) {
        _logger.w('No tokens found for refresh');
        return null;
      }

      final response = await _dio.post(
        '/api/auth/refresh',
        data: {
          'refresh_token': currentTokens.refreshToken,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true) {
          final authData = data['data'];
          final newAccessToken = authData['access_token'] as String;
          final newRefreshToken = authData['refresh_token'] as String?;
          
          // Update stored tokens
          if (newRefreshToken != null) {
            // Full token refresh
            await _tokenManager.storeAuthTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              userId: currentTokens.userId,
              userEmail: currentTokens.userEmail ?? '',
            );
          } else {
            // Only access token refresh
            await _tokenManager.updateAccessToken(newAccessToken);
          }

          _logger.d('Token refresh successful');
          
          return AuthTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? currentTokens.refreshToken,
            userId: currentTokens.userId,
            userEmail: currentTokens.userEmail,
            lastLoginTime: DateTime.now(),
          );
        } else {
          _logger.w('Token refresh failed: ${data['error']}');
          return null;
        }
      } else {
        _logger.w('Token refresh failed with status: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _logger.e('Network error during token refresh', error: e);
      
      if (e.response?.statusCode == 401) {
        // Refresh token is invalid, clear all tokens
        await _tokenManager.clearAuthTokens();
      }
      
      return null;
    } catch (e) {
      _logger.e('Unexpected error during token refresh', error: e);
      return null;
    }
  }

  /// Checks if user is currently authenticated
  /// 
  /// Returns true if valid tokens exist, false otherwise
  Future<bool> isAuthenticated() async {
    try {
      final hasTokens = await _tokenManager.hasValidTokens();
      if (!hasTokens) {
        return false;
      }

      final tokens = await _tokenManager.getAuthTokens();
      if (tokens == null) {
        return false;
      }

      // Check if token is likely expired and try to refresh
      if (tokens.isLikelyExpired) {
        _logger.d('Access token likely expired, attempting refresh');
        final refreshedTokens = await refreshToken();
        return refreshedTokens != null;
      }

      return true;
    } catch (e) {
      _logger.e('Error checking authentication status', error: e);
      return false;
    }
  }

  /// Gets the current authenticated user
  /// 
  /// Returns [User] if authenticated, null otherwise
  Future<User?> getCurrentUser() async {
    try {
      final tokens = await _tokenManager.getAuthTokens();
      if (tokens == null) {
        return null;
      }

      // For now, return basic user info from stored tokens
      // In a real app, you might want to fetch fresh user data from the API
      return User(
        id: tokens.userId,
        email: tokens.userEmail ?? '',
        name: '', // Would be fetched from API
        profileImageUrl: null,
        emailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Error getting current user', error: e);
      return null;
    }
  }

  /// Validates session and restores authentication state
  /// 
  /// Called on app startup to check if user is still authenticated
  /// Returns [SessionRestoreResult] with the restoration status
  Future<SessionRestoreResult> restoreSession() async {
    try {
      _logger.d('Attempting to restore user session');

      final isAuth = await isAuthenticated();
      if (!isAuth) {
        _logger.d('No valid session found');
        return SessionRestoreResult.noSession();
      }

      final user = await getCurrentUser();
      if (user == null) {
        _logger.w('Authentication valid but user data unavailable');
        return SessionRestoreResult.failed('Unable to load user data');
      }

      _logger.i('Session restored successfully for user: ${user.id}');
      return SessionRestoreResult.success(user);
    } catch (e) {
      _logger.e('Error restoring session', error: e);
      return SessionRestoreResult.failed('Session restore failed');
    }
  }
}

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Result of authentication operation
class AuthResult {
  final bool success;
  final User? user;
  final String? accessToken;
  final String? errorMessage;
  final AuthErrorType? errorType;

  const AuthResult._({
    required this.success,
    this.user,
    this.accessToken,
    this.errorMessage,
    this.errorType,
  });

  factory AuthResult.success({
    required User user,
    required String accessToken,
  }) {
    return AuthResult._(
      success: true,
      user: user,
      accessToken: accessToken,
    );
  }

  factory AuthResult.failure({
    required String errorMessage,
    required AuthErrorType errorType,
  }) {
    return AuthResult._(
      success: false,
      errorMessage: errorMessage,
      errorType: errorType,
    );
  }
}

/// Result of session restoration
class SessionRestoreResult {
  final SessionRestoreStatus status;
  final User? user;
  final String? errorMessage;

  const SessionRestoreResult._({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory SessionRestoreResult.success(User user) {
    return SessionRestoreResult._(
      status: SessionRestoreStatus.success,
      user: user,
    );
  }

  factory SessionRestoreResult.noSession() {
    return const SessionRestoreResult._(
      status: SessionRestoreStatus.noSession,
    );
  }

  factory SessionRestoreResult.failed(String errorMessage) {
    return SessionRestoreResult._(
      status: SessionRestoreStatus.failed,
      errorMessage: errorMessage,
    );
  }
}

/// Status of session restoration
enum SessionRestoreStatus {
  success,
  noSession,
  failed,
}

/// User model
class User {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'email_verified': emailVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.profileImageUrl == profileImageUrl &&
        other.emailVerified == emailVerified &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        profileImageUrl.hashCode ^
        emailVerified.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

/// Authentication exception
class AuthException implements Exception {
  final String message;
  final AuthErrorType type;

  const AuthException(this.message, this.type);

  @override
  String toString() => 'AuthException: $message (type: $type)';
}

/// Types of authentication errors
enum AuthErrorType {
  invalidCredentials,
  networkError,
  serverError,
  rateLimited,
  unknown,
}