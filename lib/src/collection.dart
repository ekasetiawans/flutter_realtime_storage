part of realtime_storage;

class RealtimeCollection {
  final String _path;
  final RealtimeStorage _storage;

  RealtimeCollection._({required String path, required RealtimeStorage storage})
      : _storage = storage,
        _path = path;

  Future<RealtimeDocument?> getDocumentById(String id) async {
    final idx = _list.indexWhere((element) => element.id == id);
    if (idx >= 0) {
      return _list[idx];
    }

    return _storage.document(_path + '/' + id);
  }

  List<RealtimeDocument> _list = [];
  Stream<List<RealtimeDocument>> stream({Query? where}) async* {
    final segments = _path.split('/');
    if (segments.length % 2 == 0) {
      throw Exception('path is not valid as collection path');
    }

    yield _list;
    final res = await _storage._dio.get(
      _path,
      queryParameters: {
        if (where != null) 'q': where._value,
      },
    );

    List<RealtimeDocument> list = [];
    if (res.statusCode == 200) {
      if (res.data is List) {
        list = (res.data as List)
            .map(
              (e) => RealtimeDocument._(
                data: e,
                storage: _storage,
                path: _path + '/' + e['_id'],
              ),
            )
            .toList();
        yield list;
      }
    }

    _list = list;
    yield* _storage._listenFor(_path).transform(
      StreamTransformer.fromHandlers(
        handleData: (event, sink) {
          final command = event['event'];
          switch (command) {
            case 'add':
              final data = event['value'];
              if (data != null) {
                final snapshot = RealtimeDocument._(
                  data: data,
                  storage: _storage,
                  path: _path + '/' + data['_id'],
                );

                if (where == null || where._evaluate(snapshot)) {
                  list.add(snapshot);
                  sink.add(list);
                }
              }
              break;

            case 'update':
              final data = event['value'];
              if (data != null) {
                final snapshot = RealtimeDocument._(
                  data: data,
                  storage: _storage,
                  path: _path + '/' + data['_id'],
                );

                if (where == null || where._evaluate(snapshot)) {
                  final idx =
                      list.indexWhere((element) => element.id == snapshot.id);
                  if (idx >= 0) {
                    final doc = list[idx];
                    doc._updateData(snapshot._data);
                    sink.add(list);
                  }
                }
              }
              break;

            case 'delete':
              final data = event['value'];
              if (data != null) {
                final docId = data['documentId'];
                list.removeWhere((element) => element.id == docId);
              } else {
                list.clear();
              }

              sink.add(list);
              break;
            default:
          }
        },
      ),
    );
  }

  Future<RealtimeDocument?> add(Map<String, dynamic> data) async {
    final res = await _storage._dio.post(
      _path,
      data: data,
    );

    if (res.statusCode == 200) {
      final result = RealtimeDocument._(
        data: res.data,
        storage: _storage,
        path: _path + '/' + res.data['_id'],
      );

      return result;
    }
  }
}
