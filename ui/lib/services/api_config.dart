class ApiConfig {
  static const String laptopIp = '127.0.0.1';
  static const String baseUrl = 'http://$laptopIp:8000';
  static const String aiServiceUrl = 'http://$laptopIp:8001';
  static const String wsUrl = 'ws://$laptopIp:8000/controller/gaze-control';
}
