import 'package:logger/logger.dart';
import 'secure_storage_service.dart';

/// Example service demonstrating how to use SecureStorageService for authentication tokens
/// This shows the practical implementation of Requirements 1.3, 20.2, and 20.6
class AuthTokenManager {
  final SecureStorageService _secureStorage;
  final Logger _logger;

  AuthTokenManager({
    SecureStorageService? secureStorage,
    Logger? logger,
  }) : _secureStorage = secureStorage ?? SecureStorageService(),
        _logger = logger ?? Logger();

  /// Stores authentication tokens securely
  /// 
  /// [accessToken] - JWT access token
  /// [refreshToken] - Refresh token for obtaining new access tokens
  /// [userId] - User identifier
  /// [userEmail] - User email address
  Future<void> storeAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userEmail,
  }) async {
    try {
      _logger.i('Storing authentication tokens for user: $userId');
      
      await _secureStorage.storeMultiple({
        SecureStorageKeys.accessToken: accessToken,
        SecureStorageKeys.refreshToken: refreshToken,
        SecureStorageKeys.userId: userId,
        SecureStorageKeys.userEmail: userEmail,
        SecureStorageKeys.lastLoginTime: DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      _logger.i('Successfully stored authentication tokens');
    } catch (e, stackTrace) {
      _logger.e('Failed to store authentication tokens', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves stored authentication tokens
  /// 
  /// Returns [AuthTokens] if tokens exist, null otherwise
  Future<AuthTokens?> getAuthTokens() async {
    try {
      _logger.d('Retrieving authentication tokens');
      
      final tokenData = await _secureStorage.retrieveMultiple([
        SecureStorageKeys.accessToken,
        SecureStorageKeys.refreshToken,
        SecureStorageKeys.userId,
        SecureStorageKeys.userEmail,
        SecureStorageKeys.lastLoginTime,
      ]);
      
      final accessToken = tokenData[SecureStorageKeys.accessToken];
      final refreshToken = tokenData[SecureStorageKeys.refreshToken];
      final userId = tokenData[SecureStorageKeys.userId];
      final userEmail = tokenData[SecureStorageKeys.userEmail];
      final lastLoginTimeStr = tokenData[SecureStorageKeys.lastLoginTime];
      
      if (accessToken == null || refreshToken == null || userId == null) {
        _logger.d('No complete authentication tokens found');
        return null;
      }
      
      final lastLoginTime = lastLoginTimeStr != null 
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(lastLoginTimeStr))
          : null;
      
      _logger.d('Successfully retrieved authentication tokens');
      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        userEmail: userEmail,
        lastLoginTime: lastLoginTime,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve authentication tokens', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Updates the access token while keeping other tokens
  /// 
  /// [newAccessToken] - New JWT access token
  Future<void> updateAccessToken(String newAccessToken) async {
    try {
      _logger.d('Updating access token');
      
      await _secureStorage.store(SecureStorageKeys.accessToken, newAccessToken);
      
      _logger.d('Successfully updated access token');
    } catch (e, stackTrace) {
      _logger.e('Failed to update access token', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Checks if user has valid authentication tokens
  /// 
  /// Returns true if tokens exist, false otherwise
  Future<bool> hasValidTokens() async {
    try {
      final hasAccessToken = await _secureStorage.containsKey(SecureStorageKeys.accessToken);
      final hasRefreshToken = await _secureStorage.containsKey(SecureStorageKeys.refreshToken);
      final hasUserId = await _secureStorage.containsKey(SecureStorageKeys.userId);
      
      return hasAccessToken && hasRefreshToken && hasUserId;
    } catch (e, stackTrace) {
      _logger.e('Failed to check token validity', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Clears all authentication tokens (logout)
  Future<void> clearAuthTokens() async {
    try {
      _logger.i('Clearing authentication tokens');
      
      await Future.wait([
        _secureStorage.delete(SecureStorageKeys.accessToken),
        _secureStorage.delete(SecureStorageKeys.refreshToken),
        _secureStorage.delete(SecureStorageKeys.userId),
        _secureStorage.delete(SecureStorageKeys.userEmail),
        _secureStorage.delete(SecureStorageKeys.lastLoginTime),
      ]);
      
      _logger.i('Successfully cleared authentication tokens');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear authentication tokens', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Stores device-specific credentials securely
  /// 
  /// [deviceId] - Unique device identifier
  /// [credentials] - Device credentials (JSON string)
  Future<void> storeDeviceCredentials(String deviceId, String credentials) async {
    try {
      _logger.d('Storing credentials for device: $deviceId');
      
      await _secureStorage.store(
        SecureStorageKeys.deviceCredentials(deviceId),
        credentials,
      );
      
      _logger.d('Successfully stored device credentials');
    } catch (e, stackTrace) {
      _logger.e('Failed to store device credentials', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves device-specific credentials
  /// 
  /// [deviceId] - Unique device identifier
  /// 
  /// Returns credentials JSON string or null if not found
  Future<String?> getDeviceCredentials(String deviceId) async {
    try {
      _logger.d('Retrieving credentials for device: $deviceId');
      
      final credentials = await _secureStorage.retrieve(
        SecureStorageKeys.deviceCredentials(deviceId),
      );
      
      if (credentials != null) {
        _logger.d('Successfully retrieved device credentials');
      } else {
        _logger.d('No credentials found for device: $deviceId');
      }
      
      return credentials;
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve device credentials', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Removes device-specific credentials
  /// 
  /// [deviceId] - Unique device identifier
  Future<void> removeDeviceCredentials(String deviceId) async {
    try {
      _logger.d('Removing credentials for device: $deviceId');
      
      await _secureStorage.delete(SecureStorageKeys.deviceCredentials(deviceId));
      
      _logger.d('Successfully removed device credentials');
    } catch (e, stackTrace) {
      _logger.e('Failed to remove device credentials', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Data class representing authentication tokens
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String? userEmail;
  final DateTime? lastLoginTime;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    this.userEmail,
    this.lastLoginTime,
  });

  /// Checks if the access token is likely expired (basic heuristic)
  /// In a real implementation, you would decode the JWT and check the exp claim
  bool get isLikelyExpired {
    if (lastLoginTime == null) return false;
    
    // Assume tokens expire after 15 minutes (typical for access tokens)
    final expirationTime = lastLoginTime!.add(const Duration(minutes: 15));
    return DateTime.now().isAfter(expirationTime);
  }

  @override
  String toString() {
    return 'AuthTokens(userId: $userId, userEmail: $userEmail, lastLoginTime: $lastLoginTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AuthTokens &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.userId == userId &&
        other.userEmail == userEmail &&
        other.lastLoginTime == lastLoginTime;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        userId.hashCode ^
        userEmail.hashCode ^
        lastLoginTime.hashCode;
  }
}