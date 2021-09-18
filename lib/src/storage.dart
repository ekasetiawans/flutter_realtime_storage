part of realtime_storage;

class RealtimeStorage {
  final String baseURL;
  final String database;
  late final Dio _dio;
  late WebSocket _webSocket;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  RealtimeStorage({
    required this.baseURL,
    required this.database,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: '$baseURL/database/$database/',
        contentType: 'application/json',
        setRequestContentTypeWhenNoPayload: true,
        responseType: ResponseType.json,
      ),
    );

    _connectWebSocket();
  }

  final _webSocketReady = Completer<WebSocket>();
  Future<void> _connectWebSocket() async {
    try {
      final wsUrl = baseURL.replaceFirst('http', 'ws');
      _webSocket = WebSocket('$wsUrl/database/$database/');
      await _webSocket.connect();

      _webSocket.listen(
        (event) {
          final data = json.decode(event);
          _controller.add(data);
        },
        cancelOnError: false,
        onDone: () {
          if (!_isDisposed) {
            Future.delayed(const Duration(seconds: 1), _connectWebSocket);
          }
        },
        onError: (err) {},
      );

      if (!_webSocketReady.isCompleted) {
        _webSocketReady.complete(_webSocket);
      }

      final subs = List.from(_subscriptions);
      _subscriptions.clear();

      for (var sub in subs) {
        _sub(sub);
      }
    } catch (e) {
      if (!_isDisposed) {
        Future.delayed(const Duration(seconds: 1), _connectWebSocket);
      }
    }
  }

  final _subscriptions = <String>[];
  Future<void> _sub(String path) async {
    await _webSocketReady.future;
    if (_subscriptions.contains(path)) return;
    _subscriptions.add(path);
    _webSocket.add(json.encode({
      'command': 'sub',
      'path': path,
    }));
  }

  Future<void> _unsub(String path) async {
    await _webSocketReady.future;
    if (!_subscriptions.contains(path)) return;
    _subscriptions.remove(path);
    _webSocket.add(json.encode({
      'command': 'unsub',
      'path': path,
    }));
  }

  RealtimeCollection collection(String path) {
    return RealtimeCollection._(
      path: path,
      storage: this,
    );
  }

  Future<RealtimeDocument?> document(String path) async {
    final segments = path.split('/');
    if (segments.length % 2 == 1) {
      throw Exception('path is not valid as document path');
    }

    final res = await _dio.get(path);
    if (res.statusCode == 200) {
      return RealtimeDocument._(
        data: res.data,
        storage: this,
        path: path,
      );
    }
  }

  final Map<String, Stream<Map<String, dynamic>>> _subscribers = {};
  Stream<Map<String, dynamic>> _listenFor(String path) async* {
    if (_subscribers.containsKey(path)) {
      yield* _subscribers[path]!;
      return;
    }

    _sub(path);
    _subscribers[path] =
        _controller.stream.transform(StreamTransformer.fromHandlers(
      handleData: (event, sink) {
        final _path = event['path'];
        if (_path == path) {
          sink.add(event);
        }
      },
    ));

    yield* _subscribers[path]!;

    _subscribers.remove(path);
    _unsub(path);
  }

  Future<bool> uploadFile({
    required String remotePath,
    required List<int> value,
    required String fileName,
  }) async {
    final url = '$baseURL/storage/$database/$remotePath';
    final res = await _dio.post(
      url,
      data: {
        'file': MultipartFile.fromBytes(
          value,
          filename: fileName,
        ),
      },
    );

    return res.statusCode == 200;
  }

  bool _isDisposed = false;
  void dispose() {
    _isDisposed = true;
    _controller.close();
    _webSocket.close();
  }
}
