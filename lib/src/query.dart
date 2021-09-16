part of realtime_storage;

class Query {
  final Condition where;
  const Query(this.where);

  String get _value => base64Url.encode(
        utf8.encode(
          json.encode(where.data),
        ),
      );

  bool _evaluate(RealtimeDocument document) => where._evaluate(document);
}

abstract class Condition {
  Map<String, dynamic> get data;
  bool _evaluate(RealtimeDocument document);
}

class And implements Condition {
  final List<Condition> conditions;
  And(this.conditions);

  @override
  Map<String, dynamic> get data => {
        r'$and': conditions.map((e) => e.data).toList(),
      };

  @override
  bool _evaluate(RealtimeDocument document) {
    return conditions.every((element) => element._evaluate(document));
  }
}

class Or implements Condition {
  final List<Condition> conditions;
  Or(this.conditions);

  @override
  Map<String, dynamic> get data => {
        r'$or': conditions.map((e) => e.data).toList(),
      };

  @override
  bool _evaluate(RealtimeDocument document) {
    return conditions.any((element) => element._evaluate(document));
  }
}

class Not implements Condition {
  final Condition condition;
  Not(this.condition);

  @override
  Map<String, dynamic> get data => {
        r'$not': condition.data,
      };

  @override
  bool _evaluate(RealtimeDocument document) {
    return !condition._evaluate(document);
  }
}

class Nor implements Condition {
  final List<Condition> conditions;
  Nor(this.conditions);

  @override
  Map<String, dynamic> get data => {
        r'$nor': conditions.map((e) => e.data).toList(),
      };

  @override
  bool _evaluate(RealtimeDocument document) {
    return !(conditions.any((element) => element._evaluate(document)));
  }
}

abstract class FieldCondition implements Condition {
  final String fieldName;
  final dynamic value;

  String get operator;

  FieldCondition({
    required this.fieldName,
    required this.value,
  });

  @override
  Map<String, dynamic> get data => {
        fieldName: {
          operator: value,
        }
      };
}

class Exists extends FieldCondition {
  Exists({
    required String fieldName,
    required bool value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$exists';

  @override
  bool _evaluate(RealtimeDocument document) {
    return document.containsKey(fieldName);
  }
}

class RegEx implements Condition {
  final String fieldName;
  final RegExp pattern;

  RegEx({
    required this.fieldName,
    required this.pattern,
  });

  @override
  Map<String, dynamic> get data => {
        fieldName: {
          r'$regex': pattern.pattern,
        }
      };

  @override
  bool _evaluate(RealtimeDocument document) {
    return pattern.hasMatch(document[fieldName]);
  }
}

class Equals extends FieldCondition {
  Equals({
    required String fieldName,
    required dynamic value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$eq';

  @override
  bool _evaluate(RealtimeDocument document) {
    return document[fieldName] == value;
  }
}

class GreaterThan extends FieldCondition {
  GreaterThan({
    required String fieldName,
    required dynamic value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$gt';

  @override
  bool _evaluate(RealtimeDocument document) {
    return document[fieldName] > value;
  }
}

class LowerThan extends FieldCondition {
  LowerThan({
    required String fieldName,
    required dynamic value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$lt';

  @override
  bool _evaluate(RealtimeDocument document) {
    return document[fieldName] < value;
  }
}

class LowerThanEquals extends FieldCondition {
  LowerThanEquals({
    required String fieldName,
    required dynamic value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$lte';
  @override
  bool _evaluate(RealtimeDocument document) {
    return document[fieldName] <= value;
  }
}

class GreaterThanEquals extends FieldCondition {
  GreaterThanEquals({
    required String fieldName,
    required dynamic value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$gte';
  @override
  bool _evaluate(RealtimeDocument document) {
    return document[fieldName] >= value;
  }
}

class NotEquals extends FieldCondition {
  NotEquals({
    required String fieldName,
    required dynamic value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$ne';
  @override
  bool _evaluate(RealtimeDocument document) {
    return document[fieldName] != value;
  }
}

class In extends FieldCondition {
  In({
    required String fieldName,
    required List<dynamic> value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$in';
  @override
  bool _evaluate(RealtimeDocument document) {
    return value.contains(document[fieldName]);
  }
}

class NotIn extends FieldCondition {
  NotIn({
    required String fieldName,
    required List<dynamic> value,
  }) : super(fieldName: fieldName, value: value);

  @override
  String get operator => r'$nin';

  @override
  bool _evaluate(RealtimeDocument document) {
    return !value.contains(document[fieldName]);
  }
}
