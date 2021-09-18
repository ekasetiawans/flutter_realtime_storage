part of realtime_storage;

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

abstract class Comparator {
  final dynamic value;
  Comparator({required this.value});

  String get operator;
  Map<String, dynamic> get data => {
        operator: value,
      };

  bool _evaluate(dynamic value);
}

class Field implements Condition {
  final String name;
  final Comparator value;

  Field({
    required this.name,
    required this.value,
  });

  @override
  Map<String, dynamic> get data => {
        name: value.data,
      };

  @override
  bool _evaluate(RealtimeDocument document) {
    return value._evaluate(document[name]);
  }

  factory Field.equals({
    required String name,
    required dynamic value,
  }) =>
      Field(
        name: name,
        value: Equals(value: value),
      );

  factory Field.notEquals({
    required String name,
    required dynamic value,
  }) =>
      Field(
        name: name,
        value: NotEquals(value: value),
      );

  factory Field.greaterThan({
    required String name,
    required dynamic value,
  }) =>
      Field(
        name: name,
        value: GreaterThan(value: value),
      );

  factory Field.greaterThanEquals({
    required String name,
    required dynamic value,
  }) =>
      Field(
        name: name,
        value: GreaterThanEquals(value: value),
      );

  factory Field.lowerThan({
    required String name,
    required dynamic value,
  }) =>
      Field(
        name: name,
        value: LowerThan(value: value),
      );

  factory Field.lowerThanEquals({
    required String name,
    required dynamic value,
  }) =>
      Field(
        name: name,
        value: LowerThanEquals(value: value),
      );

  factory Field.inside({
    required String name,
    required List<dynamic> value,
  }) =>
      Field(
        name: name,
        value: In(value: value),
      );

  factory Field.notInside({
    required String name,
    required List<dynamic> value,
  }) =>
      Field(
        name: name,
        value: NotIn(value: value),
      );
}

class Exists implements Condition {
  final String fieldName;
  final bool value;

  Exists({
    required this.fieldName,
    required this.value,
  });

  @override
  Map<String, dynamic> get data => {
        fieldName: {
          r'$exists': value,
        },
      };

  @override
  bool _evaluate(RealtimeDocument document) {
    if (value) {
      return document.containsKey(fieldName);
    }

    return !document.containsKey(fieldName);
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

class Equals extends Comparator {
  Equals({
    required dynamic value,
  }) : super(value: value);

  @override
  String get operator => r'$eq';

  @override
  bool _evaluate(dynamic value) {
    return value == this.value;
  }
}

class GreaterThan extends Comparator {
  GreaterThan({
    required dynamic value,
  }) : super(value: value);

  @override
  String get operator => r'$gt';

  @override
  bool _evaluate(dynamic value) {
    return value > this.value;
  }
}

class LowerThan extends Comparator {
  LowerThan({
    required dynamic value,
  }) : super(value: value);

  @override
  String get operator => r'$lt';

  @override
  bool _evaluate(dynamic value) {
    return value < this.value;
  }
}

class LowerThanEquals extends Comparator {
  LowerThanEquals({
    required dynamic value,
  }) : super(value: value);

  @override
  String get operator => r'$lte';
  @override
  bool _evaluate(dynamic value) {
    return value <= this.value;
  }
}

class GreaterThanEquals extends Comparator {
  GreaterThanEquals({
    required dynamic value,
  }) : super(value: value);

  @override
  String get operator => r'$gte';
  @override
  bool _evaluate(dynamic value) {
    return value >= this.value;
  }
}

class NotEquals extends Comparator {
  NotEquals({
    required dynamic value,
  }) : super(value: value);

  @override
  String get operator => r'$ne';
  @override
  bool _evaluate(dynamic value) {
    return value != this.value;
  }
}

class In extends Comparator {
  In({
    required List<dynamic> value,
  }) : super(value: value);

  @override
  String get operator => r'$in';
  @override
  bool _evaluate(dynamic value) {
    return this.value.contains(value);
  }
}

class NotIn extends Comparator {
  NotIn({
    required List<dynamic> value,
  }) : super(value: value);

  @override
  String get operator => r'$nin';

  @override
  bool _evaluate(dynamic value) {
    return !this.value.contains(value);
  }
}
