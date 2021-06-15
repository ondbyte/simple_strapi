import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:simple_strapi/simple_strapi.dart';

part 'simple_strapi_graph_query.dart';

///Exception thrown when you call [Strapi.i.request]
class StrapiResponseException extends StrapiException {
  final StrapiResponse response;

  StrapiResponseException(String msg, this.response) : super(msg: msg);

  @override
  String toString() {
    return "$msg\n$response";
  }
}

class StrapiException implements Exception {
  final String msg;

  StrapiException({required this.msg});

  @override
  String toString() {
    return "$msg";
  }
}

///basic queries against a collection object of strapi
class StrapiCollection {
  ///use this to reach a custom endpoint you've setup for a strapi collection
  ///if you setup a endpoint name `xEndPoint` for collection name `xCollection` and the resulting route is
  /// `/xCollection/xEndPoint`, then you have to use this method like this
  ///```dart
  ///final response = await StrapiCollection.customEndpoint(
  ///   collection: "xCollection",
  ///   endPoint: "xEndPoint",
  ///)
  ///```
  ///throws [StrapiResponseException] if response is failed
  static Future<List<Map<String, dynamic>>> customEndpoint({
    required String collection,
    required String endPoint,
    Map<String, String>? params,
    String? method,
    int? limit,
  }) async {
    final path = collection + "/" + endPoint;
    final response = await Strapi.i.request(
      path,
      params: params,
      method: method,
    );
    if (response.failed) {
      throw StrapiResponseException(
        "failed to get from custom endpoint $path",
        response,
      );
    }
    if (!response.failed) {
      StrapiObjectListener._inform(response.body);
    }
    return response.body;
  }

  ///returns all objects in a collection, run get query against a [collection], limit the number of objects in the response by setting [limit],
  ///throws [StrapiResponseException] if response is failed
  static Future<List<Map<String, dynamic>>> findMultiple({
    required String collection,
    int? limit,
  }) async {
    final response = await Strapi.i
        .request(collection, params: {if (limit is int) "_limit": "$limit"});
    if (response.failed) {
      throw StrapiResponseException(
        "failed to get multiple objects from collection $collection",
        response,
      );
    }
    if (!response.failed) {
      StrapiObjectListener._inform(response.body);
    }
    return response.body;
  }

  ///gets a single object in a [collection] with [id],
  ///throws [StrapiResponseException] if response is failed
  static Future<Map<String, dynamic>> findOne(
      {required String collection, required String id}) async {
    StrapiObjectListener._informLoading(id);
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
    if (!response.failed) {
      StrapiObjectListener._inform(response.body);
    }
    return response.body.first;
  }

  ///create a new object at [collection] with the provided [data], returns the object with a [id],
  ///throws [StrapiResponseException] if response is failed
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

