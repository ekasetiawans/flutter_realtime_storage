import 'dart:async';

abstract class WebSocketBase {
  WebSocketBase(String url);
  Future<bool> connect();

  StreamSubscription<dynamic> listen(
    void Function(dynamic event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  });

  void add(dynamic data);

  Future<void> close();
}
