import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:avc_flutter/services/secure_storage_service.dart';

import 'secure_storage_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage, Logger])
void main() {
  group('SecureStorageService', () {
    late MockFlutterSecureStorage mockSecureStorage;
    late MockLogger mockLogger;
    late SecureStorageService secureStorageService;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
      mockLogger = MockLogger();
      secureStorageService = SecureStorageService(
        secureStorage: mockSecureStorage,
        logger: mockLogger,
      );
    });

    group('store', () {
      test('should store encrypted value successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        const encryptionKey = 'avc_secure_encryption_key';
        
        when(mockSecureStorage.read(key: encryptionKey))
            .thenAnswer((_) async => base64Encode(List.generate(32, (i) => i)));
        when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        await secureStorageService.store(key, value);

        // Assert
        verify(mockSecureStorage.write(
          key: 'avc_secure_$key',
          value: anyNamed('value'),
        )).called(1);
        verify(mockLogger.d('Storing secure value for key: $key')).called(1);
        verify(mockLogger.d('Successfully stored secure value for key: $key')).called(1);
      });

      test('should throw SecureStorageException when storage fails', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        const error = 'Storage failed';
        
        when(mockSecureStorage.read(key: anyNamed('key')))
            .thenThrow(Exception(error));

        // Act & Assert
        expect(
          () => secureStorageService.store(key, value),
          throwsA(isA<SecureStorageException>()),
        );
      });
    });

    group('retrieve', () {
      test('should retrieve and decrypt value successfully', () async {
        // Arrange
        const key = 'test_key';
        const originalValue = 'test_value';
        const encryptionKey = 'avc_secure_encryption_key';
        
        // Mock encryption key retrieval
        when(mockSecureStorage.read(key: encryptionKey))
            .thenAnswer((_) async => base64Encode(List.generate(32, (i) => i)));
        
        // Create a mock encrypted value (simplified for testing)
        final mockEncryptedValue = base64Encode(utf8.encode('encrypted_$originalValue'));
        when(mockSecureStorage.read(key: 'avc_secure_$key'))
            .thenAnswer((_) async => mockEncryptedValue);

        // Act
        final result = await secureStorageService.retrieve(key);

        // Assert
        expect(result, isNotNull);
        verify(mockSecureStorage.read(key: 'avc_secure_$key')).called(1);
        verify(mockLogger.d('Retrieving secure value for key: $key')).called(1);
      });

      test('should return null when key does not exist', () async {
        // Arrange
        const key = 'nonexistent_key';
        
        when(mockSecureStorage.read(key: 'avc_secure_$key'))
            .thenAnswer((_) async => null);

        // Act
        final result = await secureStorageService.retrieve(key);

        // Assert
        expect(result, isNull);
        verify(mockLogger.d('No value found for key: $key')).called(1);
      });
    });
  });
}
    group('delete', () {
      test('should delete value successfully', () async {
        // Arrange
        const key = 'test_key';
        
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        // Act
        await secureStorageService.delete(key);

        // Assert
        verify(mockSecureStorage.delete(key: 'avc_secure_$key')).called(1);
        verify(mockLogger.d('Deleting secure value for key: $key')).called(1);
        verify(mockLogger.d('Successfully deleted secure value for key: $key')).called(1);
      });

      test('should throw SecureStorageException when deletion fails', () async {
        // Arrange
        const key = 'test_key';
        const error = 'Deletion failed';
        
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenThrow(Exception(error));

        // Act & Assert
        expect(
          () => secureStorageService.delete(key),
          throwsA(isA<SecureStorageException>()),
        );
      });
    });

    group('containsKey', () {
      test('should return true when key exists', () async {
        // Arrange
        const key = 'existing_key';
        
        when(mockSecureStorage.read(key: 'avc_secure_$key'))
            .thenAnswer((_) async => 'some_value');

        // Act
        final result = await secureStorageService.containsKey(key);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when key does not exist', () async {
        // Arrange
        const key = 'nonexistent_key';
        
        when(mockSecureStorage.read(key: 'avc_secure_$key'))
            .thenAnswer((_) async => null);

        // Act
        final result = await secureStorageService.containsKey(key);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when storage throws exception', () async {
        // Arrange
        const key = 'error_key';
        
        when(mockSecureStorage.read(key: 'avc_secure_$key'))
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await secureStorageService.containsKey(key);

        // Assert
        expect(result, isFalse);
      });
    });

    group('clearAll', () {
      test('should clear all AVC prefixed keys successfully', () async {
        // Arrange
        final allKeys = {
          'avc_secure_key1': 'value1',
          'avc_secure_key2': 'value2',
          'other_key': 'other_value',
        };
        
        when(mockSecureStorage.readAll())
            .thenAnswer((_) async => allKeys);
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        // Act
        await secureStorageService.clearAll();

        // Assert
        verify(mockSecureStorage.delete(key: 'avc_secure_key1')).called(1);
        verify(mockSecureStorage.delete(key: 'avc_secure_key2')).called(1);
        verifyNever(mockSecureStorage.delete(key: 'other_key'));
        verify(mockLogger.d('Clearing all secure storage')).called(1);
        verify(mockLogger.d('Successfully cleared all secure storage')).called(1);
      });

      test('should throw SecureStorageException when clearing fails', () async {
        // Arrange
        when(mockSecureStorage.readAll())
            .thenThrow(Exception('Read all failed'));

        // Act & Assert
        expect(
          () => secureStorageService.clearAll(),
          throwsA(isA<SecureStorageException>()),
        );
      });
    });

    group('storeMultiple', () {
      test('should store multiple values successfully', () async {
        // Arrange
        final data = {
          'key1': 'value1',
          'key2': 'value2',
          'key3': 'value3',
        };
        const encryptionKey = 'avc_secure_encryption_key';
        
        when(mockSecureStorage.read(key: encryptionKey))
            .thenAnswer((_) async => base64Encode(List.generate(32, (i) => i)));
        when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        await secureStorageService.storeMultiple(data);

        // Assert
        for (final key in data.keys) {
          verify(mockSecureStorage.write(
            key: 'avc_secure_$key',
            value: anyNamed('value'),
          )).called(1);
        }
        verify(mockLogger.d('Storing multiple secure values: ${data.keys.join(', ')}')).called(1);
        verify(mockLogger.d('Successfully stored multiple secure values')).called(1);
      });
    });

    group('retrieveMultiple', () {
      test('should retrieve multiple values successfully', () async {
        // Arrange
        final keys = ['key1', 'key2', 'key3'];
        const encryptionKey = 'avc_secure_encryption_key';
        
        when(mockSecureStorage.read(key: encryptionKey))
            .thenAnswer((_) async => base64Encode(List.generate(32, (i) => i)));
        
        // Mock different responses for different keys
        when(mockSecureStorage.read(key: 'avc_secure_key1'))
            .thenAnswer((_) async => base64Encode(utf8.encode('encrypted_value1')));
        when(mockSecureStorage.read(key: 'avc_secure_key2'))
            .thenAnswer((_) async => base64Encode(utf8.encode('encrypted_value2')));
        when(mockSecureStorage.read(key: 'avc_secure_key3'))
            .thenAnswer((_) async => null);

        // Act
        final result = await secureStorageService.retrieveMultiple(keys);

        // Assert
        expect(result, hasLength(3));
        expect(result['key1'], isNotNull);
        expect(result['key2'], isNotNull);
        expect(result['key3'], isNull);
        verify(mockLogger.d('Retrieving multiple secure values: ${keys.join(', ')}')).called(1);
        verify(mockLogger.d('Successfully retrieved multiple secure values')).called(1);
      });
    });

    group('SecureStorageKeys', () {
      test('should generate correct device credential keys', () {
        // Arrange
        const deviceId = 'device123';
        
        // Act
        final credentialsKey = SecureStorageKeys.deviceCredentials(deviceId);
        final configKey = SecureStorageKeys.deviceConfig(deviceId);
        
        // Assert
        expect(credentialsKey, equals('device_creds_device123'));
        expect(configKey, equals('device_config_device123'));
      });

      test('should have correct constant values', () {
        expect(SecureStorageKeys.accessToken, equals('access_token'));
        expect(SecureStorageKeys.refreshToken, equals('refresh_token'));
        expect(SecureStorageKeys.userId, equals('user_id'));
        expect(SecureStorageKeys.userEmail, equals('user_email'));
        expect(SecureStorageKeys.deviceId, equals('device_id'));
        expect(SecureStorageKeys.encryptionSalt, equals('encryption_salt'));
        expect(SecureStorageKeys.biometricEnabled, equals('biometric_enabled'));
        expect(SecureStorageKeys.lastLoginTime, equals('last_login_time'));
      });
    });

    group('SecureStorageException', () {
      test('should format message correctly without cause', () {
        // Arrange
        const message = 'Test error message';
        const exception = SecureStorageException(message);
        
        // Act & Assert
        expect(exception.toString(), equals('SecureStorageException: Test error message'));
      });

      test('should format message correctly with cause', () {
        // Arrange
        const message = 'Test error message';
        const cause = 'Root cause';
        const exception = SecureStorageException(message, cause);
        
        // Act & Assert
        expect(exception.toString(), equals('SecureStorageException: Test error message (caused by: Root cause)'));
      });
    });
  });
}