  ///update a object with [id] at [collection] with the new [data], returns updated object,
  ///throws [StrapiResponseException] if response is failed
  static Future<Map<String, dynamic>> update({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    StrapiObjectListener._informLoading(id);
    final path = collection + "/" + id;
    final response = await Strapi.i.request(path, method: "PUT", body: data);
    if (response.failed) {
      throw StrapiResponseException(
        "failed to update single object with id $id at collection $collection",
        response,
      );
    }
    if (!response.failed) {
      StrapiObjectListener._inform(response.body);
    }
    return response.body.first;
  }

  ///count the objects in the [collection],
  ///throws [StrapiResponseException] if response is failed
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

  ///deletes a object with [id] at [collection]
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

  ///max listeners for an object id,
  ///exception will be thrown if the max number of listners crosses [Strapi.i.maxListenersForAnObject], set
  ///it as per requirement
  int maxListenersForAnObject = 12;

  ///should the requests use 'https' or not defaults to false
  bool shouldUseHttps = false;

  ///maximum timeout for any http request you make
  int maxTimeOutInMillis = 20000;
  final _client = HttpClient();
  String strapiToken = "";

  static final _instance = Strapi._private();

  ///get [Strapi] instance
  static Strapi get instance => _instance;

  ///get [Strapi] instance
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

  ///to use this method first you need to add a custom provider for strapi with Firebase SDK enabled
  ///otherwise you'll recieve "This provider is disabled." response, go here https://yadunandan.xyz/authenticateWithFirebaseForStrapi to know how to add firebase
  ///as a authentication method, as of now it is the only method which is supported in authenticating with strapi
  Future<StrapiResponse> authenticateWithFirebaseUid({
    required String firebaseUid,
    required String email,
    required String name,
  }) async {
    if (firebaseUid.isEmpty || email.isEmpty || name.isEmpty) {
      throw StrapiException(
        msg: "empty string cannot be passed as parameters",
      );
    }

    final response = await request("/auth/firebase/callback", params: {
      "access_token": "$firebaseUid",
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
      return https.replace(query: https.query + (queryString ?? ""));
    }
    final http = Uri.http(host, unencodedPath, params);
    return http.replace(query: http.query + (queryString ?? ""));
  }

  ///do a graph request to the strapi server, pass the [queryString] mostly generated using,
  ///[StrapiCollectionQuery] or [StrapiModelQuery], [maxTimeOutInMillis] for the request can be set,
  ///returns a [StrapiResponse] which will contain graph response map in its body
  ///throws [StrapiResponseException] if request is failed
  Future<StrapiResponse> graphRequest(String queryString,
      {int maxTimeOutInMillis = 15000}) async {
    if (verbose) {
      sPrint("strapi query string: \n$queryString");
    }
    final response = await request(
      "/graphql",
      method: "POST",
      body: {"query": "{$queryString}"},
      maxTimeOutInMillis: maxTimeOutInMillis,
    );
    if (response.failed) {
      throw StrapiResponseException(
          "Graph request failed for collection ", response);
    }
    return response;
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
    String? method,
    Map<String, String>? params,
    String? queryString,
    int? maxTimeOutInMillis,
  }) async {
    final response = await _request(
      path,
      body: body,
      method: method ?? "GET",
      params: params,
      queryString: queryString,
      maxTimeOutInMillis: maxTimeOutInMillis ?? Strapi.i.maxTimeOutInMillis,
    );
    return response;
  }

  Future<StrapiResponse> _request(
    String path, {
    Map<String, dynamic>? body,
    String method = "GET",
    Map<String, String>? params,
    String? queryString,
    int maxTimeOutInMillis = 15000,
  }) async {
    final uri = _strapiUri(path, params: params, queryString: queryString);
    try {
      var closed = false;
      final request = await _client.openUrl(
        method,
        uri,
      );
      if (strapiToken.isNotEmpty) {
        request.headers.add("Authorization", "Bearer " + strapiToken);
      }
      request.headers.contentType = ContentType.json;
      if (body != null) {
        request.write(
          jsonEncode(body),
        );
      }
      Future.delayed(
        Duration(milliseconds: maxTimeOutInMillis),
        () => {
          if (!closed)
            {
              request.abort(
                TimeoutException(
                  "reaching strapi server timed out, current timeout is $maxTimeOutInMillis millis",
                ),
              )
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
          sPrint("================Verbose report==================");
          print(uri);
          print(
            jsonEncode(body),
          );
          print(method);
          print(params);
          print(queryString);
          print("raw response is");
          print(JsonEncoder.withIndent("  ").convert(responseJson));
          sPrint("================Verbose report end==================");
        }
      } on FormatException catch (e) {
        responseJson = null;
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
          url: uri,
        );
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
        sPrint(e);
        sPrint(s);
      }
      return StrapiResponse(
        body: [],
        count: 0,
        error: "http-exception",
        errorMessage: e.message,
        failed: true,
        statusCode: -1,
        url: uri,
      );
    } on TimeoutException catch (e, s) {
      if (verbose) {
        sPrint(e);
        sPrint(s);
      }
      return StrapiResponse(
        body: [],
        count: 0,
        error: "timeout-exception",
        errorMessage: e.message ?? "",
        failed: true,
        statusCode: -1,
        url: uri,
      );
    }
  }
}

///callng [Strapi.i.request] will return this
class StrapiResponse {
  ///http response code for the rquest made
  final int statusCode;

  ///immediate check whether this response is failed or not i.e non ~200 code
  final bool failed;

  ///short error message
  final String error;

  ///error message
  final String errorMessage;

  ///strapi json response body as dart map
  final List<Map<String, dynamic>> body;

  ///number of entities in the response
  ///or the result of count api against a collection
  final int count;

  ///url the request is made against
  final Uri? url;

  ///object that is returned when you call [Strapi.i.request]
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

///helpers for simple_strapi package
class StrapiUtils {
  ///from string to dart enum
  static T? toEnum<T>(List<T> enums, String? name) {
    if (name?.isEmpty ?? true) {
      return null;
    }
    if (enums.isEmpty) {
      return null;
    }
    T? t;
    for (final e in enums) {
      if (enumToString(e) == name) {
        t = e;
        break;
      }
    }
    return t;
  }

