import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();
  bool _disposed = false;

  Stream<dynamic> get stream => _controller.stream;

  void connect([String? token]) {
    if (_disposed) return;
    try {
      String url = ApiConfig.wsUrl;
      if (token != null) {
        url += "?token=$token";
      }
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
        (message) {
          if (!_controller.isClosed) _controller.add(message);
        },
        onDone: _handleDisconnect,
        onError: (error) {
          if (!_controller.isClosed) _controller.addError(error);
          _handleDisconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (!_controller.isClosed) _controller.addError(e);
    }
  }

  void _handleDisconnect() {
    // Auto-reconnect after 3 seconds if not intentionally disposed
    if (!_disposed) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!_disposed) connect();
      });
    }
  }

  void sendBytes(List<int> bytes) {
    if (_channel != null && !_disposed) {
      try {
        _channel!.sink.add(bytes);
      } catch (_) {
        // Channel may be closed; reconnect will handle it
      }
    }
  }

  void dispose() {
    _disposed = true;
    _channel?.sink.close();
    _controller.close();
  }
}
