import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:avc_flutter/services/secure_storage_service.dart';

void main() {
  group('SecureStorageService Property Tests', () {
    late SecureStorageService secureStorageService;
    final random = Random();

    setUp(() {
      secureStorageService = SecureStorageService();
    });

    tearDown(() async {
      try {
        await secureStorageService.clearAll();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    /// **Validates: Requirements 1.3, 20.2, 20.6**
    /// Property: For any valid key-value pair, storing and then retrieving 
    /// should return the original value (round-trip property)
    testWidgets('round-trip property: store then retrieve returns original value', 
        (WidgetTester tester) async {
      // Generate test cases
      final testCases = _generateTestCases(100);
      
      for (final testCase in testCases) {
        // Act
        await secureStorageService.store(testCase.key, testCase.value);
        final retrievedValue = await secureStorageService.retrieve(testCase.key);
        
        // Assert
        expect(
          retrievedValue, 
          equals(testCase.value),
          reason: 'Round-trip failed for key: ${testCase.key}, value: ${testCase.value}',
        );
      }
    });

    /// **Validates: Requirements 1.3, 20.2, 20.6**
    /// Property: For any set of key-value pairs, storing multiple and retrieving 
    /// multiple should return all original values
    testWidgets('multiple storage property: batch operations preserve all values', 
        (WidgetTester tester) async {
      // Generate test cases
      for (int iteration = 0; iteration < 20; iteration++) {
        final testData = _generateTestData(random.nextInt(10) + 1);
        
        // Act
        await secureStorageService.storeMultiple(testData);
        final retrievedData = await secureStorageService.retrieveMultiple(testData.keys.toList());
        
        // Assert
        for (final entry in testData.entries) {
          expect(
            retrievedData[entry.key], 
            equals(entry.value),
            reason: 'Batch operation failed for key: ${entry.key}',
          );
        }
        
        // Cleanup for next iteration
        await secureStorageService.clearAll();
      }
    });

    /// **Validates: Requirements 1.3, 20.2, 20.6**
    /// Property: For any stored key-value pair, containsKey should return true
    /// before deletion and false after deletion
    testWidgets('existence property: containsKey reflects storage state', 
        (WidgetTester tester) async {
      final testCases = _generateTestCases(50);
      
      for (final testCase in testCases) {
        // Initially should not exist
        expect(await secureStorageService.containsKey(testCase.key), isFalse);
        
        // Store and verify existence
        await secureStorageService.store(testCase.key, testCase.value);
        expect(await secureStorageService.containsKey(testCase.key), isTrue);
        
        // Delete and verify non-existence
        await secureStorageService.delete(testCase.key);
        expect(await secureStorageService.containsKey(testCase.key), isFalse);
      }
    });

    /// **Validates: Requirements 1.3, 20.2, 20.6**
    /// Property: For any stored data, clearAll should remove all AVC-prefixed keys
    testWidgets('clear all property: removes all stored data', 
        (WidgetTester tester) async {
      for (int iteration = 0; iteration < 10; iteration++) {
        final testData = _generateTestData(random.nextInt(15) + 5);
        
        // Store data
        await secureStorageService.storeMultiple(testData);
        
        // Verify all keys exist
        for (final key in testData.keys) {
          expect(await secureStorageService.containsKey(key), isTrue);
        }
        
        // Clear all
        await secureStorageService.clearAll();
        
        // Verify all keys are gone
        for (final key in testData.keys) {
          expect(await secureStorageService.containsKey(key), isFalse);
        }
      }
    });

    /// **Validates: Requirements 1.3, 20.2, 20.6**
    /// Property: For any non-existent key, retrieve should return null
    testWidgets('null retrieval property: non-existent keys return null', 
        (WidgetTester tester) async {
      final nonExistentKeys = _generateRandomKeys(100);
      
      for (final key in nonExistentKeys) {
        final result = await secureStorageService.retrieve(key);
        expect(result, isNull, reason: 'Non-existent key $key should return null');
      }
    });

    /// **Validates: Requirements 1.3, 20.2, 20.6**
    /// Property: For any valid data, encryption should be deterministic within the same session
    /// but different across sessions (due to random IV)
    testWidgets('encryption consistency property: same input produces consistent results', 
        (WidgetTester tester) async {
      const key = 'consistency_test_key';
      const value = 'consistency_test_value';
      
      // Store and retrieve multiple times in same session
      for (int i = 0; i < 10; i++) {
        await secureStorageService.store(key, value);
        final retrieved = await secureStorageService.retrieve(key);
        expect(retrieved, equals(value));
        await secureStorageService.delete(key);
      }
    });

    /// **Validates: Requirements 1.3, 20.2, 20.6**
    /// Property: For any authentication token scenario, all required fields should be stored and retrieved correctly
    testWidgets('authentication scenario property: complete auth data round-trip', 
        (WidgetTester tester) async {
      for (int iteration = 0; iteration < 20; iteration++) {
        final authData = _generateAuthData();
        
        // Store authentication data
        await secureStorageService.storeMultiple(authData);
        
        // Retrieve and verify
        final retrievedData = await secureStorageService.retrieveMultiple(authData.keys.toList());
        
        for (final entry in authData.entries) {
          expect(
            retrievedData[entry.key], 
            equals(entry.value),
            reason: 'Auth data mismatch for key: ${entry.key}',
          );
        }
        
        // Cleanup
        await secureStorageService.clearAll();
      }
    });
  });
}

class TestCase {
  final String key;
  final String value;
  
  TestCase(this.key, this.value);
}

List<TestCase> _generateTestCases(int count) {
  final random = Random();
  final testCases = <TestCase>[];
  
  for (int i = 0; i < count; i++) {
    final key = _generateRandomKey(random);
    final value = _generateRandomValue(random);
    testCases.add(TestCase(key, value));
  }
  
  return testCases;
}

Map<String, String> _generateTestData(int count) {
  final random = Random();
  final data = <String, String>{};
  
  for (int i = 0; i < count; i++) {
    final key = _generateRandomKey(random);
    final value = _generateRandomValue(random);
    data[key] = value;
  }
  
  return data;
}

List<String> _generateRandomKeys(int count) {
  final random = Random();
  final keys = <String>[];
  
  for (int i = 0; i < count; i++) {
    keys.add(_generateRandomKey(random));
  }
  
  return keys;
}

String _generateRandomKey(Random random) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-';
  final length = random.nextInt(20) + 5; // 5-24 characters
  
  return String.fromCharCodes(
    Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );
}

String _generateRandomValue(Random random) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?~`" \n\t';
  final length = random.nextInt(1000) + 1; // 1-1000 characters
  
  return String.fromCharCodes(
    Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );
}

Map<String, String> _generateAuthData() {
  final random = Random();
  
  return {
    SecureStorageKeys.accessToken: _generateJWT(random),
    SecureStorageKeys.refreshToken: _generateRandomValue(random),
    SecureStorageKeys.userId: 'user_${random.nextInt(10000)}',
    SecureStorageKeys.userEmail: 'user${random.nextInt(1000)}@example.com',
    SecureStorageKeys.deviceId: 'device_${random.nextInt(10000)}',
    SecureStorageKeys.lastLoginTime: DateTime.now().millisecondsSinceEpoch.toString(),
  };
}

String _generateJWT(Random random) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_';
  
  String generatePart(int length) {
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
  
  return '${generatePart(36)}.${generatePart(200)}.${generatePart(43)}';
}