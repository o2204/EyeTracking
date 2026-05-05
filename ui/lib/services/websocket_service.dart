import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get stream => _controller.stream;

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(ApiConfig.wsUrl));
    _channel!.stream.listen(
      (message) => _controller.add(message),
      onDone: () => print('WebSocket closed'),
      onError: (error) => print('WebSocket error: $error'),
    );
  }

  void sendBytes(List<int> bytes) {
    if (_channel != null) {
      _channel!.sink.add(bytes);
    }
  }

  void dispose() {
    _channel?.sink.close();
    _controller.close();
  }
}
