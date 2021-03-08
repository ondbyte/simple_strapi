import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:inflection2/inflection2.dart';
import 'package:path/path.dart' as path;

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import 'helpers.dart';
import 'types.dart';

class Gen {
  final Directory strapiProjectDirectory;
  final Directory outPutDirectory;
  final bool isSchemaOnly;
  final List<File> defaultModels;

  late final Directory apiDirectory;
  late final componentDirectory;
  late final extensionsDirectory;

  Gen(
    this.strapiProjectDirectory,
    this.outPutDirectory,
    this.isSchemaOnly,
    this.defaultModels,
  ) {
    apiDirectory = Directory(
      path.join(strapiProjectDirectory.path, "api"),
    );
    componentDirectory = Directory(
      path.join(strapiProjectDirectory.path, "components"),
    );
    extensionsDirectory = Directory(
      path.join(strapiProjectDirectory.path, "extensions"),
    );
  }

  String? getCollectionNameFromRoutesFile(File file) {
    final splitted = path.split(file.path);
    splitted.removeLast();
    splitted.removeLast();
    final configFile =
        File(path.joinAll([...splitted, "config", "routes.json"]));
    if (configFile.existsSync()) {
      final data = configFile.readAsStringSync();
      final j = jsonDecode(data);
      final routes = j["routes"];
      if (routes is List) {
        final name = path
            .basenameWithoutExtension(path.basenameWithoutExtension(file.path));
        final route =
            routes.firstWhere((element) => element["handler"] == "$name.find");
        if (route is Map) {
          final path = route["path"];
          if (route.containsKey("path")) {
            if (path is String) {
              return path.replaceFirst("/", "");
            }
          }
        }
      }
    }
  }

  Future generate() async {
    final apiFolderFiles =
        await readFilesWithExtension(apiDirectory, extn: ".settings.json")
            .toList();
    final extensionFolderFiles = await readFilesWithExtension(
            extensionsDirectory,
            extn: ".settings.json")
        .toList();
    final componentsFolderFiles =
        await readFilesWithExtension(componentDirectory, extn: ".json")
            .toList();

    final apiJsons = await readAllFileToJson(apiFolderFiles);

    final extnJsons = await readAllFileToJson(extensionFolderFiles);

    final componentJsons = await readAllFileToJson(componentsFolderFiles);

    final l = Library((b) {
      b
        ..directives.add((DirectiveBuilder()
              ..type = DirectiveType.import
              ..url = "package:simple_strapi/simple_strapi.dart")
            .build());
      apiJsons.forEach((key, value) {
        final collectionName = getCollectionNameFromRoutesFile(key);
        final classes = generateClass(key, value, false, collectionName);
        b
          ..body.addAll([
            ...classes,
          ]);
      });
      extnJsons.forEach((key, value) {
        final collectionName = getCollectionNameFromRoutesFile(key);
        final classes = generateClass(key, value, false, collectionName);
        b
          ..body.addAll([
            ...classes,
          ]);
      });
      final completer = Completer<bool>();
      componentJsons.forEach((key, value) {
        final collectionName = getCollectionNameFromRoutesFile(key);
        final classes = generateClass(key, value, true, collectionName);
        b
          ..body.addAll([
            ...classes,
          ]);
        if (key == componentJsons.keys.last) {
          completer.complete(true);
        }
      });
    });

    final e = DartEmitter();
    final f = DartFormatter();
    final dart = f.format("${l.accept(e)}");
    final dir = Directory(path.join(
      outPutDirectory.path,
      "super_strapi",
    ));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await File(path.join(dir.path, "super_strapi.dart")).writeAsString(dart);
  }

  Code generateCollectionClass(
      String className, String classVariableName, String? collectionName) {
    return Code(collectionClassString(className, classVariableName,
        collectionName ?? PLURAL.convert(className)));
  }

