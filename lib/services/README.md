# SecureStorageService

A comprehensive secure storage service for the AVC Flutter application that provides encrypted storage of sensitive data using platform-specific secure storage mechanisms.

## Overview

The `SecureStorageService` implements **Requirements 1.3, 20.2, and 20.6** by providing:

- **Platform-specific secure storage**: Uses Keychain on iOS and Keystore on Android
- **AES-256 encryption**: Additional encryption layer for extra security
- **Comprehensive API**: Store, retrieve, delete, and batch operations
- **Error handling**: Robust error handling with custom exceptions
- **Logging**: Detailed logging for debugging and monitoring

## Features

### Core Functionality
- ✅ Store encrypted key-value pairs
- ✅ Retrieve and decrypt stored values
- ✅ Delete individual keys
- ✅ Check key existence
- ✅ Clear all stored data
- ✅ Batch operations (store/retrieve multiple)

### Security Features
- ✅ Platform-specific secure storage (Keychain/Keystore)
- ✅ AES-256 encryption with random IV
- ✅ Secure key generation and management
- ✅ Automatic encryption key creation
- ✅ Prefix-based key isolation

### Platform Integration
- ✅ iOS: Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- ✅ Android: Keystore with encrypted shared preferences
- ✅ Configurable security options per platform

## Usage

### Basic Operations

```dart
final secureStorage = SecureStorageService();

// Store a value
await secureStorage.store('user_token', 'eyJhbGciOiJIUzI1NiIs...');

// Retrieve a value
final token = await secureStorage.retrieve('user_token');

// Check if key exists
final exists = await secureStorage.containsKey('user_token');

// Delete a value
await secureStorage.delete('user_token');
```

### Batch Operations

```dart
// Store multiple values
await secureStorage.storeMultiple({
  'access_token': 'eyJhbGciOiJIUzI1NiIs...',
  'refresh_token': 'refresh_token_value',
  'user_id': 'user123',
});

// Retrieve multiple values
final authData = await secureStorage.retrieveMultiple([
  'access_token',
  'refresh_token', 
  'user_id',
]);
```

### Authentication Token Management

```dart
final tokenManager = AuthTokenManager();

// Store authentication tokens
await tokenManager.storeAuthTokens(
  accessToken: 'eyJhbGciOiJIUzI1NiIs...',
  refreshToken: 'refresh_token_value',
  userId: 'user123',
  userEmail: 'user@example.com',
);

// Retrieve tokens
final tokens = await tokenManager.getAuthTokens();
if (tokens != null) {
  print('User: ${tokens.userId}');
  print('Email: ${tokens.userEmail}');
}

// Check if tokens exist
final hasTokens = await tokenManager.hasValidTokens();

// Clear tokens (logout)
await tokenManager.clearAuthTokens();
```

### Device Credentials

```dart
final tokenManager = AuthTokenManager();

// Store device-specific credentials
await tokenManager.storeDeviceCredentials(
  'device_12345',
  '{"username":"device_user","password":"device_pass"}',
);

// Retrieve device credentials
final credentials = await tokenManager.getDeviceCredentials('device_12345');
```

## Predefined Keys

The service provides predefined keys for common use cases:

```dart
class SecureStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String deviceId = 'device_id';
  static const String encryptionSalt = 'encryption_salt';
  static const String biometricEnabled = 'biometric_enabled';
  static const String lastLoginTime = 'last_login_time';
  
  // Device-specific key generators
  static String deviceCredentials(String deviceId) => 'device_creds_$deviceId';
  static String deviceConfig(String deviceId) => 'device_config_$deviceId';
}
```

## Error Handling

The service throws `SecureStorageException` for all storage-related errors:

```dart
try {
  await secureStorage.store('key', 'value');
} catch (e) {
  if (e is SecureStorageException) {
    print('Storage error: ${e.message}');
    if (e.cause != null) {
      print('Caused by: ${e.cause}');
    }
  }
}
```

## Platform Configuration

### iOS Configuration

The service uses the following iOS Keychain settings:

```dart
static const IOSOptions _iosOptions = IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
  synchronizable: false,
);
```

### Android Configuration

The service uses the following Android Keystore settings:

```dart
static const AndroidOptions _androidOptions = AndroidOptions(
  encryptedSharedPreferences: true,
  sharedPreferencesName: 'avc_secure_prefs',
  preferencesKeyPrefix: 'avc_secure_',
);
```

## Security Considerations

1. **Encryption**: All values are encrypted with AES-256 before storage
2. **Key Management**: Encryption keys are stored in platform-specific secure storage
3. **IV Generation**: Random IV is generated for each encryption operation
4. **Key Isolation**: All keys are prefixed with 'avc_secure_' to avoid conflicts
5. **Platform Security**: Leverages iOS Keychain and Android Keystore security features

## Testing

The service includes comprehensive tests:

### Unit Tests
- Mock-based testing of all public methods
- Error condition testing
- Edge case validation

### Integration Tests
- Real flutter_secure_storage integration
- End-to-end functionality testing
- Platform-specific behavior validation

### Property-Based Tests
- Round-trip encryption/decryption validation
- Batch operation consistency
- Data integrity across operations
- Authentication scenario testing

Run tests with:
```bash
flutter test test/unit/services/secure_storage_service_test.dart
flutter test test/integration/secure_storage_integration_test.dart
flutter test test/property/secure_storage_property_test.dart
```

## Performance Considerations

- **Lazy Key Generation**: Encryption keys are generated only when needed
- **Batch Operations**: Use `storeMultiple`/`retrieveMultiple` for better performance
- **Memory Management**: Large values are handled efficiently
- **Caching**: No in-memory caching to maintain security

## Dependencies

- `flutter_secure_storage: ^9.1.0` - Platform-specific secure storage
- `crypto: ^3.0.3` - Cryptographic operations
- `logger: ^2.0.0` - Logging functionality

## Migration Notes

When upgrading from previous versions:

1. Existing data remains accessible (backward compatible)
2. New encryption features apply to newly stored data
3. Consider re-encrypting existing sensitive data for enhanced security

## Troubleshooting

### Common Issues

1. **Platform Permissions**: Ensure proper permissions are set in platform configurations
2. **Keychain Access**: On iOS, ensure the app has proper entitlements
3. **Android Keystore**: Ensure minimum API level 23 for full functionality
4. **Storage Limits**: Be aware of platform-specific storage limitations

### Debug Logging

Enable debug logging to troubleshoot issues:

```dart
final logger = Logger(level: Level.debug);
final secureStorage = SecureStorageService(logger: logger);
```

## Contributing

When contributing to the SecureStorageService:

1. Maintain backward compatibility
2. Add comprehensive tests for new features
3. Update documentation
4. Follow security best practices
5. Test on both iOS and Android platforms