import 'package:code_builder/code_builder.dart';

import 'helpers.dart';

Reference? getDartTypeFromStrapiType(
    {String name = "",
    String strapiType = "",
    String component = "",
    String collection = "",
    String model = "",
    bool componentRepeatable = false}) {
  switch (strapiType) {
    case "date":
    case "datetime":
    case "time":
      {
        return Reference(
          "DateTime?",
        );
      }
    case "decimal":
    case "float":
      {
        return Reference("double?");
      }
    case "integer":
    case "biginteger":
      {
        return Reference("int?");
      }
    case "string":
    case "richtext":
      {
        return Reference("String?");
      }
    case "boolean":
      {
        return Reference("bool?");
      }
    case "email":
      {
        return Reference("String?");
      }
    case "json":
      {
        return Reference("Map<String,dynamic>?");
      }
    case "component":
      {
        if (component.isEmpty) {
          throw Exception("component cannot be empty while referencing a type");
        }
        final className = toClassName(component);
        if (componentRepeatable) {
          return ComponentListReference("List<$className>?", className);
        } else {
          return ComponentReference("$className?", className);
        }
      }
    case "":
      {
        final className = toClassName(model);
        if (model.isNotEmpty) {
          return CollectionReference(className + "?", className);
        } else if (collection.isNotEmpty) {
          return CollectionListReference("List<$className>?", className);
        } else {
          throw Exception("model and collection both cannot be empty");
        }
      }
    default:
      {
        return null;
      }
  }
}

class CollectionListReference extends Reference {
  final className;
  CollectionListReference(
    String symbol,
    this.className,
  ) : super(symbol);
}

class CollectionReference extends Reference {
  final className;
  CollectionReference(
    String symbol,
    this.className,
  ) : super(symbol);
}

class ComponentListReference extends Reference {
  final className;
  ComponentListReference(
    String symbol,
    this.className,
  ) : super(symbol);
}

class ComponentReference extends Reference {
  final className;
  ComponentReference(
    String symbol,
    this.className,
  ) : super(symbol);
}

List<Field> getFieldsFromStrapiAttributes(Map<String, dynamic> attributes) {
  final returnable = <Field>[];
  attributes.forEach(
    (name, value) {
      final type = getDartTypeFromStrapiType(
          name: name,
          strapiType: value["type"],
          component: value["component"]?.split(".").last,
          model: value["model"],
          collection: value["collection"],
          componentRepeatable: value["repeatable"]);
      if (type is Reference) {
        returnable.add(
          Field(
            (b) => b
              ..name = name
              ..type = type
              ..modifier = FieldModifier.final$,
          ),
        );
      }
    },
  );
  return returnable;
}

extension FieldExt on Field {
  Code accessFromMap() {
    switch (type.symbol) {
      case "DateTime?":
        {
          return Code("DateTime.tryParse2(map[\"$name\"])");
        }
      case "double?":
        {
          return Code("double.tryParse2(map[\"$name\"])");
        }
      case "int?":
        {
          return Code("int.tryParse2(map[\"$name\"])");
        }
      case "String?":
        {
          return Code("map[\"$name\"]");
        }
      case "Map<String,dynamic>?":
        {
          return Code("map[\"$name\"]");
        }
      default:
        {
          {
            if (type.symbol.endsWith("Component?")) {
              return Code("${type.symbol}.fromMap(map[\"$name\"])");
            }
            if (type.symbol.startsWith("List<")) {
              final sym =
                  type.symbol.replaceAll("List<", "").replaceAll(">", "");
              return Code("$sym" "Collection.fromIDs(map[\"$name\"])");
            }
          }
          return Code("");
        }
    }
  }
}

final collectionClassString =
    (String className, String classVariableName, String collectionName) {
  final collectionClassName = toClassName(collectionName);
  return '''
class <CollectionClassName> {
  static const collectionName = "<collectionClassName>";

  static List<className> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => className.fromID(id)).toList();
  }

  static Future<className?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return className.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<className>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => className.fromSyncedMap(map)).toList();
    }
  }

  static Future<className?> create(className classVariableName) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: classVariableName.toMap(),
    );
    if (map.isNotEmpty) {
      return className.fromSyncedMap(map);
    }
  }

  static Future<className?> update(className classVariableName) async {
    final id = classVariableName.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: classVariableName.toMap(),
      );
      if (map.isNotEmpty) {
        return className.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<className?> delete(className classVariableName) async {
    final id = classVariableName.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return className.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}'''
      .replaceAll("className", className)
      .replaceAll("classVariableName", classVariableName)
      .replaceAll("<CollectionClassName>", collectionClassName)
      .replaceAll("<collectionClassName>", collectionClassName.toLowerCase());
};
