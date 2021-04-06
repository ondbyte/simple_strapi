part of 'simple_strapi_base.dart';

///sort the query results in two possible ways
enum Sort {
  ascending,
  descending,
}

///query against published or draft items in collection
enum PublicationState {
  published,
  draft,
}

class StrapiCollectionQuery extends StrapiModelQuery {
  final int? limit, start;
  final String collectionName;

  ///graph query against strapi cllection or List of references (think of contains many references in strapi) in Strapi data structure,
  ///you can nest it according to the reference fields that exists in the data structure of the collection model,
  ///[collectionName] is required only for the root query, any [collectionName] passed to additional
  ///queries of a root query are ignored because query will be made against the field name,
  ///[requiredFields] in the response,
  ///[limit] is the maximum number of documents in the response,
  ///[start] can be used to paginate the queries,
  StrapiCollectionQuery({
    required this.collectionName,
    required List<StrapiField> requiredFields,
    this.limit,
    this.start,
  }) : super(requiredFields: requiredFields);

  @override
  MapEntry<String, String> _queryParts() {
    final l = super._queryParts();
    final limitString = (limit is int) ? "limit: $limit," : "";
    final startString = (start is int) ? "start: $start," : "";
    final key = "$limitString$startString where:{${l.key}}";
    return MapEntry(key, l.value);
  }

  ///stringified query, pass the [collectionName] to replace the original root collectionName
  ///in output string
  String query({String? collectionName}) {
    final cn =
        _collectionNameToGraphQlName(collectionName ?? this.collectionName);
    final l = _queryParts();
    return "$cn(${l.key}){${l.value}}";
  }
}

class StrapiModelQuery {
  final _where = <String>[];
  final _fields = <StrapiField, String>{};

  ///base strapi graph query
  ///this query is made against single reference field which exist in a strapi data/model structure
  ///[requiredFields] in the response,
  StrapiModelQuery({
    required List<StrapiField> requiredFields,
  }) {
    _fields.addAll(
      requiredFields.fold(
        {},
        (previousValue, element) {
          if (element is! StrapiComponentField) {
            previousValue.addAll({element: ""});
          }
          return previousValue;
        },
      ),
    );
  }

  void requireCompenentField(
      StrapiComponentField field, List<StrapiField> fields) {
    var s = "";
    fields.forEach((e) {
      if (e is StrapiCollectionField || e is StrapiModelField) {
        s += "${e.fieldName}{\nid\n}\n";
      } else if (e is StrapiLeafField) {
        s += "${e.fieldName}\n";
      }
    });
    _fields.addAll({field: "${field.fieldName}{\n$s\n}"});
  }

  ///used to filter against a field in strapi data structure in collection
  void whereField({
    required StrapiLeafField field,
    required StrapiFieldQuery query,
    required value,
  }) {
    final v = StrapiField.processValue(value, query);
    if (v is String) {
      _where.add(field.fieldName + _operation(query) + ":$v");
    } else {
      throw Exception(
        "leaf value must be a basic type or list of basic type incase of includes/notincludes in an array operation ${v.runtimeType}",
      );
    }
  }

  void whereModelField({
    required StrapiModelField field,
    required StrapiModelQuery query,
  }) {
    final entry = query._queryParts();
    _where.add(field.fieldName + ": {" + entry.key + "}");
    _fields.remove(field);
    _fields.addAll({field: "${field.fieldName}{${entry.value}}"});
  }

  void whereCollectionField({
    required StrapiCollectionField field,
    required StrapiCollectionQuery query,
  }) {
    _fields.remove(field);
    _fields.addAll(
      {
        field: query.query(collectionName: field.fieldName),
      },
    );
  }

