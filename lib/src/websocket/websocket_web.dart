// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html show WebSocket;

import 'websocket.dart';

class WebSocket implements WebSocketBase {
  html.WebSocket? _socket;
  final String url;
  WebSocket(this.url);

  @override
  Future<bool> connect() async {
    if (_socket != null) {
      return true;
    }

    _socket = html.WebSocket(url);
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

    return _socket!.onMessage.listen(
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

    _socket!.send(data);
  }

  @override
  Future<void> close() async {
    if (_socket == null) {
      throw Exception('You have to connect first');
    }

    _socket!.close();
  }
}
