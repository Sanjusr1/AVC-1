import 'package:flutter/material.dart';
import 'package:avc_flutter/services/secure_storage_service.dart';
import 'package:avc_flutter/services/auth_token_manager.dart';

/// Example demonstrating SecureStorageService usage
/// This example shows how to implement Requirements 1.3, 20.2, and 20.6
class SecureStorageExample extends StatefulWidget {
  const SecureStorageExample({super.key});

  @override
  State<SecureStorageExample> createState() => _SecureStorageExampleState();
}

class _SecureStorageExampleState extends State<SecureStorageExample> {
  final SecureStorageService _secureStorage = SecureStorageService();
  final AuthTokenManager _tokenManager = AuthTokenManager();
  
  String _status = 'Ready';
  String _retrievedValue = '';
  AuthTokens? _currentTokens;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Basic Storage Operations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Storage Operations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _storeTestData,
                            child: const Text('Store Test Data'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _retrieveTestData,
                            child: const Text('Retrieve Test Data'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkKeyExists,
                            child: const Text('Check Key Exists'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _deleteTestData,
                            child: const Text('Delete Test Data'),
                          ),
                        ),
                      ],
                    ),
                    if (_retrievedValue.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Retrieved Value:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_retrievedValue),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Authentication Token Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication Token Management',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _storeAuthTokens,
                            child: const Text('Store Auth Tokens'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _retrieveAuthTokens,
                            child: const Text('Retrieve Auth Tokens'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkTokensExist,
                            child: const Text('Check Tokens Exist'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearAuthTokens,
                            child: const Text('Clear Auth Tokens'),
                          ),
                        ),
                      ],
                    ),
                    if (_currentTokens != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Current Tokens:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User ID: ${_currentTokens!.userId}'),
                            Text('Email: ${_currentTokens!.userEmail ?? 'N/A'}'),
                            Text('Last Login: ${_currentTokens!.lastLoginTime ?? 'N/A'}'),
                            Text('Likely Expired: ${_currentTokens!.isLikelyExpired}'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Batch Operations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Batch Operations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _storeBatchData,
                            child: const Text('Store Batch Data'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _retrieveBatchData,
                            child: const Text('Retrieve Batch Data'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _clearAllData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear All Secure Data'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _storeTestData() async {
    try {
      setState(() => _status = 'Storing test data...');
      
      await _secureStorage.store('test_key', 'This is a test value with special chars: !@#\$%^&*()');
      
      setState(() => _status = 'Test data stored successfully');
    } catch (e) {
      setState(() => _status = 'Error storing test data: $e');
    }
  }

  Future<void> _retrieveTestData() async {
    try {
      setState(() => _status = 'Retrieving test data...');
      
      final value = await _secureStorage.retrieve('test_key');
      
      setState(() {
        _status = value != null ? 'Test data retrieved successfully' : 'No test data found';
        _retrievedValue = value ?? '';
      });
    } catch (e) {
      setState(() => _status = 'Error retrieving test data: $e');
    }
  }

  Future<void> _checkKeyExists() async {
    try {
      setState(() => _status = 'Checking if key exists...');
      
      final exists = await _secureStorage.containsKey('test_key');
      
      setState(() => _status = 'Key exists: $exists');
    } catch (e) {
      setState(() => _status = 'Error checking key existence: $e');
    }
  }

  Future<void> _deleteTestData() async {
    try {
      setState(() => _status = 'Deleting test data...');
      
      await _secureStorage.delete('test_key');
      
      setState(() {
        _status = 'Test data deleted successfully';
        _retrievedValue = '';
      });
    } catch (e) {
      setState(() => _status = 'Error deleting test data: $e');
    }
  }

  Future<void> _storeAuthTokens() async {
    try {
      setState(() => _status = 'Storing authentication tokens...');
      
      await _tokenManager.storeAuthTokens(
        accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
        refreshToken: 'refresh_token_example_12345',
        userId: 'user_12345',
        userEmail: 'john.doe@example.com',
      );
      
      setState(() => _status = 'Authentication tokens stored successfully');
    } catch (e) {
      setState(() => _status = 'Error storing authentication tokens: $e');
    }
  }

  Future<void> _retrieveAuthTokens() async {
    try {
      setState(() => _status = 'Retrieving authentication tokens...');
      
      final tokens = await _tokenManager.getAuthTokens();
      
      setState(() {
        _status = tokens != null ? 'Authentication tokens retrieved successfully' : 'No authentication tokens found';
        _currentTokens = tokens;
      });
    } catch (e) {
      setState(() => _status = 'Error retrieving authentication tokens: $e');
    }
  }

  Future<void> _checkTokensExist() async {
    try {
      setState(() => _status = 'Checking if tokens exist...');
      
      final hasTokens = await _tokenManager.hasValidTokens();
      
      setState(() => _status = 'Has valid tokens: $hasTokens');
    } catch (e) {
      setState(() => _status = 'Error checking token existence: $e');
    }
  }

  Future<void> _clearAuthTokens() async {
    try {
      setState(() => _status = 'Clearing authentication tokens...');
      
      await _tokenManager.clearAuthTokens();
      
      setState(() {
        _status = 'Authentication tokens cleared successfully';
        _currentTokens = null;
      });
    } catch (e) {
      setState(() => _status = 'Error clearing authentication tokens: $e');
    }
  }

  Future<void> _storeBatchData() async {
    try {
      setState(() => _status = 'Storing batch data...');
      
      await _secureStorage.storeMultiple({
        'batch_key_1': 'Batch value 1',
        'batch_key_2': 'Batch value 2',
        'batch_key_3': 'Batch value 3',
        'device_config': '{"model":"AVC_Pro","firmware":"1.2.3","settings":{"volume":75}}',
      });
      
      setState(() => _status = 'Batch data stored successfully');
    } catch (e) {
      setState(() => _status = 'Error storing batch data: $e');
    }
  }

  Future<void> _retrieveBatchData() async {
    try {
      setState(() => _status = 'Retrieving batch data...');
      
      final data = await _secureStorage.retrieveMultiple([
        'batch_key_1',
        'batch_key_2',
        'batch_key_3',
        'device_config',
      ]);
      
      final retrievedCount = data.values.where((v) => v != null).length;
      
      setState(() => _status = 'Batch data retrieved: $retrievedCount items found');
    } catch (e) {
      setState(() => _status = 'Error retrieving batch data: $e');
    }
  }

  Future<void> _clearAllData() async {
    try {
      setState(() => _status = 'Clearing all secure data...');
      
      await _secureStorage.clearAll();
      
      setState(() {
        _status = 'All secure data cleared successfully';
        _retrievedValue = '';
        _currentTokens = null;
      });
    } catch (e) {
      setState(() => _status = 'Error clearing all data: $e');
    }
  }
}