  List<dynamic> generateClass(File file, Map<String, dynamic> j,
      bool isComponent, String? collectionName) {
    if (!j.containsKey("attributes")) {
      throw Exception("attributes missing in the strapi model");
    }
    final _name =
        path.basenameWithoutExtension(path.basenameWithoutExtension(file.path));

    final className = toClassName(_name);
    final camelClassName = toCamelClassName(className);

    final fields = getFieldsFromStrapiAttributes(j["attributes"]);

    final createdAtField = Field(
      (b) => {
        b
          ..name = "createdAt"
          ..type = Reference("DateTime?")
          ..modifier = FieldModifier.final$
      },
    );

    final updatedAtField = Field(
      (b) => {
        b
          ..name = "updatedAt"
          ..type = Reference("DateTime?")
          ..modifier = FieldModifier.final$
      },
    );

    final syncedField = Field(
      (b) => {
        b
          ..name = "_synced"
          ..type = Reference("bool")
          ..modifier = FieldModifier.final$
      },
    );

    final idField = Field(
      (b) => {
        b
          ..name = "id"
          ..type = Reference("String?")
          ..modifier = FieldModifier.final$
      },
    );

    final params = <Parameter>[];
    for (final field in fields) {
      params.add((ParameterBuilder()
            ..name = field.name
            ..toThis = true)
          .build());
    }

    final classBuilder = ClassBuilder();

    final constructorFromID = (ConstructorBuilder()
          ..name = "fromID"
          ..requiredParameters.add((ParameterBuilder()
                ..name = idField.name
                ..toThis = true)
              .build())
          ..initializers.addAll([
            Code("_synced = false"),
            ...fields.map((e) => Code("${e.name} = null")),
            Code("${createdAtField.name} = null"),
            Code("${updatedAtField.name} = null")
          ]))
        .build();

    final constructorFresh = (ConstructorBuilder()
          ..name = "fresh"
          ..requiredParameters.addAll([
            ...params,
          ])
          ..initializers.addAll([
            Code("_synced = false"),
            Code("${createdAtField.name} = null"),
            Code("${updatedAtField.name} = null"),
            Code("${idField.name} = null"),
          ]))
        .build();

    final constructor_synced = (ConstructorBuilder()
          ..name = "_synced"
          ..requiredParameters.addAll([
            ...fields.map((e) => (ParameterBuilder()
                  ..name = e.name
                  ..toThis = true)
                .build()),
            (ParameterBuilder()
                  ..name = createdAtField.name
                  ..toThis = true)
                .build(),
            (ParameterBuilder()
                  ..name = updatedAtField.name
                  ..toThis = true)
                .build(),
            (ParameterBuilder()
                  ..name = idField.name
                  ..toThis = true)
                .build(),
          ])
          ..initializers.addAll([
            Code("_synced = true"),
          ]))
        .build();

    final constructor_unsynced = (ConstructorBuilder()
          ..name = "_unsynced"
          ..requiredParameters.addAll([
            ...fields.map((e) => (ParameterBuilder()
                  ..name = e.name
                  ..toThis = true)
                .build()),
            if (!isComponent)
              (ParameterBuilder()
                    ..name = createdAtField.name
                    ..toThis = true)
                  .build(),
            if (!isComponent)
              (ParameterBuilder()
                    ..name = updatedAtField.name
                    ..toThis = true)
                  .build(),
            if (!isComponent)
              (ParameterBuilder()
                    ..name = idField.name
                    ..toThis = true)
                  .build(),
          ])
          ..initializers.addAll([
            if (!isComponent) Code("_synced = false"),
          ]))
        .build();

    final getSyncedMethod = (MethodBuilder()
          ..name = "synced"
          ..lambda = true
          ..type = MethodType.getter
          ..returns = Reference("bool")
          ..body = Code("_synced"))
        .build();

    final copyWithMethod = (MethodBuilder()
          ..name = "copyWIth"
          ..returns = Reference("$className")
          ..requiredParameters.addAll(fields.map((field) => (ParameterBuilder()
                ..name = field.name
                ..type = field.type)
              .build()))
          ..body = CodeExpression(Code("$className._unsynced")).call([
            ...fields
                .map((field) =>
                    CodeExpression(Code("${field.name}??this.${field.name}")))
                .toList(),
            CodeExpression(Code("this.${createdAtField.name}")),
            CodeExpression(Code("this.${updatedAtField.name}")),
            CodeExpression(Code("this.${idField.name}")),
          ]).code)
        .build();

    final accessFromMapExpression = (Field f, bool fromMap) {
      final type = f.type;
      if (type is CollectionListReference) {
        return fromMap
            ? CodeExpression(
                Code("${type.className}s.fromIDs(map[\"${f.name}\"])"),
              )
            : CodeExpression(
                Code("\"${f.name}\":${f.name}.map((e)=>e.id)"),
              );
      }
      if (type is CollectionReference) {
        return CodeExpression(
          fromMap
              ? Code("${type.className}.fromID(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}.id"),
        );
      }
      if (type is ComponentListReference) {
        return CodeExpression(
          fromMap
              ? Code(
                  "map[\"${f.name}\"].map((e)=>${type.className}.fromMap(e)).tiList()")
              : Code(
                  "\"${f.name}\":${f.name}?.map((e)=>e.toMap())",
                ),
        );
      }
      if (type is ComponentReference) {
        return CodeExpression(
          fromMap
              ? Code("${type.className}.fromMap(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}?.toMap()"),
        );
      }
      if (type.symbol == "DateTime?") {
        return CodeExpression(
          fromMap
              ? Code("StrapiUtils.parseDateTime(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}?.toIso8601String()"),
        );
      }
      if (type.symbol == "double?") {
        return CodeExpression(
          fromMap
              ? Code("StrapiUtils.parseDouble(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}"),
        );
      }
      if (type.symbol == "int?") {
        return CodeExpression(
          fromMap
              ? Code("StrapiUtils.parseInt(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}"),
        );
      }
      if (type.symbol == "bool?") {
        return CodeExpression(
          fromMap
              ? Code("StrapiUtils.parseBool(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}"),
        );
      }
      if (type.symbol == "Map<String,dynamic>?") {
        return CodeExpression(
          fromMap
              ? Code("jsonDecode(map[\"${f.name}\"])")
              : Code("\"${f.name}\":jsonEncode(${f.name}"),
        );
      }
      return fromMap
          ? CodeExpression(Code("map[\"f.name\"]"))
          : CodeExpression(Code("\"${f.name}\":${f.name}"));
    };

    final toMapMethod = (MethodBuilder()
          ..name = "toMap"
          ..returns = Reference("Map<String,dynamic>")
          ..lambda = true
          ..body = Code(
            "{${fields.map((field) => accessFromMapExpression(field, false).code.toString()).join(",")}}",
          ))
        .build();

    final fromSyncedMapMethod = (MethodBuilder()
          ..name = "fromSyncedMap"
          ..static = true
          ..returns = Reference(className)
          ..requiredParameters.add((ParameterBuilder()
                ..name = "map"
                ..type = Reference("Map<String,dynamic>"))
              .build())
          ..body = CodeExpression(Code("$className._synced")).call([
            ...fields.map((field) => accessFromMapExpression(field, true)),
            if (!isComponent) accessFromMapExpression(createdAtField, true),
            if (!isComponent) accessFromMapExpression(updatedAtField, true),
            if (!isComponent) accessFromMapExpression(idField, true)
          ]).code)
        .build();

    final fromMapMethod = (MethodBuilder()
          ..name = "fromMap"
          ..static = true
          ..returns = Reference(className)
          ..requiredParameters.add((ParameterBuilder()
                ..name = "map"
                ..type = Reference("Map<String,dynamic>"))
              .build())
          ..body = CodeExpression(Code("$className._unsynced")).call([
            ...fields.map((field) => accessFromMapExpression(field, true)),
            if (!isComponent) accessFromMapExpression(createdAtField, true),
            if (!isComponent) accessFromMapExpression(updatedAtField, true),
            if (!isComponent) accessFromMapExpression(idField, true)
          ]).code)
        .build();

    classBuilder
      ..name = className
      ..fields.addAll([
        if (!isComponent) syncedField,
        ...fields,
        if (!isComponent) createdAtField,
        if (!isComponent) updatedAtField,
        if (!isComponent) idField,
      ])
      ..constructors.addAll([
        if (!isComponent) constructorFromID,
        if (!isComponent) constructorFresh,
        if (!isComponent) constructor_synced,
        constructor_unsynced,
      ])
      ..methods.addAll([
        if (!isComponent) getSyncedMethod,
        if (!isComponent) copyWithMethod,
        toMapMethod,
        if (!isComponent) fromSyncedMapMethod,
        fromMapMethod,
      ]);
    return [
      classBuilder.build(),
      if (!isComponent)
        generateCollectionClass(className, camelClassName, collectionName),
    ];
  }

  Future<Map<File, Map<String, dynamic>>> readAllFileToJson(
      List<File> files) async {
    final returnable = <File, Map<String, dynamic>>{};
    for (final file in files) {
      returnable.addAll({file: await readToJson(file)});
    }
    return returnable;
  }

  Future<Map<String, dynamic>> readToJson(File file) async {
    try {
      final content = await file.readAsString();
      final j = json.decode(content);
      return j;
    } catch (e) {
      print("unable to read file to json ${file.path}");
    }
    return {};
  }

  Stream<File> readFilesWithExtension(Directory dir,
      {String extn = ""}) async* {
    final stream = dir.list(recursive: true);
    await for (final maybeFile in stream) {
      if (maybeFile is File) {
        if (maybeFile.path.endsWith(extn)) {
          yield maybeFile;
        }
      }
    }
  }
}
