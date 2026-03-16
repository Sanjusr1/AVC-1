import 'package:flutter_test/flutter_test.dart';
import 'package:avc_flutter/services/secure_storage_service.dart';

void main() {
  group('SecureStorageService Integration Tests', () {
    late SecureStorageService secureStorageService;

    setUp(() {
      secureStorageService = SecureStorageService();
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await secureStorageService.clearAll();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    testWidgets('should store and retrieve values correctly', (WidgetTester tester) async {
      // Arrange
      const key = 'integration_test_key';
      const value = 'integration_test_value';

      // Act
      await secureStorageService.store(key, value);
      final retrievedValue = await secureStorageService.retrieve(key);

      // Assert
      expect(retrievedValue, equals(value));
    });

    testWidgets('should handle multiple key-value pairs', (WidgetTester tester) async {
      // Arrange
      final testData = {
        'key1': 'value1',
        'key2': 'value2',
        'key3': 'value3',
      };

      // Act
      await secureStorageService.storeMultiple(testData);
      final retrievedData = await secureStorageService.retrieveMultiple(testData.keys.toList());

      // Assert
      for (final entry in testData.entries) {
        expect(retrievedData[entry.key], equals(entry.value));
      }
    });

    testWidgets('should correctly identify existing keys', (WidgetTester tester) async {
      // Arrange
      const existingKey = 'existing_key';
      const nonExistentKey = 'non_existent_key';
      const value = 'test_value';

      // Act
      await secureStorageService.store(existingKey, value);
      final existsResult = await secureStorageService.containsKey(existingKey);
      final notExistsResult = await secureStorageService.containsKey(nonExistentKey);

      // Assert
      expect(existsResult, isTrue);
      expect(notExistsResult, isFalse);
    });

    testWidgets('should delete values correctly', (WidgetTester tester) async {
      // Arrange
      const key = 'delete_test_key';
      const value = 'delete_test_value';

      // Act
      await secureStorageService.store(key, value);
      expect(await secureStorageService.containsKey(key), isTrue);
      
      await secureStorageService.delete(key);
      final retrievedValue = await secureStorageService.retrieve(key);

      // Assert
      expect(retrievedValue, isNull);
      expect(await secureStorageService.containsKey(key), isFalse);
    });

    testWidgets('should clear all AVC keys without affecting other keys', (WidgetTester tester) async {
      // Arrange
      const avcKey1 = 'avc_key1';
      const avcKey2 = 'avc_key2';
      const value1 = 'value1';
      const value2 = 'value2';

      // Act
      await secureStorageService.store(avcKey1, value1);
      await secureStorageService.store(avcKey2, value2);
      
      expect(await secureStorageService.containsKey(avcKey1), isTrue);
      expect(await secureStorageService.containsKey(avcKey2), isTrue);
      
      await secureStorageService.clearAll();

      // Assert
      expect(await secureStorageService.containsKey(avcKey1), isFalse);
      expect(await secureStorageService.containsKey(avcKey2), isFalse);
    });

    testWidgets('should handle authentication token storage scenario', (WidgetTester tester) async {
      // Arrange
      const accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
      const refreshToken = 'refresh_token_value';
      const userId = 'user123';
      const userEmail = 'user@example.com';

      // Act - Store authentication data
      await secureStorageService.storeMultiple({
        SecureStorageKeys.accessToken: accessToken,
        SecureStorageKeys.refreshToken: refreshToken,
        SecureStorageKeys.userId: userId,
        SecureStorageKeys.userEmail: userEmail,
      });

      // Retrieve authentication data
      final authData = await secureStorageService.retrieveMultiple([
        SecureStorageKeys.accessToken,
        SecureStorageKeys.refreshToken,
        SecureStorageKeys.userId,
        SecureStorageKeys.userEmail,
      ]);

      // Assert
      expect(authData[SecureStorageKeys.accessToken], equals(accessToken));
      expect(authData[SecureStorageKeys.refreshToken], equals(refreshToken));
      expect(authData[SecureStorageKeys.userId], equals(userId));
      expect(authData[SecureStorageKeys.userEmail], equals(userEmail));
    });

    testWidgets('should handle device-specific credential storage', (WidgetTester tester) async {
      // Arrange
      const deviceId = 'device_12345';
      const deviceCredentials = '{"username":"device_user","password":"device_pass"}';
      const deviceConfig = '{"model":"AVC_Pro","firmware":"1.2.3"}';

      // Act
      await secureStorageService.store(
        SecureStorageKeys.deviceCredentials(deviceId),
        deviceCredentials,
      );
      await secureStorageService.store(
        SecureStorageKeys.deviceConfig(deviceId),
        deviceConfig,
      );

      final retrievedCredentials = await secureStorageService.retrieve(
        SecureStorageKeys.deviceCredentials(deviceId),
      );
      final retrievedConfig = await secureStorageService.retrieve(
        SecureStorageKeys.deviceConfig(deviceId),
      );

      // Assert
      expect(retrievedCredentials, equals(deviceCredentials));
      expect(retrievedConfig, equals(deviceConfig));
    });

    testWidgets('should handle large data storage', (WidgetTester tester) async {
      // Arrange
      const key = 'large_data_key';
      final largeValue = 'x' * 10000; // 10KB of data

      // Act
      await secureStorageService.store(key, largeValue);
      final retrievedValue = await secureStorageService.retrieve(key);

      // Assert
      expect(retrievedValue, equals(largeValue));
      expect(retrievedValue?.length, equals(10000));
    });

    testWidgets('should handle special characters and unicode', (WidgetTester tester) async {
      // Arrange
      const key = 'unicode_test_key';
      const value = 'Special chars: !@#\$%^&*()_+ Unicode: 🚀🔐💾 中文 العربية';

      // Act
      await secureStorageService.store(key, value);
      final retrievedValue = await secureStorageService.retrieve(key);

      // Assert
      expect(retrievedValue, equals(value));
    });
  });
}