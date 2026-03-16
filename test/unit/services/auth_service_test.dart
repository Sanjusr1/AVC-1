import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'package:avc_flutter/services/auth_service.dart';
import 'package:avc_flutter/services/auth_token_manager.dart';

// Mock classes
class MockDio extends Mock implements Dio {}
class MockAuthTokenManager extends Mock implements AuthTokenManager {}
class MockLogger extends Mock implements Logger {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockDio mockDio;
    late MockAuthTokenManager mockTokenManager;
    late MockLogger mockLogger;

    setUp(() {
      mockDio = MockDio();
      mockTokenManager = MockAuthTokenManager();
      mockLogger = MockLogger();
      
      authService = AuthService(
        dio: mockDio,
        tokenManager: mockTokenManager,
        logger: mockLogger,
      );
    });

    group('login', () {
      test('should return success result when login is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        final mockResponse = Response(
          data: {
            'success': true,
            'data': {
              'access_token': 'mock_access_token',
              'refresh_token': 'mock_refresh_token',
              'user': {
                'id': 'user123',
                'email': email,
                'name': 'Test User',
                'email_verified': true,
                'created_at': '2024-01-01T00:00:00Z',
                'updated_at': '2024-01-01T00:00:00Z',
              },
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/auth/login'),
        );

        when(mockDio.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);
        
        when(mockTokenManager.storeAuthTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
          userId: anyNamed('userId'),
          userEmail: anyNamed('userEmail'),
        )).thenAnswer((_) async {});

        // Act
        final result = await authService.login(email, password);

        // Assert
        expect(result.success, true);
        expect(result.user?.email, email);
        expect(result.accessToken, 'mock_access_token');
        
        verify(mockTokenManager.storeAuthTokens(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
          userId: 'user123',
          userEmail: email,
        )).called(1);
      });
    });
  });
}