part of realtime_storage;

class RealtimeDocument {
  String get id => _data['_id'];
  DateTime get createdAt => DateTime.parse(_data['_created_at']);
  DateTime? get updatedAt => _data['_updated_at'] == null
      ? null
      : DateTime.parse(_data['_updated_at']);

  late Map<String, dynamic> _data;
  final RealtimeStorage _storage;

  final String _path;
  RealtimeDocument._({
    required Map<String, dynamic> data,
    required RealtimeStorage storage,
    required String path,
  })  : _path = path,
        _storage = storage,
        _data = data;

  RealtimeCollection get collection {
    final paths = _path.split('/');
    paths.removeLast();
    return _storage.collection(paths.join('/'));
  }

  dynamic operator [](String key) {
    return _data[key];
  }

  void _updateData(Map<String, dynamic> data) {
    _data = data;
  }

  void operator []=(String key, dynamic value) {
    assert(
      !key.startsWith('_'),
      'Keys that begin with an underscore are reserved words.',
    );
    _data[key] = value;
  }

  Future<bool> update() async {
    final updated = Map.from(_data);
    updated.remove('_id');

    final res = await _storage._dio.put(
      _path,
      data: updated,
    );
    return res.statusCode == 200;
  }

  Future<bool> delete() async {
    final res = await _storage._dio.delete(_path);
    return res.statusCode == 200;
  }

  Stream<RealtimeDocument?> stream() async* {
    yield this;
    yield* _storage._listenFor(_path).transform(
      StreamTransformer.fromHandlers(
        handleData: (event, sink) {
          final path = event['path'];
          if (path == path) {
            final command = event['event'];
            switch (command) {
              case 'update':
                final data = event['value'];
                if (data != null) {
                  _data = data;
                  sink.add(this);
                  return;
                }
                break;

              case 'delete':
                sink.add(null);
                break;
              default:
            }
          }
        },
      ),
    );
  }
}
