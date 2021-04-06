import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:yaml/yaml.dart';

import 'gen.dart';

void main(List<String> arguments) async {
  final argvParser = ArgParser();
  try {
    argvParser.addOption(
      "strapi-project-path",
      abbr: "i",
      help:
          "required, strapi project folder to generate the schema/dart classes",
    );
    argvParser.addOption(
      "output-folder",
      abbr: "o",
      help: "required, to output the generated super_strapi project folder",
    );
    argvParser.addFlag(
      "only-schema",
      abbr: "s",
      defaultsTo: false,
      help:
          "defaults to false, if set to true only schema is generated from strapi models otherwise dart classes is generated from strapi models",
    );
    argvParser.addFlag(
      "get-latest-models",
      abbr: "g",
      defaultsTo: false,
      help:
          "defaults to false, if set to true latest default models are fetched from strapi github",
    );

    final argvResults = argvParser.parse(arguments);

    final strapiProjectPath = argvResults["strapi-project-path"];
    final outPutPath = argvResults["output-folder"];
    if (outPutPath == null) {
      throw FormatException();
    }
    final isSchemaOnly = argvResults["only-schema"];
    final shouldGetLatestModel = argvResults["get-latest-models"];

    if (strapiProjectPath != null && outPutPath != null) {
      final strapiProjectDirectory = Directory(strapiProjectPath);
      final outPutFile = await setupOutPutDirectory(Directory(outPutPath));
      checkStrapiProjectRoot(strapiProjectDirectory);
      final defaultModels = await _getLatestDefaultModels(
          strapiProjectDirectory, shouldGetLatestModel);
      //print(defaultModels);

      final gen = Gen(
        strapiProjectDirectory,
        outPutFile,
        isSchemaOnly,
        defaultModels,
        false,
      );

      await gen.generate();
    } else {
      throw FormatException();
    }
  } on FormatException catch (e) {
    print("use fallowing arguments with super_strapi\n");

    print(argvParser.usage);
  }
}

final defaultModelsURL = [
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/",
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-upload/models/"
];

final defaultModelNames = <String>[
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/Permission.settings.json",
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/Role.settings.json",
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/User.settings.json",
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-upload/models/File.settings.json",
];

final tmpDirectory = join(Directory.systemTemp.path);

Future<List<File>> _getLatestDefaultModels(
    Directory strapiProjectDir, bool shouldGet) async {
  final fileList = <File>[];
  final modulesDirectory = Directory(
    join(strapiProjectDir.path, "node_modules"),
  );
  if (!(await modulesDirectory.exists())) {
    print(
        "${modulesDirectory.path} doesnt exists, make sure you are referring a strapi project as input, and make sure you ran 'npm install' in your strapi project");
    exit(0);
  }
  final all =
      await (await modulesDirectory.list()).fold<List<Directory>>([], (pv, e) {
    if (e is Directory) {
      final name = basename(e.path);
      if (name.startsWith("strapi-plugin-")) {
        return [...pv, e];
      }
    }
    return pv;
  });

  await Future.forEach<Directory>(all, (e) async {
    fileList.addAll(
        await readFilesWithExtension(e, extn: "settings.json").toList());
  });
  return fileList;
}

void checkStrapiProjectRoot(Directory directory) {
  if (!directory.existsSync()) {
    print("provided path doesnt exist ${directory.path}");
    exit(0);
  } else if (!File(directory.path + "/package.json").existsSync()) {
    print("provided project is not a node/strapi project ${directory.path}");
    exit(0);
  }
}

Future<File> setupOutPutDirectory(Directory directory) async {
  if (await _validatePubspec(directory)) {
    return File(
      join(directory.path, "super_strapi_generated", "lib",
          "super_strapi_generated.dart"),
    );
  } else {
    throw Exception(
        "unable to validate out-put directory @ ${directory.absolute.path}");
  }
}

Future<bool> _validatePubspec(Directory directory) async {
  final pubspec =
      File(join(directory.path, "super_strapi_generated", "pubspec.yaml"));
  var projectExists = await pubspec.exists();
  if (!projectExists) {
    projectExists = await _makeProject(directory);
  }
  if (!projectExists) {
    print("problem creating a dart project");
    exit(0);
  }
  final yamlString = await pubspec.readAsString();
  final parsed = loadYaml(yamlString);
  final enabled = parsed?["super_strapi"]?["enabled"] ?? false;
  return enabled;
}

Future<bool> _makeProject(Directory directory) async {
  print("generating a dart project @ ${directory.path}");
  final process = await Process.run(
    "dart",
    ["create", "-t", "package-simple", "super_strapi_generated"],
    workingDirectory: directory.path,
  );

  final pubspecFile = File(join(
    directory.path,
    "super_strapi_generated",
    "pubspec.yaml",
  ));
  if (await pubspecFile.exists()) {
    final yamlString = await pubspecFile.readAsString();
    final yaml = loadYaml(yamlString);
    yaml["super_strapi"] = {"enabled": true};
    yaml["dependencies"]["simple_strapi"] = "any";

    await pubspecFile.writeAsString(yaml.toYamlString());
    return true;
  }
  return false;
}

Stream<File> readFilesWithExtension(Directory dir, {String extn = ""}) async* {
  final stream = dir.list(recursive: true);
  await for (final maybeFile in stream) {
    if (maybeFile is File) {
      if (maybeFile.path.endsWith(extn)) {
        yield maybeFile;
      }
    }
  }
}
