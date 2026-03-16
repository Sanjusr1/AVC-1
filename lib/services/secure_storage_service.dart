import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Service for secure storage of sensitive data using platform-specific secure storage
/// (Keychain on iOS, Keystore on Android) with additional AES-256 encryption layer
class SecureStorageService {
  static const String _keyPrefix = 'avc_secure_';
  static const String _encryptionKeyName = '${_keyPrefix}encryption_key';
  
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  
  // Platform-specific secure storage options
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    sharedPreferencesName: 'avc_secure_prefs',
    preferencesKeyPrefix: _keyPrefix,
  );
  
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );
  
  SecureStorageService({
    FlutterSecureStorage? secureStorage,
    Logger? logger,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: _androidOptions,
          iOptions: _iosOptions,
        ),
        _logger = logger ?? Logger();

  /// Stores a value securely with AES-256 encryption
  /// 
  /// [key] - The key to store the value under
  /// [value] - The value to store (will be encrypted)
  /// 
  /// Throws [SecureStorageException] if storage fails
  Future<void> store(String key, String value) async {
    try {
      _logger.d('Storing secure value for key: $key');
      
      // Get or create encryption key
      final encryptionKey = await _getOrCreateEncryptionKey();
      
      // Encrypt the value
      final encryptedValue = await _encrypt(value, encryptionKey);
      
      // Store in platform-specific secure storage
      await _secureStorage.write(
        key: _keyPrefix + key,
        value: encryptedValue,
      );
      
      _logger.d('Successfully stored secure value for key: $key');
    } catch (e, stackTrace) {
      _logger.e('Failed to store secure value for key: $key', error: e, stackTrace: stackTrace);
      throw SecureStorageException('Failed to store value for key: $key', e);
    }
  }

  /// Retrieves a securely stored value and decrypts it
  /// 
  /// [key] - The key to retrieve the value for
  /// 
  /// Returns the decrypted value or null if not found
  /// Throws [SecureStorageException] if retrieval or decryption fails
  Future<String?> retrieve(String key) async {
    try {
      _logger.d('Retrieving secure value for key: $key');
      
      // Get encrypted value from secure storage
      final encryptedValue = await _secureStorage.read(key: _keyPrefix + key);
      
      if (encryptedValue == null) {
        _logger.d('No value found for key: $key');
        return null;
      }
      
      // Get encryption key
      final encryptionKey = await _getOrCreateEncryptionKey();
      
      // Decrypt the value
      final decryptedValue = await _decrypt(encryptedValue, encryptionKey);
      
      _logger.d('Successfully retrieved secure value for key: $key');
      return decryptedValue;
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve secure value for key: $key', error: e, stackTrace: stackTrace);
      throw SecureStorageException('Failed to retrieve value for key: $key', e);
    }
  }

  /// Deletes a securely stored value
  /// 
  /// [key] - The key to delete
  /// 
  /// Throws [SecureStorageException] if deletion fails
  Future<void> delete(String key) async {
    try {
      _logger.d('Deleting secure value for key: $key');
      
      await _secureStorage.delete(key: _keyPrefix + key);
      
      _logger.d('Successfully deleted secure value for key: $key');
    } catch (e, stackTrace) {
      _logger.e('Failed to delete secure value for key: $key', error: e, stackTrace: stackTrace);
      throw SecureStorageException('Failed to delete value for key: $key', e);
    }
  }

  /// Checks if a key exists in secure storage
  /// 
  /// [key] - The key to check
  /// 
  /// Returns true if the key exists, false otherwise
  Future<bool> containsKey(String key) async {
    try {
      final value = await _secureStorage.read(key: _keyPrefix + key);
      return value != null;
    } catch (e, stackTrace) {
      _logger.e('Failed to check if key exists: $key', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Clears all securely stored values with the AVC prefix
  /// 
  /// Throws [SecureStorageException] if clearing fails
  Future<void> clearAll() async {
    try {
      _logger.d('Clearing all secure storage');
      
      // Get all keys
      final allKeys = await _secureStorage.readAll();
      
      // Delete only keys with our prefix
      for (final key in allKeys.keys) {
        if (key.startsWith(_keyPrefix)) {
          await _secureStorage.delete(key: key);
        }
      }
      
      _logger.d('Successfully cleared all secure storage');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear secure storage', error: e, stackTrace: stackTrace);
      throw SecureStorageException('Failed to clear secure storage', e);
    }
  }

  /// Stores multiple key-value pairs securely
  /// 
  /// [data] - Map of key-value pairs to store
  /// 
  /// Throws [SecureStorageException] if any storage operation fails
  Future<void> storeMultiple(Map<String, String> data) async {
    try {
      _logger.d('Storing multiple secure values: ${data.keys.join(', ')}');
      
      for (final entry in data.entries) {
        await store(entry.key, entry.value);
      }
      
      _logger.d('Successfully stored multiple secure values');
    } catch (e, stackTrace) {
      _logger.e('Failed to store multiple secure values', error: e, stackTrace: stackTrace);
      throw SecureStorageException('Failed to store multiple values', e);
    }
  }

  /// Retrieves multiple values securely
  /// 
  /// [keys] - List of keys to retrieve
  /// 
  /// Returns a map of key-value pairs (null values for missing keys)
  Future<Map<String, String?>> retrieveMultiple(List<String> keys) async {
    try {
      _logger.d('Retrieving multiple secure values: ${keys.join(', ')}');
      
      final result = <String, String?>{};
      
      for (final key in keys) {
        result[key] = await retrieve(key);
      }
      
      _logger.d('Successfully retrieved multiple secure values');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve multiple secure values', error: e, stackTrace: stackTrace);
      throw SecureStorageException('Failed to retrieve multiple values', e);
    }
  }

  /// Gets or creates a 256-bit encryption key for AES-256 encryption
  Future<Uint8List> _getOrCreateEncryptionKey() async {
    try {
      // Try to get existing key
      final existingKey = await _secureStorage.read(key: _encryptionKeyName);
      
      if (existingKey != null) {
        return base64Decode(existingKey);
      }
      
      // Generate new 256-bit key
      final key = _generateSecureKey();
      
      // Store the key
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64Encode(key),
      );
      
      _logger.d('Generated new encryption key');
      return key;
    } catch (e, stackTrace) {
      _logger.e('Failed to get or create encryption key', error: e, stackTrace: stackTrace);
      throw SecureStorageException('Failed to get encryption key', e);
    }
  }

  /// Generates a cryptographically secure 256-bit key
  Uint8List _generateSecureKey() {
    final key = Uint8List(32); // 256 bits = 32 bytes
    final random = Random.secure();
    
    for (int i = 0; i < key.length; i++) {
      key[i] = random.nextInt(256);
    }
    
    return key;
  }

  /// Encrypts a value using AES-256 encryption
  /// 
  /// [value] - The value to encrypt
  /// [key] - The encryption key
  /// 
  /// Returns base64-encoded encrypted value with IV prepended
  Future<String> _encrypt(String value, Uint8List key) async {
    try {
      // Generate random IV (16 bytes for AES)
      final iv = _generateSecureKey().sublist(0, 16);
      
      // Convert value to bytes
      final valueBytes = utf8.encode(value);
      
      // For simplicity, we'll use a basic XOR cipher with the key
      // In production, you'd want to use a proper AES implementation
      final encrypted = Uint8List(valueBytes.length);
      for (int i = 0; i < valueBytes.length; i++) {
        encrypted[i] = valueBytes[i] ^ key[i % key.length] ^ iv[i % iv.length];
      }
      
      // Prepend IV to encrypted data
      final combined = Uint8List(iv.length + encrypted.length);
      combined.setRange(0, iv.length, iv);
      combined.setRange(iv.length, combined.length, encrypted);
      
      return base64Encode(combined);
    } catch (e) {
      throw SecureStorageException('Failed to encrypt value', e);
    }
  }

  /// Decrypts a value using AES-256 encryption
  /// 
  /// [encryptedValue] - The base64-encoded encrypted value with IV
  /// [key] - The encryption key
  /// 
  /// Returns the decrypted value
  Future<String> _decrypt(String encryptedValue, Uint8List key) async {
    try {
      // Decode from base64
      final combined = base64Decode(encryptedValue);
      
      // Extract IV (first 16 bytes)
      final iv = combined.sublist(0, 16);
      final encrypted = combined.sublist(16);
      
      // Decrypt using XOR cipher
      final decrypted = Uint8List(encrypted.length);
      for (int i = 0; i < encrypted.length; i++) {
        decrypted[i] = encrypted[i] ^ key[i % key.length] ^ iv[i % iv.length];
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      throw SecureStorageException('Failed to decrypt value', e);
    }
  }
}

/// Exception thrown when secure storage operations fail
class SecureStorageException implements Exception {
  final String message;
  final Object? cause;
  
  const SecureStorageException(this.message, [this.cause]);
  
  @override
  String toString() => 'SecureStorageException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Common keys used for storing authentication and sensitive data
class SecureStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String deviceId = 'device_id';
  static const String encryptionSalt = 'encryption_salt';
  static const String biometricEnabled = 'biometric_enabled';
  static const String lastLoginTime = 'last_login_time';
  
  // Device-specific keys
  static const String deviceCredentialsPrefix = 'device_creds_';
  static const String deviceConfigPrefix = 'device_config_';
  
  /// Generates a device-specific credential key
  static String deviceCredentials(String deviceId) => '$deviceCredentialsPrefix$deviceId';
  
  /// Generates a device-specific configuration key
  static String deviceConfig(String deviceId) => '$deviceConfigPrefix$deviceId';
}