import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

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
      defaultsTo: Directory.current.path,
      help:
          "mostly the lib folder of a flutter/dart project to output the generated super_strapi.dart, example of the output <given lib folder>/super_strapi/super_starpi.dart",
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
    final isSchemaOnly = argvResults["only-schema"];
    final shouldGetLatestModel = argvResults["get-latest-models"];

    if (strapiProjectPath != null && outPutPath != null) {
      final strapiProjectDirectory = Directory(strapiProjectPath);
      final outPutDirectory = Directory(outPutPath);
      checkStrapiProjectRoot(strapiProjectDirectory);
      checkOutPutFolder(outPutDirectory);
      final defaultModels = await getLatestDefaultModels(shouldGetLatestModel);

      final gen = Gen(
        strapiProjectDirectory,
        outPutDirectory,
        isSchemaOnly,
        defaultModels,
      );

      await gen.generate();
    } else {
      throw FormatException();
    }
  } on FormatException catch (e) {
    print("use fallowing arguments\n");

    print(argvParser.usage);
  }
}

final defaultModelsURL =
    "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/";

final defaultModelNames = <String>[
  "Permission.settings.json",
  "Role.settings.json",
  "User.settings.json",
];

final tmpDirectory = join(Directory.systemTemp.path);

Future<List<File>> getLatestDefaultModels(bool shouldGet) async {
  final h = HttpClient();
  final fileList = <File>[];
  for (final fileName in defaultModelNames) {
    final file = shouldGet
        ? Uri.parse(defaultModelsURL + fileName)
        : File(join(tmpDirectory, fileName));
    if (file is File) {
      if (!await file.exists()) {
        return getLatestDefaultModels(true);
      } else {
        fileList.add(file);
      }
    } else if (file is Uri) {
      final request = await h.getUrl(file);
      final response = await request.close();
      if (response.statusCode == 200) {
        final data = await response.transform(utf8.decoder).toList();
        final newFile = File(join(tmpDirectory, fileName));
        await newFile.writeAsString(data.join("\n"));
        print(data);
        fileList.add(newFile);
      }
    }
  }
  return fileList;
}

void checkOutPutFolder(Directory directory) {
  if (!directory.existsSync()) {
    print("provided path doesnt exist ${directory.path}");
    exit(0);
  }
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
