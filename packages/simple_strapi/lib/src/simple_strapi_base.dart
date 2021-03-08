import 'dart:async';
import 'dart:convert';
import 'dart:io';

class StrapiResponseException implements Exception {
  final String log;
  final StrapiResponse response;

  StrapiResponseException(this.log, this.response) {
    print(
      log,
    );
    print("strapi response was");
    print(response);
  }
}

class StrapiCollection {
  static Future<dynamic> customEndpoint({
    required String collection,
    required String endPoint,
    int? limit,
    StrapiQuery? query,
  }) async {
    final path = collection + "/" + endPoint;
    query = query != null ? (query) : StrapiQuery();
    query.enableLimit(limit);
    final response =
        await Strapi.i.request(path, queryString: query.queryString);
    if (response.failed) {
      throw StrapiResponseException(
        "failed to get multiple objects from collection $collection",
        response,
      );
    }
    return response.body;
  }

  static Future<List<Map<String, dynamic>>> findMultiple(
      {required String collection, int? limit, StrapiQuery? query}) async {
    final path = collection;
    query = query != null ? (query) : StrapiQuery();
    query.enableLimit(limit);
    final response =
        await Strapi.i.request(path, queryString: query.queryString);
    if (response.failed) {
      throw StrapiResponseException(
        "failed to get multiple objects from collection $collection",
        response,
      );
    }
    return response.body;
  }

  static Future<Map<String, dynamic>> findOne(
      {required String collection, required String id}) async {
    final path = collection + "/" + id;
    final response = await Strapi.i.request(
      path,
    );
    if (response.failed) {
      throw StrapiResponseException(
        "failed to get single object from collection $collection",
        response,
      );
    }
    return response.body.first;
  }

