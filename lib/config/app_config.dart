import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'constants.dart';

class AppConfig {
  static late Logger logger;
  static late bool isDebugMode;
  static late String appVersion;
  static late String buildNumber;
  
  static Future<void> initialize() async {
    isDebugMode = kDebugMode;
    
    // Initialize logger
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
    
    // Initialize app version info
    // This will be populated from package_info_plus in a real app
    appVersion = '1.0.0';
    buildNumber = '1';
    
    logger.i('AppConfig initialized');
    logger.i('Debug mode: $isDebugMode');
    logger.i('App version: $appVersion ($buildNumber)');
  }
  
  static String get apiBaseUrl {
    if (isDebugMode) {
      return AppConstants.debugApiBaseUrl;
    } else {
      return AppConstants.productionApiBaseUrl;
    }
  }
  
  static String get websocketBaseUrl {
    if (isDebugMode) {
      return AppConstants.debugWebsocketBaseUrl;
    } else {
      return AppConstants.productionWebsocketBaseUrl;
    }
  }
}