  ///
  ///```dart
  /////first on is
  ///where({variable1:"value"})
  /////second one
  ///{
  ///   variable1
  ///   variable2
  ///}
  ///```
  MapEntry<String, String> _queryParts() {
    final k = _where.join(",");
    final tmp = <StrapiField, String>{};
    _fields.forEach(
      (key, value) {
        if (value.isEmpty) {
          if (key is StrapiModelField || key is StrapiCollectionField) {
            tmp.addAll({key: "${key.fieldName}{\nid\n}"});
          } else if (key is StrapiComponentField) {
          } else {
            tmp.addAll(
              {key: "${key.fieldName}"},
            );
          }
        } else {
          tmp.addAll({key: value});
        }
      },
    );
    _fields.clear();
    _fields.addAll(tmp);
    final v = _fields.values.join("\n");
    return MapEntry(k, v);
  }
}

class StrapiStatics {
  static final _statics = <String, dynamic>{};

  static getValue(String key) {
    return _statics[key];
  }
}

class StrapiCollectionField extends StrapiField {
  StrapiCollectionField(String fieldName) : super(fieldName);
}

class StrapiModelField extends StrapiField {
  StrapiModelField(String fieldName) : super(fieldName);
}

class StrapiLeafField extends StrapiField {
  StrapiLeafField(String fieldName) : super(fieldName);
}

class StrapiComponentField extends StrapiField {
  StrapiComponentField(String fieldName) : super(fieldName);
}

///base class for strapi field
abstract class StrapiField {
  final String fieldName;
  StrapiField(this.fieldName);

  ///helper function which evaluates whether the value provided is leaf value
  ///like [String], [int], [double], [bool], [DateTime] or lis of these types incase the query operation is
  ///[StrapiFieldQuery.includesInAnArray] or [StrapiFieldQuery.notIncludesInAnArray]
  static String? processValue(value, StrapiFieldQuery query) {
    if (value is int || value is double || value is bool) {
      return "$value";
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is String) {
      return '''"$value"''';
    }

    ///specific to [StrapiFieldQuery.includesInAnArray] or [StrapiFieldQuery.notIncludesInAnArray]
    if (value is List &&
        (query == StrapiFieldQuery.includesInAnArray ||
            query == StrapiFieldQuery.notIncludesInAnArray) &&
        value.isNotEmpty &&
        value.first is String) {
      return "[${value.map((e) => "\"$e\"").join(",")}]";
    }
  }
}

///stringify the [StrapiFieldQuery] operation
String _operation(StrapiFieldQuery operation) {
  switch (operation) {
    case StrapiFieldQuery.equalTo:
      return "_eq";
    case StrapiFieldQuery.notEqualsTo:
      return "_ne";
    case StrapiFieldQuery.lowerThan:
      return "_lt";
    case StrapiFieldQuery.lowerThanOrEqualTo:
      return "_lte";
    case StrapiFieldQuery.greaterThan:
      return "_gt";
    case StrapiFieldQuery.greaterThanOrEqualTo:
      return "_gte";
    case StrapiFieldQuery.contains:
      return "_contains";
    case StrapiFieldQuery.containsCaseSensitive:
      return "_containss";
    case StrapiFieldQuery.includesInAnArray:
      return "_in";
    case StrapiFieldQuery.notIncludesInAnArray:
      return "_nin";
    case StrapiFieldQuery.equalsNull:
      return "_null";
  }
}

///the query operations supported by Strapi as of now,
///please request feature if qny queries are missing
enum StrapiFieldQuery {
  equalTo,
  notEqualsTo,
  lowerThan,
  lowerThanOrEqualTo,
  greaterThan,
  greaterThanOrEqualTo,
  contains,
  containsCaseSensitive,
  includesInAnArray,
  notIncludesInAnArray,
  equalsNull,
}

String _collectionNameToGraphQlName(
  String collectionName,
) {
  final all = collectionName.split(RegExp(r'[\s_-]'));
  final from2nd = all.sublist(1);
  var returnable = "" + all[0];
  from2nd.forEach((s) {
    returnable += _capitalizeFirst(s);
  });
  return returnable;
}

String _capitalizeFirst(String s) {
  final f = s.split("").first;
  return s.replaceFirst(
    f,
    f.toUpperCase(),
  );
}
