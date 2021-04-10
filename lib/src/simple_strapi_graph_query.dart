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

  ///graph query against strapi collection or List of references (think of repeatable references in strapi) in Strapi data structure,
  ///you can nest it according to the reference fields that exists in the data structure of the collection model,
  ///[collectionName] is required only for the root query, any [collectionName] passed to additional
  ///queries of a root query are ignored because query will be made against the field name,
  ///pass [requiredFields] to be in the response,
  ///[limit] is the maximum number of documents in the response,
  ///[start] can be used to paginate the queries,
  ///
  ///if you have a collections like the fallowing,
  ///
  ///A with model
  ///```json
  ///{
  ///   "id":"<value>",
  ///   "name": "<value>",
  ///   "single_reference_for_B": "<id>",
  ///   "repeatable_reference_for_C": ["<id>","<id>",...],
  ///}
  ///```
  ///
  ///B with model
  ///```json
  ///{
  ///   "id":"<value>",
  ///   "dob": "<value>",
  ///}
  ///```
  ///
  ///C with model
  ///```json
  ///{
  ///   "id":"<value>",
  ///   "place": "<value>",
  ///}
  ///```
  ///for above collection models, if you are making graph query against A, required fields are passed like this
  ///```dart
  ///final query = StrapiCollectionQuery(
  /// collectionName: "A",
  /// requiredFields: [
  ///   StrapiLeafField("id"),
  ///   StrapiLeafField("name"),
  /// ],
  ///);
  //////and [StrapiLeafField]s are filtered like this, this query returns objects contining the id (must return only one)
  //////check out [StrapiFieldQuery] to see all the filter posibilities
  ///query.whereField(
  ///    field: StrapiLeafField("id"),
  ///    query: StrapiFieldQuery.equalTo,
  ///    value: "<value>",
  ///  );
  ///```
  ///you cannot require the fields `single_reference_for_B` and `repeatable_reference_for_C`
  ///as they are references, if you want to require them you have to nest the query against them like this,
  ///
  ///lets modify the last query
  ///
  ///```
  //////use [StrapiModelQuery] if the reference is single
  ///query.whereModelField(
  /// field: StrapiModelField("single_reference_for_B"),
  ///   query: StrapiModelQuery(
  ///   requiredFields: [
  ///     StrapiLeafField("id"),
  ///     StrapiLeafField("dob"),
  ///   ],
  /// ),
  ///);
  ///
  //////use [StrapiCollectionQuery] if the reference is repeatable i.e list of references as mentioned earlier
  ///query.whereCollectionField(
  /// field: StrapiCollectionField("repeatable_reference_for_C"),
  /// query: StrapiCollectionQuery(
  ///   collectionName: "C",
  ///   requiredFields: [
  ///     StrapiLeafField("id"),
  ///     StrapiLeafField("place"),
  ///   ],
  /// ),
  ///);
  ///```
  StrapiCollectionQuery({
    required collectionName,
    required List<StrapiField> requiredFields,
    this.limit,
    this.start,
  })  : this.collectionName = _collectionNameToGraphQlName(collectionName),
        super(requiredFields: requiredFields);

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
    final cn = (collectionName is String)
        ? _collectionNameToGraphQlName(collectionName)
        : this.collectionName;
    final l = _queryParts();
    return "$cn(${l.key}){${l.value}}";
  }
}

///query to be made aginst single references in the collection model
class StrapiModelQuery {
  final _where = <String>[];
  final _fields = <StrapiField, String>{};
  var a = StrapiLeafField("ya");

  ///base strapi graph query
  ///this query is made against single reference field which exist in a strapi data/model structure
  ///pass [requiredFields] to be in the response, if the reference field contains repeatable collection object
  ///then you must use [StrapiCollectionQuery],
  ///for complete idea how to use this check [StrapiCollectionQuery],
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

  ///compenents of strapi models cannot be queried, it isn't supported by strapi as of now, so to include them in
  ///the response you have to explicitly pass the field names as String, for example
  ///```dart
  ///requireCompenentField(
  ///   field: StrapiComponentField("someField"),
  ///   fields: "{ componentFieldA,componentFieldB,componentFieldC }",
  ///)
  ///```
  void requireCompenentField(
    StrapiComponentField field,
    String fields,
  ) {
    _fields.addAll({field: "${field.fieldName}$fields"});
  }

  ///used to filter against a field in strapi data structure in collection, [field] should be a
  ///leaf fields, which means it should be a basic data type supported by strapi like
  ///Date, String, Number, bool etc
  ///throws [StrapiException] if field isnt truw [StrapiLeafField]
  void whereField({
    required StrapiLeafField field,
    required StrapiFieldQuery query,
    required value,
  }) {
    final v = StrapiField.processValue(value, query);
    if (v is String) {
      _where.add(field.fieldName + _operation(query) + ":$v");
    } else {
      throw StrapiException(
        msg:
            "leaf value must be a basic type or list of basic type incase of includes/notincludes in an array operation ${v.runtimeType}",
      );
    }
  }

  ///query against a field containing single reference to other collection object
  void whereModelField({
    required StrapiModelField field,
    required StrapiModelQuery query,
  }) {
    final entry = query._queryParts();
    _where.add(field.fieldName + ": {" + entry.key + "}");
    _fields.remove(field);
    _fields.addAll({field: "${field.fieldName}{${entry.value}}"});
  }

  ///query against field containing repeatable reference to other collection objects
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
            tmp.addAll({key: value});
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

///Strapi object field containing references to other colection objects
class StrapiCollectionField extends StrapiField {
  StrapiCollectionField(String fieldName) : super(fieldName);
}

///Strapi object field containing reference to other colection object
class StrapiModelField extends StrapiField {
  StrapiModelField(String fieldName) : super(fieldName);
}

///Strapi field containing base strapi data types like
///Date, String, Number, bool etc
class StrapiLeafField extends StrapiField {
  StrapiLeafField(String fieldName) : super(fieldName);
}

///Strapi field containing a strapi components
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
