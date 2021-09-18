import 'dart:async';
import 'dart:io' as io show WebSocket;

import 'websocket.dart';

class WebSocket implements WebSocketBase {
  io.WebSocket? _socket;

  final String url;
  WebSocket(this.url);

  @override
  Future<bool> connect() async {
    if (_socket != null) {
      return true;
    }

    _socket = await io.WebSocket.connect(url);
    return true;
  }

  @override
  StreamSubscription<dynamic> listen(
    void Function(dynamic event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (_socket == null) {
      throw Exception('You have to connect first');
    }

    return _socket!.listen(
      onData,
      onError: onError,
      cancelOnError: cancelOnError,
      onDone: onDone,
    );
  }

  @override
  void add(dynamic data) {
    if (_socket == null) {
      throw Exception('You have to connect first');
    }

    _socket!.add(data);
  }

  @override
  Future<void> close() async {
    if (_socket == null) {
      throw Exception('You have to connect first');
    }

    await _socket!.close();
  }
}
