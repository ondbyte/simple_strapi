import 'package:code_builder/code_builder.dart';
import 'package:inflection2/inflection2.dart';

import 'helpers.dart';

Reference getDartTypeFromStrapiType(
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
          "DateTime",
        );
      }
    case "decimal":
    case "float":
      {
        return Reference("double");
      }
    case "integer":
    case "biginteger":
      {
        return Reference("int");
      }
    case "string":
    case "richtext":
      {
        return Reference("String");
      }
    case "boolean":
      {
        return Reference("bool");
      }
    case "email":
      {
        return Reference("String");
      }
    case "json":
      {
        return Reference("Map<String,dynamic>");
      }
    case "component":
      {
        if (component.isEmpty) {
          throw Exception("component cannot be empty while referencing a type");
        }
        final className = toClassName(component);
        if (componentRepeatable) {
          return ComponentListReference("List<$className>", className);
        } else {
          return ComponentReference("$className", className);
        }
        return null;
      }
    case "":
      {
        if (model.isNotEmpty) {
          final className = toClassName(model);
          return CollectionReference(className + "", className);
        } else if (collection.isNotEmpty) {
          final className = toClassName(collection);
          return CollectionListReference("List<$className>", className);
        } else {
          throw Exception("model and collection both cannot be empty");
        }
        return null;
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
          strapiType: value["type"] ?? "",
          component: (value["component"] != null)
              ? (value["component"] ?? "").split(".").last
              : "",
          model: value["model"] ?? "",
          collection: value["collection"] ?? "",
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
      case "DateTime":
        {
          return Code("DateTime.tryParse2(map[\"$name\"])");
        }
      case "double":
        {
          return Code("double.tryParse2(map[\"$name\"])");
        }
      case "int":
        {
          return Code("int.tryParse2(map[\"$name\"])");
        }
      case "String":
        {
          return Code("map[\"$name\"]");
        }
      case "Map<String,dynamic>":
        {
          return Code("map[\"$name\"]");
        }
      default:
        {
          {
            if (type.symbol.endsWith("Component")) {
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
    // ignore: top_level_function_literal_block
    (String className, String classVariableName, String collectionName,
        bool buildWidgets, bool isUserCollection) {
  final collectionClassName = () {
    final ccn = toClassName(pluralize(className));
    if (ccn.toLowerCase() == className.toLowerCase()) {
      return ccn + "s";
    }
    return ccn;
  }();
  if (collectionName == null || collectionName.isEmpty) {
    collectionName = pluralize(className);
  }
  var returnable = '''
class <CollectionClassName> {
  static const collectionName = "<collectionName>";

  static List<className> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => className.fromID(id)).toList();
  }

  static Future<className> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return className.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<className>> findMultiple({int limit = 16,StrapiQuery query}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName,limit:limit,query:query);
    if (list.isNotEmpty) {
      return list.map((map) => className.fromSyncedMap(map)).toList();
    }
  }

  static Future<className> create(className classVariableName) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: classVariableName.toMap(),
    );
    if (map.isNotEmpty) {
      return className.fromSyncedMap(map);
    }
  }

  static Future<className> update(className classVariableName) async {
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

  static Future<className> delete(className classVariableName) async {
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
  static List<className> fromListOfIDOrData(List idsOrData) {
    if(idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => className.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => className.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static className fromIDorData(idOrData) {
    if (idOrData is String) {
      return className.fromID(idOrData);
    }
    if (idOrData is Map) {
      return className.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<className>> getForListOfIDs(List<String> ids) async {
    if(ids!=null&&ids.isEmpty){
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(collection: collectionName,query: query);
    if (list.isNotEmpty) {
      return list.map((map) => className.fromSyncedMap(map)).toList();
    }
  }

  <userMe>

  <widgetBuilder>
}''';
  var userMeString = "";
  if (isUserCollection) {
    userMeString = '''
  static Future<className> me() async {
    if(Strapi.i.strapiToken.isEmpty){
      throw Exception("cannot get users/me endpoint without token, please authenticate first");
    }
    final response = await StrapiCollection.customEndpoint(
      collection:"users",
      endPoint: "me"
    );
    if (response is Map) {
      return className.fromSyncedMap(response);
    } else if (response is List && response.isNotEmpty) {
      return User.fromSyncedMap(response.first);
    } else {
      throw Exception("wrong response from users/me endpoint");
    }
  }''';
  }
  returnable = returnable.replaceFirst("<userMe>", userMeString);
  var widgetBuilderSTring = "";
  if (buildWidgets) {
    // ignore: prefer_double_quotes
    widgetBuilderSTring = '''static Widget widget(
      {className strapiObject, Widget Function(className) builder}) {
    return StrapiObs(
      strapiObject: strapiObject.toMap(),
      builder: (map) {
        return builder(className.fromMap(map));
      },
    );
  }''';
  }
  returnable = returnable.replaceAll("<widgetBuilder>", widgetBuilderSTring);

  returnable = returnable
      .replaceAll("className", className)
      .replaceAll("classVariableName", classVariableName)
      .replaceAll("<CollectionClassName>", collectionClassName)
      .replaceAll("<collectionName>", collectionName);
  return returnable;
};

final strapiBaseWidget = '''
typedef Widget StrapiWidgetBuilder(Map);

class StrapiObs extends StatefulWidget {
  ///an object with a field id, mostly a collection object from strapi, whenever a new object arrives for a same
  ///id, every instance of the collection object which is encapsulated in [StrapiObs] rebuilds by providing
  ///the new instance accross the app
  final Map<String, dynamic> strapiObject;
  final StrapiWidgetBuilder builder;

  ///make strapi collection objects reactive, whenever a new version of the [strapiObject] arrives
  ///widget is rebuilt with new object provided to the [builder].
  StrapiObs({Key key, this.strapiObject, this.builder}) : super(key: key);

  @override
  _StrapiObsState createState() => _StrapiObsState();
}

class _StrapiObsState extends State<StrapiObs> {
  Map<String, dynamic> strapiObject;
  @override
  void initState() {
    strapiObject = widget.strapiObject;
    super.initState();
    if (widget.strapiObject.containsKey("id")) {
      Strapi.i.objectsStram.listen((newStrapiObject) {
        if (newStrapiObject["id"] == widget.strapiObject["id"]) {
          setState(() {
            strapiObject = newStrapiObject;
          });
        }
      });
    } else {
      throw Exception(
          "provided strapi object doesn't contain an ID field, only collection types are supported, do not provide fresh objects");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(strapiObject);
  }
}''';
