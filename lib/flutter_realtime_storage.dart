library realtime_storage;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'src/websocket/websocket_io.dart'
    if (dart.library.html) 'src/websocket/websocket_web.dart';

part 'src/collection.dart';
part 'src/document.dart';
part 'src/query.dart';
part 'src/storage.dart';