  static Future<Map<String, dynamic>> create({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    final path = collection;
    final response = await Strapi.i.request(
      path,
      method: "POST",
      body: data,
    );

    if (response.failed) {
      throw StrapiResponseException(
        "failed to create object at collection $collection",
        response,
      );
    }
    return response.body.first;
  }

  static Future<Map<String, dynamic>> update({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final path = collection + "/" + id;
    final response = await Strapi.i.request(path, method: "PUT", body: data);
    if (response.failed) {
      throw StrapiResponseException(
        "failed to update single object with id $id at collection $collection",
        response,
      );
    }
    return response.body.first;
  }

  static Future<int> count(String collection) async {
    final path = collection + "/count";
    final response = await Strapi.i.request(
      path,
    );
    if (response.failed) {
      throw StrapiResponseException(
          "failed to count at collection $collection", response);
    }
    return response.count;
  }

  static Future<Map<String, dynamic>> delete({
    required String collection,
    required String id,
  }) async {
    final path = collection + "/$id";
    final response = await Strapi.i.request(
      path,
      method: "DELETE",
    );
    if (response.failed) {
      throw StrapiResponseException(
        "failed to delete at collection $collection for id :$id",
        response,
      );
    }
    return response.body.isNotEmpty ? response.body.first : {};
  }
}

///A singleton you can access it from anywhere like
///```dart
///Strapi.instance;
/////or
///Strapi.i;
///```
///Strapi instance is what you need to do authentication with strapi server and get a jwt token,
///it is also easier to make authenticated request using [request] method
class Strapi {
  String host = "localhost:1337";

  ///should the requests use 'https' or not defaults to false
  bool shouldUseHttps = false;
  final _client = HttpClient();
  String strapiToken = "";

  static final _instance = Strapi._private();

  static Strapi get instance => _instance;

  static Strapi get i => _instance;

  ///output the error to console if any
  bool verbose = false;

  Strapi._private();

  ///gets whether a user is authenticated or not,
  ///if no user present call any authentication methods first,
  ///or if you need to add a new method for your custom provider at strapi,
  ///consider adding a extension method on [Strapi] like
  ///```dart
  ///extension MyExtension on Strapi {
  ///Future customAuthentication() async {
  ///  final StrapiResponse strapiResponse = await request(
  ///    "/auth/my-custom-provider/callback",
  ///    method: "GET",
  ///    params: {
  ///      "customParam1": "value1",
  ///      "customParam2": "value2",
  ///    },
  ///  );
  ///  if (strapiResponse.failed) {
  ///    //request failed
  ///  }
  ///  //set the strapiToken making your custom authentication method sucessfull
  ///  strapiToken = strapiResponse.body.first["jwt"];
  /// }
  ///}
  ///```
  bool get userPresent => strapiToken.isNotEmpty;

  ///to use this provider first you need to add a custom provider for strapi with Firebase SDK enabled
  ///otherwise you'll recieve "This provider is disabled." response
  Future<StrapiResponse> authenticateWithFirebaseToken({
    required String firebaseProviderToken,
    required String email,
    required String name,
  }) async {
    assert(firebaseProviderToken.isNotEmpty);
    assert(email.isNotEmpty);
    assert(name.isNotEmpty);

    final response = await request("/auth/firebase/callback", params: {
      "access_token": "$firebaseProviderToken",
      "email": email,
      "name": name,
    });
    if (!response.failed) {
      strapiToken = response.body.first["jwt"];
    }
    return response;
  }

  ///constructs https or http url from path, params and [StrapiQuery]
  Uri _strapiUri(String unencodedPath,
      {Map<String, String>? params, String? queryString}) {
    if (shouldUseHttps) {
      final https = Uri.https(host, unencodedPath, params);
      return https.replace(query: queryString);
    }
    final http = Uri.http(host, unencodedPath, params);
    return http.replace(query: queryString);
  }

  ///an authentcated strapi request making towards the endpionts of your strapi server,
  ///in every request you make a authorization token is inserted automatically if the [strapiToken] is present
  ///otherwise the request will be plain unauthenticated request,
  ///[host] will be used a your strapi server
  ///[path] will be your endpoint, for example if you need to count restaurants collection
  ///```dart
  ///final response = request("/restaurants/count");
  ///print(response.count);
  ///```
  ///[body] should be the json data you need to post or or (do not forget to change [method] too)
  ///[method] should be the required http request type for the endpoint, defaluts to 'GET'
  ///[params] will be custom key value pair arguments to pas in the url of the request
  Future<StrapiResponse> request(
    String path, {
    Map<String, dynamic>? body,
    String method = "GET",
    Map<String, String>? params,
    String? queryString,
    int maxTimeOutInMillis = 15000,
  }) async {
    try {
      var closed = false;
      final uri = _strapiUri(path, params: params, queryString: queryString);
      if (verbose) {
        sPrint(uri);
      }
      final request = await _client.openUrl(
        method,
        uri,
      );
      if (strapiToken.isNotEmpty) {
        request.headers.add("Authorization", "Bearer " + strapiToken);
      }
      request.headers.contentType = ContentType.json;
      if (body != null) {
        request.write(jsonEncode(body));
      }
      Future.delayed(
        Duration(milliseconds: maxTimeOutInMillis),
        () => {
          if (!closed)
            {
              request.abort(TimeoutException(
                  "reaching strapi server timed out, current timeout is $maxTimeOutInMillis millis"))
            }
        },
      );
      final response = await request.close();
      closed = true;
      final responseBodyString =
          (await response.transform(utf8.decoder).toList()).join();

      late final responseJson;
      try {
        responseJson = jsonDecode(responseBodyString);
        if (verbose) {
          sPrint("raw response is");
          sPrint(JsonEncoder.withIndent("  ").convert(responseJson));
        }
      } on FormatException catch (e) {
        return StrapiResponse(
          body: [],
          count: 0,
          error: "format-exception",
          errorMessage: e.message,
          failed: response.statusCode > 210,
          statusCode: response.statusCode,
          url: uri,
        );
      }

      final failed = response.statusCode > 210;
      if (responseJson is Map<String, dynamic>) {
        return StrapiResponse(
            statusCode: response.statusCode,
            body: [if (!failed) responseJson],
            error: responseJson["error"] ?? "",
            errorMessage: failed ? responseJson.toString() : "",
            failed: failed,
            count: failed ? 0 : 1,
            url: uri);
      } else if (responseJson is int) {
        return StrapiResponse(
            statusCode: response.statusCode,
            body: [],
            error: "",
            errorMessage: "",
            failed: failed,
            count: responseJson,
            url: uri);
      } else if (responseJson is List &&
          responseJson.isNotEmpty &&
          responseJson.first is Map<String, dynamic>) {
        return StrapiResponse(
          statusCode: response.statusCode,
          body: responseJson.map((e) => (e as Map<String, dynamic>)).toList(),
          error: "",
          errorMessage: "",
          failed: failed,
          count: responseJson.length,
          url: uri,
        );
      } else {
        return StrapiResponse(
          body: [],
          count: 0,
          error: "empty-response",
          errorMessage: "",
          failed: true,
          statusCode: response.statusCode,
          url: uri,
        );
      }
    } on HttpException catch (e, s) {
      if (verbose) {
        print(e);
        print(s);
      }
      return StrapiResponse(
        body: [],
        count: 0,
        error: "http-exception",
        errorMessage: e.message,
        failed: true,
        statusCode: -1,
        url: e.uri,
      );
    }
  }

  ///everytime a new object is recieved from server it is added to this stream
  final _objectsStramController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get objectsStram =>
      _objectsStramController.stream;
}

class StrapiResponse {
  final int statusCode;
  final bool failed;
  final String error;
  final String errorMessage;
  final List<Map<String, dynamic>> body;
  final int count;
  final Uri? url;

  StrapiResponse(
      {required this.statusCode,
      required this.failed,
      required this.error,
      required this.errorMessage,
      required this.body,
      required this.count,
      required this.url});

  @override
  String toString() {
    return "statustCode: $statusCode\nfailed: $failed\nerror: $error\nerrorMessage: $errorMessage\nbody: $body\ncount: $count\nurl: $url";
  }
}

class StrapiUtils {
  static double? parseDouble(source) {
    if (source == null) {
      return null;
    }
    if (source is double) {
      return source;
    }
    return double.tryParse(source);
  }

  static int? parseInt(source) {
    if (source == null) {
      return null;
    }
    if (source is int) {
      return source;
    }
    return int.tryParse(source);
  }

  static DateTime? parseDateTime(source) {
    if (source == null) {
      return null;
    }
    if (source is DateTime) {
      return source;
    }
    return DateTime.tryParse(source);
  }

  static bool parseBool(source) {
    if (source == null) {
      return false;
    }
    if (source is bool) {
      return source;
    }
    return source == "true";
  }

  static List<T> objFromListOfMap<T>(
      dynamic data, T Function(dynamic) forEach) {
    final list = <T>[];
    if (data is List && data.isNotEmpty) {
      data.forEach((e) {
        list.add(forEach(e));
      });
    }
    return list;
  }

  static T? objFromMap<T>(dynamic data, T Function(dynamic) returner) {
    if (data is Map && data.isNotEmpty) {
      return returner(data);
    }
    return null;
  }
}

void sPrint(d) {
  print("[Strapi] " + d.toString());
}

String _operation(StrapiQueryOperation operation) {
  switch (operation) {
    case StrapiQueryOperation.equalTo:
      {
        return "_eq";
      }
    case StrapiQueryOperation.includesInAnArray:
      {
        return "_in";
      }
  }
}

enum StrapiQueryOperation { equalTo, includesInAnArray }

class StrapiQuery {
  final _queries = <String>[];

  String? get queryString => _queries.isEmpty ? null : _queries.join("&");

  void where(String field, StrapiQueryOperation operation, value) {
    _queries.add(field + _operation(operation) + "=" + value);
  }

  void enableLimit(int? limit) {
    if (limit is int) {
      if (!_queries.any((e) => e.startsWith("_limit="))) {
        _queries.add("_limit=$limit");
      }
    }
  }
}
