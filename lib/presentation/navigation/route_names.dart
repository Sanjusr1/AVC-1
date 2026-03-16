class RouteNames {
  // Auth routes
  static const String splash = 'splash';
  static const String login = 'login';
  
  // Main app routes
  static const String dashboard = 'dashboard';
  static const String deviceDiscovery = 'deviceDiscovery';
  static const String devicePairing = 'devicePairing';
  static const String deviceList = 'deviceList';
  static const String deviceDetail = 'deviceDetail';
  static const String healthMonitor = 'healthMonitor';
  static const String healthCharts = 'healthCharts';
  static const String controlPanel = 'controlPanel';
  static const String deviceConfig = 'deviceConfig';
  static const String aiModelSelection = 'aiModelSelection';
  static const String sensorCalibration = 'sensorCalibration';
  static const String firmwareUpdate = 'firmwareUpdate';
  static const String aiAssistant = 'aiAssistant';
  static const String alerts = 'alerts';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String about = 'about';
  
  // Modal routes
  static const String addDevice = 'addDevice';
  static const String deviceDetailModal = 'deviceDetailModal';
  static const String alertDetail = 'alertDetail';
  
  // Deep link routes
  static const String deviceDeepLink = 'device/:deviceId';
  static const String alertDeepLink = 'alert/:alertId';
  
  // Route parameters
  static const String deviceIdParam = 'deviceId';
  static const String alertIdParam = 'alertId';
  static const String categoryParam = 'category';
  static const String modelIdParam = 'modelId';
  
  // Query parameters
  static const String fromParam = 'from';
  static const String successParam = 'success';
  static const String errorParam = 'error';
  
  // Route groups
  static const List<String> authRoutes = [splash, login];
  static const List<String> mainRoutes = [
    dashboard,
    deviceDiscovery,
    devicePairing,
    deviceList,
    deviceDetail,
    healthMonitor,
    healthCharts,
    controlPanel,
    deviceConfig,
    aiModelSelection,
    sensorCalibration,
    firmwareUpdate,
    aiAssistant,
    alerts,
    settings,
    profile,
    about,
  ];
  static const List<String> modalRoutes = [
    addDevice,
    deviceDetailModal,
    alertDetail,
  ];
  
  // Route path patterns
  static String getDeviceDetailPath(String deviceId) => '/device/$deviceId';
  static String getAlertDetailPath(String alertId) => '/alert/$alertId';
  
  // Route builders
  static Map<String, String> buildDeviceDetailParams(String deviceId) => {
    deviceIdParam: deviceId,
  };
  
  static Map<String, String> buildAlertDetailParams(String alertId) => {
    alertIdParam: alertId,
  };
  
  static Map<String, String> buildSuccessQueryParams(String from) => {
    fromParam: from,
    successParam: 'true',
  };
  
  static Map<String, String> buildErrorQueryParams(String from, String error) => {
    fromParam: from,
    errorParam: error,
  };
}