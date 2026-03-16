class AppConstants {
  // API Configuration
  static const String debugApiBaseUrl = 'https://api.staging.avc.com/v1';
  static const String productionApiBaseUrl = 'https://api.avc.com/v1';
  static const String debugWebsocketBaseUrl = 'wss://ws.staging.avc.com';
  static const String productionWebsocketBaseUrl = 'wss://ws.avc.com';
  
  // App Constants
  static const String appName = 'AVC Mobile';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  
  // Database
  static const String databaseName = 'avc_database.db';
  static const int databaseVersion = 1;
  
  // Network
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
  
  // Health Monitoring Intervals (in milliseconds)
  static const int signalStrengthInterval = 2000; // 2 seconds
  static const int batteryCheckInterval = 5000; // 5 seconds
  static const int latencyCheckInterval = 2000; // 2 seconds
  static const int accuracyCheckInterval = 5000; // 5 seconds
  
  // Alert Thresholds
  static const int lowBatteryThreshold = 20; // 20%
  static const int poorSignalThreshold = 30; // Signal strength below 30 is poor
  static const int highLatencyThreshold = 100; // 100ms
  static const int lowAccuracyThreshold = 80; // 80% accuracy threshold
  
  // Device Categories
  static const List<String> deviceCategories = [
    'AVC Mask',
    'AVC Pro',
    'AVC Lite',
    'AVC Audio Hub',
    'AVC Wearable',
  ];
  
  // AI Model Options
  static const List<String> aiModels = [
    'Standard',
    'Enhanced',
    'Professional',
    'Enterprise',
  ];
  
  // Notification Channels
  static const String alertsChannelId = 'alerts_channel';
  static const String updatesChannelId = 'updates_channel';
  static const String backgroundChannelId = 'background_channel';
  
  // Cache Settings
  static const int cacheMaxAge = 300; // 5 minutes in seconds
  static const int cacheMaxSize = 100 * 1024 * 1024; // 100MB in bytes
  
  // Security
  static const int tokenRefreshThreshold = 300; // Refresh token 5 minutes before expiry
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 15; // minutes
  
  // Analytics
  static const int analyticsBatchSize = 20;
  static const int analyticsFlushInterval = 30; // seconds
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String devicesEndpoint = '/devices';
  static const String healthMetricsEndpoint = '/health/metrics';
  static const String alertsEndpoint = '/alerts';
  static const String configurationEndpoint = '/config';
  
  // Local Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';
  static const String deviceListKey = 'device_list';
  static const String appSettingsKey = 'app_settings';
  static const String lastSyncTimeKey = 'last_sync_time';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authenticationError = 'Authentication failed. Please log in again.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String unknownError = 'An unexpected error occurred.';
  
  // Validation Patterns
  static final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
  
  // Device Discovery
  static const String deviceDiscoveryService = '_avc-device._tcp';
  static const int deviceDiscoveryPort = 5353;
  static const int deviceDiscoveryTimeout = 10; // seconds
}