  ///from dart enum to string, calling this by passing `Some.enumarator` will give you `enumarator`
  static String enumToString(enumConstant) {
    if (enumConstant == null) {
      return "";
    }
    return enumConstant.toString().split(".").last;
  }

  static double? parseDouble(source) {
    if (source == null) {
      return null;
    }
    if (source is double) {
      return source;
    }
    return double.tryParse("$source");
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
      dynamic data, T? Function(dynamic) forEach) {
    final list = <T>[];
    if (data is List && data.isNotEmpty) {
      data.forEach((e) {
        try {
          final o = forEach(e);
          if (o is T) {
            list.add(o);
          }
        } catch (e, s) {
          if (Strapi.i.verbose) {
            sPrint("error while parsing strapi object");
            sPrint(e);
            sPrint(s);
          } else {
            sPrint(
                "ignoring a error while parsing a strapi object, set verbose to true to see the error");
          }
        }
      });
    }
    return list;
  }

  static T? objFromMap<T>(dynamic data, T? Function(dynamic) returner) {
    if (data == null) {
      return null;
    }
    try {
      return returner(data);
    } catch (e, s) {
      if (Strapi.i.verbose) {
        sPrint("error while parsing strapi object");
        sPrint(e);
        sPrint(s);
      } else {
        sPrint(
            "ignoring a error while parsing a strapi object, set verbose to true to see the error");
      }
    }
  }
}

void sPrint(d) {
  print("[Strapi] " + d.toString());
}

///static class which manages all listeners of any strapi collection object
class StrapiObjectListener {
  ///every listeners instantiated
  static final _allListeners = <String, List<StrapiObjectListener>>{};

  ///listener function belonging to a instance of [StrapiObjectListener]
  final Function(Map<String, dynamic> listener, bool loading) _listener;
  final String id;
  Map<String, dynamic> _lastData;
  StrapiObjectListener._private(this.id, this._listener, this._lastData);

  void _loading() {
    _listener(_lastData, true);
  }

  void _executeListener() {
    _listener(_lastData, false);
  }

  ///call when you no more need to listen and free up resource
  void stopListening() {
    final objectId = id.split("-").first;
    final myListeners = _allListeners[objectId];
    final me = myListeners?.remove(this) ?? false;
    if (me) {
      final toAdd = myListeners ?? [];
      if (toAdd.isNotEmpty) {
        _allListeners.update(objectId, (value) => toAdd);
      }
      sPrint("Object listener removed");
    } else {
      throw StrapiException(
        msg: "This should not be the case, no listner found, $me",
      );
    }
  }

  ///call when you no more need to listen and free up resource
  void dispose() {
    stopListening();
  }

  static void _informLoading(String id) {
    final allListenerForId = _allListeners[id];
    if (allListenerForId is List) {
      allListenerForId?.forEach(
        (l) {
          l._loading();
        },
      );
    }
  }

  static void _inform(
    List<Map<String, dynamic>> list,
  ) {
    if (list is List) {
      list.forEach((data) {
        final id = data["id"];
        if (id is String) {
          final allListenerForId = _allListeners[id];
          if (allListenerForId is List) {
            allListenerForId?.forEach(
              (l) {
                l._lastData = data;
                l._executeListener();
              },
            );
          }
        }
      });
    }
  }

  ///listen to a Strapi collection object, listening for now means any new instance of the collection
  ///object with [id] is received will be delivered to the [listner], no server changes are are streamed as
  ///of now
  factory StrapiObjectListener({
    required String id,
    required Function(Map<String, dynamic>, bool) listener,
    required Map<String, dynamic> initailData,
  }) {
    sPrint("Startingto listen for object $id");
    final existingListeners = _allListeners[id];
    var length = 0;
    if (existingListeners is List) {
      if (existingListeners?.length == Strapi.i.maxListenersForAnObject) {
        ///exception will be thrown if the max number of listners crosses [Strapi.i.maxListenersForAnObject], set
        ///it as per requirement
        throw Exception(
          "no more listeners for object id $id can be added this, set Strapi.maxListenersForAnObject to higher value",
        );
      }
      length = existingListeners?.length ?? 0;
    }

    final l = StrapiObjectListener._private(
      id + "-" + length.toString(),
      listener,
      initailData,
    );
    _allListeners.update(
      id,
      (value) => [...value, l],
      ifAbsent: () => [
        l,
      ],
    );
    return l;
  }
}
